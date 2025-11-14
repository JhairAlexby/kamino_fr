import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'dart:async';
import 'package:kamino_fr/core/app_theme.dart';
import '../provider/home_provider.dart';
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

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
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
                      },
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
                        }
                      },
                    ),
                  ),
                  Positioned(
                    right: 24,
                    bottom: 60,
                    child: FloatingActionButton(
                      backgroundColor: AppTheme.primaryMint,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onPressed: _centerCameraOnUser,
                      child: Icon(
                        Icons.my_location,
                        color: AppTheme.textBlack,
                      ),
                    ),
                  ),
                  
                  // Botón circular flotante (interés/sugerencias)
                  Positioned(
                    right: 24,
                    bottom: 120,
                    child: FloatingActionButton(
                      backgroundColor: AppTheme.primaryMint,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const GenerationModal(),
                        );
                      },
                      child: Icon(
                        Icons.explore,
                        color: AppTheme.textBlack,
                      ),
                    ),
                  ),
                ],
              ),
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

 

 
