import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' show ImageFilter, Path, Paint, Canvas;
import 'package:flutter/services.dart' show rootBundle, HapticFeedback;
import 'dart:math' as math;
import 'package:kamino_fr/core/app_theme.dart';
import '../provider/home_provider.dart';
import 'package:kamino_fr/config/environment_config.dart';
import 'package:kamino_fr/core/auth/token_storage.dart';
import 'package:kamino_fr/core/network/http_client.dart';
import 'package:kamino_fr/features/2_home/data/places_api.dart';
import 'package:kamino_fr/features/2_home/data/places_repository.dart';
import 'package:kamino_fr/features/2_home/data/navigation_repository.dart';
import 'package:kamino_fr/features/4_routes/presentation/pages/my_routes_page.dart';
import 'package:kamino_fr/features/2_home/presentation/provider/nearby_places_provider.dart';
import 'package:kamino_fr/features/2_home/presentation/provider/navigation_provider.dart';
import 'package:kamino_fr/features/2_home/presentation/map/places_layers.dart';
import 'package:kamino_fr/features/2_home/data/models/place.dart';
import '../widgets/generation_modal.dart';
import '../widgets/place_preview_modal.dart'; 
import 'package:kamino_fr/features/2_home/presentation/widgets/home_floating_buttons.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/eta_indicator.dart';
import 'package:kamino_fr/features/2_home/presentation/utils/map_style_helper.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/route_generation_overlay.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/destination_confirmation_dialog.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/home_sliding_panel.dart';
import 'package:kamino_fr/features/3_profile/presentation/pages/profile_page.dart';
import 'package:kamino_fr/core/utils/app_animations.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../widgets/place_info_modal.dart'; // Usamos el existente

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  MapboxMap? _mapboxMap;
  StreamSubscription<geo.Position>? _posSub;
  final bool _followUser = true;
  DateTime? _lastCameraUpdate;
  PlacesLayerController? _placesLayer;
  Uint8List? _userMarkerBytes;
  PolylineAnnotationManager? _routeManager;
  
  double _userSpeed = 0.0;
  
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

  void _startFollow(NavigationProvider navProvider) {
    _posSub?.cancel();
    _posSub = geo.Geolocator.getPositionStream(locationSettings: const geo.LocationSettings(accuracy: geo.LocationAccuracy.best, distanceFilter: 10))
        .listen((geoPos) async {
      if (!_followUser) return;
      final now = DateTime.now();
      if (_lastCameraUpdate != null && now.difference(_lastCameraUpdate!).inMilliseconds < 1000) return;
      _lastCameraUpdate = now;
      final pos = Position(geoPos.longitude, geoPos.latitude);
      await _mapboxMap?.setCamera(CameraOptions(center: Point(coordinates: pos)));
      _userSpeed = geoPos.speed;
      
      // Actualizar ETA si hay ruta activa
      if (navProvider.routeCoords.isNotEmpty) {
        final remaining = navProvider.remainingDistanceMeters(geoPos.latitude, geoPos.longitude);
        navProvider.updateEta(remaining, _userSpeed);
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

  void _simulatePlaceSelection({double? lat, double? lon}) {
    final mockPlace = Place(
      id: 'sim-1',
      name: 'Destino Seleccionado',
      description: 'Ubicación seleccionada manualmente en el mapa. Un lugar perfecto para explorar.',
      category: 'Ubicación Personalizada',
      tags: ['Explorar', 'Aventura'],
      latitude: lat ?? 19.412, 
      longitude: lon ?? -99.169,
      address: 'Coordenadas: ${lat?.toStringAsFixed(4)}, ${lon?.toStringAsFixed(4)}',
      imageUrl: 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0c/f2/eb/63/parque-mexico.jpg?w=1200&h=-1&s=1',
      isHiddenGem: false,
      openingTime: '06:00',
      closingTime: '23:00',
      tourDuration: 45,
      narrativeStoreId: null,
      narrativeDocumentId: null,
      hasNarrative: false,
      closedDays: const [],
      scheduleByDay: const {},
      crowdInfo: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      distance: 0.5,
    );
    final navVm = Provider.of<NavigationProvider>(context, listen: false);
    AppAnimations.showFluidModalBottomSheet(
      context: context,
      builder: (ctx) => PlacePreviewModal(
        place: mockPlace,
        onNavigate: () => _handlePlaceSelectionWithNav(navVm, mockPlace, ctx),
        onChat: () => _handleChat(mockPlace),
        onDetails: () => _handleDetails(mockPlace),
      ),
    );
  }

  // Nuevos métodos para manejar las acciones del modal
  Future<void> _handlePlaceSelection(Place place, BuildContext ctx) async {
    _hideTooltip();
    final lat = place.latitude;
    final lon = place.longitude;
    
    final navVm = Provider.of<NavigationProvider>(ctx, listen: false);
    final geoPos = await geo.Geolocator.getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.best);
    _userSpeed = geoPos.speed;
    
    Navigator.of(ctx).pop(); // Cerrar el modal
    
    await navVm.calculateRoute(
      latOrigin: geoPos.latitude, 
      lonOrigin: geoPos.longitude, 
      latDest: lat, 
      lonDest: lon, 
      currentSpeed: _userSpeed,
      showOverlay: false,
      destinationName: place.name, // Nombre del destino para la UI
    );
    if (navVm.routeCoords.isNotEmpty) {
      await _fitCameraToRoute(navVm.routeCoords);
      await _drawRoute(navVm.routeCoords);
    }
  }

  Future<void> _handlePlaceSelectionWithNav(NavigationProvider navVm, Place place, BuildContext ctx) async {
    _hideTooltip();
    final lat = place.latitude;
    final lon = place.longitude;
    final geoPos = await geo.Geolocator.getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.best);
    _userSpeed = geoPos.speed;
    Navigator.of(ctx).pop();
    await navVm.calculateRoute(
      latOrigin: geoPos.latitude,
      lonOrigin: geoPos.longitude,
      latDest: lat,
      lonDest: lon,
      currentSpeed: _userSpeed,
      showOverlay: false,
      destinationName: place.name,
    );
    if (navVm.routeCoords.isNotEmpty) {
      await _fitCameraToRoute(navVm.routeCoords);
      await _drawRoute(navVm.routeCoords);
    }
  }

  void _handleChat(Place place) {
    Navigator.of(context).pop();
    // TODO: Conectar con el módulo de chat
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chat con ${place.name} próximamente')),
    );
  }

  void _handleDetails(Place place) {
    Navigator.of(context).pop();
    // Usamos showDialog con PlaceInfoModal como en la confirmación de ruta
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => PlaceInfoModal(
        destinationName: place.name,
        imageUrl: place.imageUrl, // Pasamos datos reales
        description: place.description,
      ),
    );
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
  
  Future<void> _fitCameraToRoute(List<Position> coords) async {
    if (_mapboxMap == null || coords.length < 2) return;
    double minLat = coords.first.lat.toDouble();
    double maxLat = minLat;
    double minLon = coords.first.lng.toDouble();
    double maxLon = minLon;
    for (final p in coords) {
      final la = p.lat.toDouble();
      final lo = p.lng.toDouble();
      if (la < minLat) minLat = la;
      if (la > maxLat) maxLat = la;
      if (lo < minLon) minLon = lo;
      if (lo > maxLon) maxLon = lo;
    }
    final centerLat = (minLat + maxLat) / 2.0;
    final centerLon = (minLon + maxLon) / 2.0;
    final diagonalMeters = geo.Geolocator.distanceBetween(minLat, minLon, maxLat, maxLon);
    double zoom;
    if (diagonalMeters < 500) {
      zoom = 16;
    } else if (diagonalMeters < 1500) {
      zoom = 14.5;
    } else if (diagonalMeters < 5000) {
      zoom = 13;
    } else if (diagonalMeters < 15000) {
      zoom = 12;
    } else {
      zoom = 10.5;
    }
    await _mapboxMap!.setCamera(
      CameraOptions(center: Point(coordinates: Position(centerLon, centerLat)), zoom: zoom),
    );
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
    final navRepo = NavigationRepository(http.dio, config.mapboxAccessToken);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => NearbyPlacesProvider(repository: placesRepo)),
        ChangeNotifierProvider(create: (_) => NavigationProvider(navRepo)),
      ],
      child: Consumer2<HomeProvider, NavigationProvider>(
        builder: (context, vm, navVm, child) {
          // Listener para dibujar la ruta cuando cambie en el provider
          if (navVm.routeCoords.isNotEmpty && _mapboxMap != null) {
            _drawRoute(navVm.routeCoords);
          }
          
          return Scaffold(
            backgroundColor: AppTheme.textBlack,
            body: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  // Capa Principal (Mapa + Panel)
                  // Usamos Offstage para mantener el mapa vivo en memoria y evitar el crash al destruirlo/recrearlo
                  Offstage(
                    offstage: vm.currentTab != 0,
                    child: SlidingUpPanel(
                      key: const ValueKey('home_panel'),
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
                        alignment: Alignment.center,
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
                                _startFollow(navVm);
                                _placesLayer = PlacesLayerController(map: controller);
                                controller.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
                                try {
                                  controller.compass.updateSettings(CompassSettings(enabled: false));
                                } catch (_) {}
                              },
                              onTapListener: (gestureCtx) async {
                                _hideTooltip();
                                final p = gestureCtx.point;
                                final lat = p.coordinates.lat.toDouble();
                                final lon = p.coordinates.lng.toDouble();
                                
                                // Simular selección de lugar en las coordenadas tocadas
                                _simulatePlaceSelection(lat: lat, lon: lon);
                              },
                              onCameraChangeListener: (_) { _onCameraChanged(context); },
                              onStyleLoadedListener: (event) async {
                                await _applyLocationSettings();
                                if (_mapboxMap != null) {
                                  await MapStyleHelper.configureMapStyle(_mapboxMap!);

                                  await _placesLayer?.ensureInitialized();
                                  _routeManager ??= await _mapboxMap!.annotations.createPolylineAnnotationManager();
                                  final vm = Provider.of<NearbyPlacesProvider>(context, listen: false);
                                  vm.addListener(() async {
                                    if (_mapboxMap == null) return;
                                    final data = vm.places;
                                    await _placesLayer?.updatePlaces(data);
                                  });
                                  final navVmLocal = Provider.of<NavigationProvider>(context, listen: false);
                                  _placesLayer?.attachInteractions((place) {
                                    AppAnimations.showFluidModalBottomSheet(
                                      context: context,
                                      builder: (ctx) => PlacePreviewModal(
                                        place: place,
                                        onNavigate: () => _handlePlaceSelectionWithNav(navVmLocal, place, ctx),
                                        onChat: () => _handleChat(place),
                                        onDetails: () => _handleDetails(place),
                                      ),
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
                            child: HomeFloatingButtons(
                              onHideTooltip: _hideTooltip,
                              onCenterCamera: () => _centerCameraOnUser(),
                              onCameraChanged: (ctx) => _onCameraChanged(ctx),
                            ),
                          ),
                          RouteGenerationOverlay(isVisible: navVm.isGeneratingRouteOverlay),
                        ],
                      ),
                    ),
                  ),
                  
                  // Capa de Perfil (Animada)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutBack,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                        child: child,
                      ),
                    ),
                    child: vm.currentTab == 2
                        ? const ProfilePage(key: ValueKey('profile'))
                        : vm.currentTab == 1
                            ? const MyRoutesPage(key: ValueKey('my_routes'))
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutBack,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: vm.currentTab != 0
                  ? const SizedBox.shrink(key: ValueKey('empty_fab'))
                  : Column(
                      key: const ValueKey('home_fab'),
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      EtaIndicator(
                        etaText: navVm.etaText,
                        navMode: navVm.navMode,
                      ),
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
                            onTap: () async {
                              _hideTooltip();
                              final confirmed = await AppAnimations.showFluidDialog<bool>(
                                context: context,
                                builder: (context) => const GenerationModal(),
                              );
                              if (confirmed == true) {
                                bool keepSearching = true;
                                while (keepSearching && mounted) {
                                  try {
                                    final geoPos = await geo.Geolocator.getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.best);
                                    
                                    // Simulación: Destino "sorpresa" generado por la IA
                                    // Generamos un offset aleatorio para simular diferentes destinos
                                    final random = math.Random();
                                    final latOffset = (random.nextDouble() * 0.02 - 0.01); // +/- 0.01 grados (~1km)
                                    final lonOffset = (random.nextDouble() * 0.02 - 0.01);
                                    
                                    final destLat = geoPos.latitude + (latOffset.abs() < 0.002 ? 0.005 : latOffset);
                                    final destLon = geoPos.longitude + (lonOffset.abs() < 0.002 ? 0.005 : lonOffset);
                                    
                                    await navVm.calculateRoute(
                                      latOrigin: geoPos.latitude,
                                      lonOrigin: geoPos.longitude,
                                      latDest: destLat,
                                      lonDest: destLon,
                                      currentSpeed: geoPos.speed,
                                      showOverlay: true, // Activa la animación de "Generando Ruta"
                                      destinationName: "Destino Sorpresa"
                                    );

                                    if (navVm.routeCoords.isNotEmpty && mounted) {
                                      final selectedMode = await showDialog<String>(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (ctx) => DestinationConfirmationDialog(
                                          initialMode: navVm.navMode,
                                          destinationName: navVm.destinationName ?? 'Destino',
                                          distance: navVm.distanceText,
                                          duration: navVm.etaText,
                                        ),
                                      );

                                      if (selectedMode == 'regenerate') {
                                        // El usuario quiere otra opción, el bucle continúa
                                        keepSearching = true;
                                        navVm.clearRoute();
                                      } else if (selectedMode != null) {
                                        // Usuario confirmó
                                        keepSearching = false;
                                        // Si cambió el modo, recalculamos (opcional, o solo actualizamos estado)
                                        if (selectedMode != navVm.navMode) {
                                          await navVm.calculateRoute(
                                            latOrigin: geoPos.latitude,
                                            lonOrigin: geoPos.longitude,
                                            latDest: destLat,
                                            lonDest: destLon,
                                            currentSpeed: geoPos.speed,
                                            destinationName: "Destino Sorpresa",
                                            overrideMode: selectedMode,
                                          );
                                        }
                                        // Aquí iniciaría la navegación real
                                      } else {
                                        // Usuario canceló (null)
                                        keepSearching = false;
                                        navVm.clearRoute();
                                      }
                                    } else {
                                      keepSearching = false;
                                    }
                                  } catch (e) {
                                    debugPrint("Error al iniciar ruta IA: $e");
                                    keepSearching = false;
                                  }
                                }
                              }
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
                          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Mis Rutas'),
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

// _PlaceSheetContent removed in favor of PlacePreviewModal

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
