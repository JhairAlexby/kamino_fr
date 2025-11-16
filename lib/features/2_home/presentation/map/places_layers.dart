import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../data/models/place.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class PlacesLayerController {
  final MapboxMap map;
  CircleAnnotationManager? _circleManager;
  PointAnnotationManager? _pointManager;
  final Map<String, Place> _annToPlace = {};
  Uint8List? _markerBytes;

  PlacesLayerController({required this.map});

  Future<void> ensureInitialized() async {
    if (_pointManager == null && _circleManager == null) {
      try {
        _markerBytes = await _loadMarkerBytes('assets/images/marker.png');
        _pointManager = await map.annotations.createPointAnnotationManager();
      } catch (_) {
        _circleManager = await map.annotations.createCircleAnnotationManager();
      }
    }
  }

  Future<Uint8List> _loadMarkerBytes(String assetPath) async {
    final bd = await rootBundle.load(assetPath);
    return bd.buffer.asUint8List();
  }

  Future<void> updatePlaces(List<Place> places) async {
    _annToPlace.clear();
    if (_pointManager != null && _markerBytes != null) {
      await _pointManager!.deleteAll();
      final options = <PointAnnotationOptions>[];
      for (final p in places) {
        options.add(
          PointAnnotationOptions(
            geometry: Point(coordinates: Position(p.longitude, p.latitude)),
            image: _markerBytes!,
            iconSize: 1.0,
          ),
        );
      }
      if (options.isNotEmpty) {
        final anns = await _pointManager!.createMulti(options);
        for (int i = 0; i < anns.length && i < places.length; i++) {
          final ann = anns[i];
          final plc = places[i];
          if (ann != null) _annToPlace[ann.id] = plc;
        }
      }
      return;
    }
    if (_circleManager != null) {
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
        final anns = await _circleManager!.createMulti(options);
        for (int i = 0; i < anns.length && i < places.length; i++) {
          final ann = anns[i];
          final plc = places[i];
          if (ann != null) _annToPlace[ann.id] = plc;
        }
      }
    }
  }

  void attachInteractions(void Function(Place place) onTap) {
    if (_pointManager != null) {
      _pointManager!.tapEvents(onTap: (annotation) {
        final plc = _annToPlace[annotation.id];
        if (plc != null) onTap(plc);
      });
    }
    if (_circleManager != null) {
      _circleManager!.tapEvents(onTap: (annotation) {
        final plc = _annToPlace[annotation.id];
        if (plc != null) onTap(plc);
      });
    }
  }
}