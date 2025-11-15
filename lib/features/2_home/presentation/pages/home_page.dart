import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'dart:async';
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

  Future<void> _applyLocationSettings() async {
    if (_mapboxMap == null) return;
    await _mapboxMap!.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        puckBearingEnabled: true,
        showAccuracyRing: true,
        locationPuck: LocationPuck(),
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
    });
  }

  Future<void> _onCameraChanged(BuildContext ctx) async {
    if (_mapboxMap == null) return;
    final vm = Provider.of<NearbyPlacesProvider>(ctx, listen: false);
    final camera = await _mapboxMap!.getCameraState();
    final center = camera.center?.coordinates;
    if (center == null) return;
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
                          final vm = Provider.of<NearbyPlacesProvider>(context, listen: false);
                          vm.addListener(() async {
                            if (_mapboxMap == null) return;
                            final data = vm.places;
                            await _placesLayer?.updatePlaces(data);
                          });
                          await _onCameraChanged(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: Column(
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
            bottomNavigationBar: NavigationBarTheme(
              data: NavigationBarThemeData(
                height: 76,
                backgroundColor: AppTheme.lightMintBackground,
                indicatorColor: AppTheme.primaryMint.withValues(alpha: 0.20),
                labelTextStyle: MaterialStateProperty.resolveWith((states) {
                  final selected = states.contains(MaterialState.selected);
                  return TextStyle(
                    color: selected
                        ? AppTheme.primaryMint
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: selected ? 13 : 12,
                    fontWeight: FontWeight.w600,
                  );
                }),
                iconTheme: MaterialStateProperty.resolveWith((states) {
                  final selected = states.contains(MaterialState.selected);
                  return IconThemeData(
                    color: selected
                        ? AppTheme.primaryMint
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    size: selected ? 28 : 26,
                  );
                }),
              ),
              child: NavigationBar(
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                selectedIndex: vm.currentTab,
                onDestinationSelected: vm.setTab,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home),
                    selectedIcon: Icon(Icons.home),
                    label: 'Inicio',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book),
                    label: 'Bitácoras',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Perfil',
                  ),
                ],
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

 

 
