import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' show ImageFilter;
import 'package:flutter/services.dart' show rootBundle, HapticFeedback;
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
import 'package:kamino_fr/features/3_profile/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
  Future<void> _openNearbyParams(BuildContext ctx) async {
    final vm = Provider.of<NearbyPlacesProvider>(ctx, listen: false);
    final radiusCtrl = TextEditingController(text: vm.manualRadius.toString());
    final limitCtrl = TextEditingController(text: vm.manualLimit.toString());
    bool useManual = vm.useManual;
    await showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Usar parámetros manuales'),
                    Switch(
                      value: useManual,
                      onChanged: (v) {
                        setState(() { useManual = v; });
                      },
                    ),
                  ],
                ),
                TextField(
                  controller: radiusCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Radio (km)'),
                ),
                TextField(
                  controller: limitCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Límite (lugares)'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    final r = double.tryParse(radiusCtrl.text) ?? vm.manualRadius;
                    final l = int.tryParse(limitCtrl.text) ?? vm.manualLimit;
                    vm.setManualParams(useManual: useManual, radius: r, limit: l);
                    Navigator.of(sheetCtx).pop();
                    _onCameraChanged(ctx);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ),
        );
      },
    );
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

  Future<void> _confirmDestination(BuildContext ctx, double lat, double lon) async {
    String selectedMode = _navMode;
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (dCtx) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¿Deseas ir a esta ubicación?'),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Modo: '),
                  const SizedBox(width: 8),
                  StatefulBuilder(
                    builder: (c, setState) {
                      return DropdownButton<String>(
                        value: selectedMode,
                        items: const [
                          DropdownMenuItem(value: 'driving', child: Text('Conducción')),
                          DropdownMenuItem(value: 'walking', child: Text('Caminando')),
                          DropdownMenuItem(value: 'cycling', child: Text('Bicicleta')),
                        ],
                        onChanged: (v) { if (v != null) { setState(() { selectedMode = v; }); } },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () { Navigator.of(dCtx).pop(false); }, child: const Text('Cancelar')),
            ElevatedButton(onPressed: () { Navigator.of(dCtx).pop(true); }, child: const Text('Ir')),
          ],
        );
      },
    );
    if (ok == true) {
      _navMode = selectedMode;
      _currentDestination = Point(coordinates: Position(lon, lat));
      final geoPos = await geo.Geolocator.getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.best);
      await _calculateAndShowRoute(latOrigin: geoPos.latitude, lonOrigin: geoPos.longitude, latDest: lat, lonDest: lon, mode: _navMode);
    }
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
      lineColor: Colors.cyan.value,
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
                  ? const _ProfileContentWrapper()
                  : Stack(
                children: [
                  Positioned.fill(
                    child: MapWidget(
                      styleUri: MapboxStyles.STANDARD,
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
                        final p = gestureCtx.point;
                        if (p == null) return;
                        final lat = p.coordinates.lat.toDouble();
                        final lon = p.coordinates.lng.toDouble();
                        await _confirmDestination(context, lat, lon);
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
                  if (_etaText.isNotEmpty)
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
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
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: vm.currentTab == 2
                ? null
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        backgroundColor: AppTheme.primaryMint,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onPressed: () => _openNearbyParams(context),
                        child: Icon(Icons.tune, color: AppTheme.textBlack),
                      ),
                      const SizedBox(height: 12),
                      FloatingActionButton(
                        backgroundColor: AppTheme.primaryMint,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onPressed: () {
                          showDialog(context: context, builder: (context) => const GenerationModal());
                        },
                        child: Icon(Icons.explore, color: AppTheme.textBlack),
                      ),
                      const SizedBox(height: 12),
                      FloatingActionButton(
                        backgroundColor: AppTheme.primaryMint,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onPressed: _centerCameraOnUser,
                        child: Icon(Icons.my_location, color: AppTheme.textBlack),
                      ),
                    ],
                  ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [Color(0xFF2C303A), AppTheme.textBlack],
                        stops: [0.0, 1.0],
                      ),
                      boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, -4))],
                    ),
                    child: NavigationBarTheme(
                      data: NavigationBarThemeData(
                        height: 76,
                        backgroundColor: Colors.transparent,
                        indicatorColor: AppTheme.primaryMint.withValues(alpha: 0.22),
                        indicatorShape: const StadiumBorder(),
                        labelTextStyle: MaterialStateProperty.resolveWith((states) {
                          final selected = states.contains(MaterialState.selected);
                          return TextStyle(
                            color: AppTheme.primaryMint.withValues(alpha: selected ? 1.0 : 0.65),
                            fontWeight: FontWeight.w700,
                            fontSize: selected ? 13 : 12,
                          );
                        }),
                        iconTheme: MaterialStateProperty.resolveWith((states) {
                          final selected = states.contains(MaterialState.selected);
                          return IconThemeData(
                            color: AppTheme.primaryMint.withValues(alpha: selected ? 1.0 : 0.65),
                            size: selected ? 28 : 26,
                          );
                        }),
                      ),
                      child: NavigationBar(
                        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                        selectedIndex: vm.currentTab,
                        onDestinationSelected: (i) {
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

class _ProfileContentWrapper extends StatelessWidget {
  const _ProfileContentWrapper();
  @override
  Widget build(BuildContext context) {
    return const ProfilePage();
  }
}

 

 
