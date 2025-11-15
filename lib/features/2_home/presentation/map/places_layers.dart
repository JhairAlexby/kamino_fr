import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../data/models/place.dart';

class PlacesLayerController {
  final MapboxMap map;
  CircleAnnotationManager? _circleManager;

  PlacesLayerController({required this.map});

  Future<void> ensureInitialized() async {
    if (_circleManager != null) return;
    _circleManager = await map.annotations.createCircleAnnotationManager();
  }

  Future<void> updatePlaces(List<Place> places) async {
    if (_circleManager == null) return;
    await _circleManager!.deleteAll();
    final options = <CircleAnnotationOptions>[];
    for (final p in places) {
      options.add(
        CircleAnnotationOptions(
          geometry: Point(coordinates: Position(p.longitude, p.latitude)),
          circleColor: Colors.red.value,
          circleRadius: 8.0,
          circleStrokeColor: Colors.white.value,
          circleStrokeWidth: 2.0,
        ),
      );
    }
    if (options.isNotEmpty) {
      await _circleManager!.createMulti(options);
    }
  }
}