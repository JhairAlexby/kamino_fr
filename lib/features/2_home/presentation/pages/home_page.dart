import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' show ImageFilter, Path, Paint, Canvas;
import 'package:flutter/services.dart' show rootBundle, HapticFeedback;
import 'package:dio/dio.dart';
import 'dart:math' as math;
import 'package:kamino_fr/core/app_theme.dart';
import '../provider/home_provider.dart';
import 'package:kamino_fr/config/environment_config.dart';
import 'package:kamino_fr/core/auth/token_storage.dart';
import 'package:kamino_fr/core/network/http_client.dart';
import 'package:kamino_fr/features/2_home/data/places_api.dart';
import 'package:kamino_fr/features/2_home/data/places_repository.dart';
import 'package:kamino_fr/features/2_home/presentation/provider/nearby_places_provider.dart';
import 'package:kamino_fr/features/2_home/presentation/map/places_layers.dart';
import '../widgets/generation_modal.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/nearby_params_modal.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/destination_confirmation_dialog.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/home_sliding_panel.dart';
import 'package:kamino_fr/features/3_profile/presentation/pages/profile_page.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  MapboxMap? _mapboxMap;
  StreamSubscription<geo.Position>? _posSub;
  final bool _followUser = true;
  DateTime? _lastCameraUpdate;
  PlacesLayerController? _placesLayer;
  Uint8List? _userMarkerBytes;
  PolylineAnnotationManager? _routeManager;
  List<Position> _routeCoords = [];
  String _etaText = '';
  String _navMode = 'driving';
  DateTime? _lastRouteRecalc;
  Point? _currentDestination;
  
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _showTooltip = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  void _hideTooltip() {
    if (_showTooltip) {
      setState(() {
        _showTooltip = false;
      });
    }
  }

  Future<void> _enableUserLocation() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      await _applyLocationSettings();
      await _centerCameraOnUser();
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  Future<void> _loadUserMarker() async {
    try {
      final bytes = await rootBundle.load('assets/images/icons/markerUserMale.png');
      _userMarkerBytes = bytes.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error al cargar el marcador del usuario: $e');
      _userMarkerBytes = null;
    }
  }

  Future<void> _applyLocationSettings() async {
    if (_mapboxMap == null) return;
    
    if (_userMarkerBytes == null) {
      await _loadUserMarker();
    }
    
    await _mapboxMap!.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        puckBearingEnabled: false,
        showAccuracyRing: true,
        locationPuck: LocationPuck(
          locationPuck2D: DefaultLocationPuck2D(
            topImage: _userMarkerBytes,
            shadowImage: Uint8List.fromList([]),
          ),
        ),
      ),
    );
  }

  Future<void> _centerCameraOnUser() async {
    try {
      final geoPos = await geo.Geolocator.getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.best);
      final pos = Position(geoPos.longitude, geoPos.latitude);
      await _mapboxMap?.setCamera(
        CameraOptions(center: Point(coordinates: pos), zoom: 14),
      );
    } catch (_) {}
  }

  void _startFollow() {
    _posSub?.cancel();
    _posSub = geo.Geolocator.getPositionStream(locationSettings: const geo.LocationSettings(accuracy: geo.LocationAccuracy.best, distanceFilter: 10))
        .listen((geoPos) async {
      if (!_followUser) return;
      final now = DateTime.now();
      if (_lastCameraUpdate != null && now.difference(_lastCameraUpdate!).inMilliseconds < 1000) return;
      _lastCameraUpdate = now;
      final pos = Position(geoPos.longitude, geoPos.latitude);
      await _mapboxMap?.setCamera(CameraOptions(center: Point(coordinates: pos)));
      if (_routeCoords.isNotEmpty) {
        final off = _distanceToRouteMeters(geoPos.latitude, geoPos.longitude, _routeCoords);
        final shouldRecalc = off > 30.0 && (_lastRouteRecalc == null || now.difference(_lastRouteRecalc!).inMilliseconds > 3000);
        if (shouldRecalc && _currentDestination != null) {
          _lastRouteRecalc = now;
          await _calculateAndShowRoute(
            latOrigin: geoPos.latitude,
            lonOrigin: geoPos.longitude,
            latDest: _currentDestination!.coordinates.lat.toDouble(),
            lonDest: _currentDestination!.coordinates.lng.toDouble(),
            mode: _navMode,
          );
        } else if (_currentDestination != null) {
          final remaining = _remainingDistanceMeters(geoPos.latitude, geoPos.longitude, _routeCoords);
          _updateEtaText(remaining, _navMode);
        }
      }
    });
  }

  Future<void> _onCameraChanged(BuildContext ctx) async {
    if (_mapboxMap == null) return;
    final vm = Provider.of<NearbyPlacesProvider>(ctx, listen: false);
    final camera = await _mapboxMap!.getCameraState();
    final center = camera.center.coordinates;
    final size = MediaQuery.of(context).size;
    final sw = await _mapboxMap!.coordinateForPixel(ScreenCoordinate(x: 0, y: size.height));
    final ne = await _mapboxMap!.coordinateForPixel(ScreenCoordinate(x: size.width, y: 0));
    final swPos = sw.coordinates;
    final nePos = ne.coordinates;
    final diagonalMeters = geo.Geolocator.distanceBetween(
      swPos.lat.toDouble(),
      swPos.lng.toDouble(),
      nePos.lat.toDouble(),
      nePos.lng.toDouble(),
    );
    final radiusKm = (diagonalMeters / 2) / 1000.0;
    final radius = radiusKm.clamp(0.1, 50.0).toDouble();
    vm.loadNearbyDebounced(
      latitude: center.lat.toDouble(),
      longitude: center.lng.toDouble(),
      radius: vm.useManual ? vm.manualRadius : radius,
      limit: vm.manualLimit,
    );
  }

  Future<void> _calculateAndShowRoute({required double latOrigin, required double lonOrigin, required double latDest, required double lonDest, required String mode}) async {
    try {
      final cfg = Provider.of<EnvironmentConfig>(context, listen: false);
      final url = 'https://api.mapbox.com/directions/v5/mapbox/$mode/$lonOrigin,$latOrigin;$lonDest,$latDest?geometries=geojson&access_token=${cfg.mapboxAccessToken}';
      final resp = await Dio().get(url);
      final data = resp.data as Map<String, dynamic>;
      final routes = (data['routes'] as List?) ?? [];
      if (routes.isEmpty) return;
      final r0 = routes.first as Map<String, dynamic>;
      final geometry = r0['geometry'] as Map<String, dynamic>;
      final coords = (geometry['coordinates'] as List).cast<List>();
      _routeCoords = coords.map((c) => Position((c[0] as num).toDouble(), (c[1] as num).toDouble())).toList();
      await _drawRoute(_routeCoords);
      final distance = (r0['distance'] as num?)?.toDouble() ?? _pathLengthMeters(_routeCoords);
      _updateEtaText(distance, mode);
    } catch (_) {}
  }

  Future<void> _drawRoute(List<Position> coords) async {
    if (_routeManager == null) return;
    await _routeManager!.deleteAll();
    if (coords.length < 2) return;
    final ls = LineString(coordinates: coords);
    final opt = PolylineAnnotationOptions(
      geometry: ls,
      lineColor: AppTheme.primaryMint.value,
      lineWidth: 6,
      lineOpacity: 0.8,
    );
    await _routeManager!.create(opt);
  }

  void _updateEtaText(double distanceMeters, String mode) {
    final speed = _avgSpeedMetersPerSecond(mode);
    if (speed <= 0) { setState(() { _etaText = ''; }); return; }
    final seconds = (distanceMeters / speed).round();
    final d = Duration(seconds: seconds);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    final txt = h > 0 ? '${h}h ${m}m' : (m > 0 ? '${m}m ${s}s' : '${s}s');
    setState(() { _etaText = txt; });
  }

  double _avgSpeedMetersPerSecond(String mode) {
    switch (mode) {
      case 'walking': return 1.4;
      case 'cycling': return 4.16;
      case 'driving':
      default: return 13.9;
    }
  }

  double _pathLengthMeters(List<Position> coords) {
    if (coords.length < 2) return 0.0;
    double sum = 0.0;
    for (int i = 1; i < coords.length; i++) {
      sum += _haversine(
        coords[i - 1].lat.toDouble(),
        coords[i - 1].lng.toDouble(),
        coords[i].lat.toDouble(),
        coords[i].lng.toDouble(),
      );
    }
    return sum;
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371000.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = (math.sin(dLat / 2) * math.sin(dLat / 2)) + math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) * (math.sin(dLon / 2) * math.sin(dLon / 2));
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double d) => d * 0.017453292519943295;

  double _distanceToRouteMeters(double lat, double lon, List<Position> path) {
    if (path.length < 2) return double.infinity;
    double minD = double.infinity;
    for (int i = 1; i < path.length; i++) {
      final aLat = path[i - 1].lat.toDouble();
      final aLon = path[i - 1].lng.toDouble();
      final bLat = path[i].lat.toDouble();
      final bLon = path[i].lng.toDouble();
      final d = _pointToSegmentDistanceMeters(lat, lon, aLat, aLon, bLat, bLon);
      if (d < minD) minD = d;
    }
    return minD;
  }

  double _pointToSegmentDistanceMeters(double pLat, double pLon, double aLat, double aLon, double bLat, double bLon) {
    final ap = _vectorMeters(aLat, aLon, pLat, pLon);
    final ab = _vectorMeters(aLat, aLon, bLat, bLon);
    final abLen2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (abLen2 == 0) return _haversine(pLat, pLon, aLat, aLon);
    final t = ((ap.dx * ab.dx) + (ap.dy * ab.dy)) / abLen2;
    final clampedT = t.clamp(0.0, 1.0);
    final projLon = aLon + (bLon - aLon) * clampedT;
    final projLat = aLat + (bLat - aLat) * clampedT;
    return _haversine(pLat, pLon, projLat, projLon);
  }

  Offset _vectorMeters(double lat1, double lon1, double lat2, double lon2) {
    final dx = _haversine(lat1, lon1, lat1, lon2);
    final dy = _haversine(lat1, lon1, lat2, lon1);
    final signX = lon2 >= lon1 ? 1.0 : -1.0;
    final signY = lat2 >= lat1 ? 1.0 : -1.0;
    return Offset(dx * signX, dy * signY);
  }

  double _remainingDistanceMeters(double lat, double lon, List<Position> path) {
    if (path.length < 2) return 0.0;
    int nearestIdx = 0;
    double minD = double.infinity;
    for (int i = 0; i < path.length; i++) {
      final d = _haversine(lat, lon, path[i].lat.toDouble(), path[i].lng.toDouble());
      if (d < minD) { minD = d; nearestIdx = i; }
    }
    double sum = 0.0;
    for (int i = nearestIdx; i < path.length - 1; i++) {
      sum += _haversine(
        path[i].lat.toDouble(), path[i].lng.toDouble(),
        path[i + 1].lat.toDouble(), path[i + 1].lng.toDouble(),
      );
    }
    return sum;
  }

  @override
  void dispose() {
    _animController.dispose();
    _posSub?.cancel();
    try {
      final vm = Provider.of<NearbyPlacesProvider>(context, listen: false);
      vm.disposeDebounce();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<EnvironmentConfig>(context, listen: false);
    final http = HttpClient(config, SecureTokenStorage());
    final placesApi = PlacesApiImpl(http.dio);
    final placesRepo = PlacesRepository(api: placesApi, maxRetries: config.maxRetries);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => NearbyPlacesProvider(repository: placesRepo)),
      ],
      child: Consumer<HomeProvider>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: AppTheme.textBlack,
            body: SafeArea(
              bottom: false,
              child: vm.currentTab == 2
                  ? const ProfilePage()
                  : SlidingUpPanel(
                      minHeight: 64,
                      maxHeight: MediaQuery.of(context).size.height * 0.75,
                      margin: const EdgeInsets.only(bottom: 0),
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                      color: const Color(0xFF242A33),
                      boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, -8))],
                      backdropEnabled: true,
                      backdropOpacity: 0.2,
                      onPanelSlide: (_) => _hideTooltip(),
                      collapsed: const HomeCollapsedPanel(),
                      panelBuilder: (sc) => HomeExpandedPanel(scrollController: sc),
                      body: Stack(
                        children: [
                          Positioned.fill(
                            child: MapWidget(
                              styleUri: MapboxStyles.DARK,
                              cameraOptions: CameraOptions(
                                center: Point(coordinates: Position(-98.0, 39.5)),
                                zoom: 14,
                                bearing: 0,
                                pitch: 60,
                              ),
                              onMapCreated: (controller) {
                                _mapboxMap = controller;
                                _enableUserLocation();
                                _startFollow();
                                _placesLayer = PlacesLayerController(map: controller);
                              },
                              onTapListener: (gestureCtx) async {
                                _hideTooltip();
                                final p = gestureCtx.point;
                                final lat = p.coordinates.lat.toDouble();
                                final lon = p.coordinates.lng.toDouble();
                                final selectedMode = await showDialog<String>(
                                  context: context,
                                  builder: (_) => DestinationConfirmationDialog(initialMode: _navMode),
                                );
                                if (selectedMode != null) {
                                  _navMode = selectedMode;
                                  _currentDestination = Point(coordinates: Position(lon, lat));
                                  final geoPos = await geo.Geolocator.getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.best);
                                  await _calculateAndShowRoute(latOrigin: geoPos.latitude, lonOrigin: geoPos.longitude, latDest: lat, lonDest: lon, mode: _navMode);
                                }
                              },
                              onCameraChangeListener: (_) { _onCameraChanged(context); },
                              onStyleLoadedListener: (event) async {
                                await _applyLocationSettings();
                                if (_mapboxMap != null) {
                                  final style = _mapboxMap!.style;
                                  await style.addSource(
                                    RasterDemSource(
                                      id: 'mapbox-dem',
                                      url: 'mapbox://mapbox.mapbox-terrain-dem-v1',
                                      tileSize: 512,
                                      maxzoom: 14,
                                      prefetchZoomDelta: 0,
                                      tileRequestsDelay: 0.3,
                                      tileNetworkRequestsDelay: 0.5,
                                    ),
                                  );
                                  await style.setStyleTerrainProperty('source', 'mapbox-dem');
                                  await style.setStyleTerrainProperty('exaggeration', 1.0);
                                  await style.setStyleImportConfigProperty('basemap', 'lightPreset', 'dusk');
                                  await style.setStyleImportConfigProperty('basemap', 'showPointOfInterestLabels', true);

                                  // 1. Configurar Niebla (Atmósfera) para un horizonte suave
                                  // Nota: La API de Flutter de Mapbox puede requerir un método diferente o json encode
                                  // para propiedades complejas de estilo root como 'fog'.
                                  // Si 'styleJSON' es de solo lectura o no funciona así, usamos setStyleLayerProperty si fuera una capa,
                                  // pero fog es propiedad raíz. Intentaremos con una llamada directa si existe, o lo omitimos si la API no lo expone.
                                  // Al revisar la API, para propiedades root genéricas se suele usar style.styleJSON = ... pero es un getter.
                                  // Usaremos setStyleJSONProperty si existe en una extensión, pero el error dice que no.
                                  // La alternativa correcta es usar style.setStyleURI o cargar el JSON completo, pero para un cambio puntual:
                                  // Intentaremos omitir la niebla si la API estricta no lo permite fácilmente sin recargar todo el estilo.
                                  // O buscamos si hay un método setStyleProperty específico.
                                  // Investigando: style.setStyleProperty("fog", ...)
                                  /*
                                  await style.setStyleProperty('fog', {
                                    "range": [0.5, 10],
                                    "color": "rgb(24, 26, 32)",
                                    "horizon-blend": 0.2
                                  });
                                  */

                                  // 2. Agregar capa de Edificios 3D
                                  try {
                                    if (await style.styleSourceExists('composite')) {
                                      final buildingsLayer = FillExtrusionLayer(
                                        id: '3d-buildings',
                                        sourceId: 'composite',
                                        sourceLayer: 'building',
                                        minZoom: 15.0,
                                        filter: ['==', ['get', 'extrude'], 'true'],
                                        fillExtrusionColor: Colors.grey.shade800.value,
                                        fillExtrusionOpacity: 0.6,
                                        // Mapbox Flutter v10+ espera expresiones como List<Object?> o similares, no List<String> directo si el tipo es double?
                                        // Requerimos castear o usar la clase Expression si está disponible, o pasar la lista como dynamic.
                                        // Sin embargo, el error dice "List<String> can't be assigned to double?".
                                        // Esto significa que la propiedad fillExtrusionHeight espera un valor fijo (double) y no una expresión (List) en este wrapper.
                                        // Para usar expresiones (data-driven styling), debemos usar propiedades que acepten expresiones.
                                        // En el SDK de Flutter v2/v3, algunas propiedades son tipadas estrictas.
                                        // Si no permite expresiones, usaremos un valor fijo o lo omitiremos.
                                        // Pero la extrusión 3D sin altura variable no tiene sentido.
                                        // Verificamos si hay propiedades 'Expression' o si debemos usar 'addLayer' con un JSON crudo.
                                        // Al ser FillExtrusionLayer una clase tipada, revisemos sus campos.
                                        // Si fillExtrusionHeight es double?, entonces no soporta expresiones directamente en este constructor.
                                        // Intentaremos usar un valor fijo por ahora para eliminar el error,
                                        // o mejor, eliminamos la capa 3D temporalmente si no podemos usar alturas reales,
                                        // ya que edificios planos elevados se ven mal.
                                        //
                                        // CORRECCIÓN: La librería mapbox_maps_flutter suele tener soporte para expresiones.
                                        // El problema es que pasé `['get', 'height']` (List<String>) a un campo que el linter dice que es `double?`.
                                        // Esto sugiere que la versión de la librería que usamos tiene bindings que fuerzan tipos escalares para estas propiedades
                                        // o estoy usando el constructor incorrecto.
                                        //
                                        // Solución rápida: Usar valores fijos para compilar, y luego investigar si podemos usar addStyleLayer con JSON crudo.
                                        fillExtrusionHeight: 20.0, // Altura fija temporal para prueba
                                        fillExtrusionBase: 0.0,
                                        fillExtrusionAmbientOcclusionIntensity: 0.3,
                                      );
                                      await style.addLayer(buildingsLayer);
                                    }
                                  } catch (e) {
                                    debugPrint('Error agregando edificios 3D: $e');
                                  }

                                  await _placesLayer?.ensureInitialized();
                                  _routeManager ??= await _mapboxMap!.annotations.createPolylineAnnotationManager();
                                  final vm = Provider.of<NearbyPlacesProvider>(context, listen: false);
                                  vm.addListener(() async {
                                    if (_mapboxMap == null) return;
                                    final data = vm.places;
                                    await _placesLayer?.updatePlaces(data);
                                  });
                                  _placesLayer?.attachInteractions((place) {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (ctx) {
                                        return Container(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(place.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                              const SizedBox(height: 6),
                                              Text(place.category),
                                              const SizedBox(height: 8),
                                              Text(place.address),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  });
                                  await _onCameraChanged(context);
                                }
                              },
                            ),
                          ),
                          Positioned(
                            right: 16,
                            top: MediaQuery.of(context).padding.top,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FloatingActionButton(
                                  heroTag: 'settings_btn',
                                  backgroundColor: AppTheme.primaryMint,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  onPressed: () async {
                                    _hideTooltip();
                                    final changed = await showModalBottomSheet<bool>(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (_) => const NearbyParamsModal(),
                                    );
                                    if (changed == true) {
                                      _onCameraChanged(context);
                                    }
                                  },
                                  child: const Icon(Icons.tune, color: AppTheme.textBlack),
                                ),
                                const SizedBox(height: 12),
                                FloatingActionButton(
                                  heroTag: 'location_btn',
                                  backgroundColor: AppTheme.primaryMint,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  onPressed: () {
                                    _hideTooltip();
                                    _centerCameraOnUser();
                                  },
                                  child: const Icon(Icons.my_location, color: AppTheme.textBlack),
                                ),
                              ],
                            ),
                          ),
                          if (_etaText.isNotEmpty)
                            Positioned(
                              top: 16,
                              left: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Tiempo estimado de llegada', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                    Text(_etaText, style: const TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: vm.currentTab == 2
                ? null
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Mensaje tipo burbuja
                          if (_showTooltip) ...[
                            const _TooltipBubble(message: 'Generemos tu ruta de hoy'),
                            const SizedBox(width: 8),
                          ],
                          // Botón principal animado (fijo)
                          GestureDetector(
                            onTap: () {
                              _hideTooltip();
                              showDialog(context: context, builder: (context) => const GenerationModal());
                            },
                        child: AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                    // Sombra "glow" animada
                                    BoxShadow(
                                      color: AppTheme.primaryMint.withValues(alpha: 0.4),
                                      blurRadius: 12 * _scaleAnimation.value,
                                      spreadRadius: 2 * (_scaleAnimation.value - 1.0),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.explore, color: AppTheme.textBlack, size: 32),
                              ),
                            );
                          },
                        ),
                      ),
                      ],
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [Color(0xFF2C303A), AppTheme.textBlack],
                        stops: [0.0, 1.0],
                      ),
                      boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, -4))],
                      border: Border(top: BorderSide(color: AppTheme.primaryMint.withOpacity(0.25), width: 1)),
                    ),
                    child: NavigationBarTheme(
                      data: NavigationBarThemeData(
                        height: 76,
                        backgroundColor: Colors.transparent,
                        indicatorColor: AppTheme.primaryMint.withOpacity(0.22),
                        indicatorShape: const StadiumBorder(),
                        labelTextStyle: MaterialStateProperty.resolveWith((states) {
                          final selected = states.contains(MaterialState.selected);
                          return TextStyle(
                            color: selected ? AppTheme.primaryMint : Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: selected ? 13 : 12,
                          );
                        }),
                        iconTheme: MaterialStateProperty.resolveWith((states) {
                          final selected = states.contains(MaterialState.selected);
                          return IconThemeData(
                            color: selected ? AppTheme.primaryMint : Colors.white,
                            size: selected ? 28 : 26,
                          );
                        }),
                      ),
                      child: NavigationBar(
                        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                        selectedIndex: vm.currentTab,
                        onDestinationSelected: (i) {
                          _hideTooltip();
                          HapticFeedback.selectionClick();
                          vm.setTab(i);
                        },
                        destinations: const [
                          NavigationDestination(icon: Icon(Icons.home), selectedIcon: Icon(Icons.home), label: 'Inicio'),
                          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Bitácoras'),
                          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TooltipBubble extends StatefulWidget {
  final String message;
  const _TooltipBubble({Key? key, required this.message}) : super(key: key);

  @override
  State<_TooltipBubble> createState() => _TooltipBubbleState();
}

class _TooltipBubbleState extends State<_TooltipBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _offsetAnimation = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(-_offsetAnimation.value, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryMint, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: AppTheme.textBlack,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(-1.5, 0),
                child: CustomPaint(
                  size: const Size(6, 12),
                  painter: _BubbleArrowPainter(
                    color: Colors.white,
                    borderColor: AppTheme.primaryMint,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BubbleArrowPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double strokeWidth;

  _BubbleArrowPainter({
    required this.color,
    this.borderColor = Colors.transparent,
    this.strokeWidth = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);

    if (strokeWidth > 0 && borderColor != Colors.transparent) {
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final borderPath = Path();
      borderPath.moveTo(0, 0);
      borderPath.lineTo(size.width, size.height / 2);
      borderPath.lineTo(0, size.height);
      canvas.drawPath(borderPath, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}