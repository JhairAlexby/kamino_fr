import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:kamino_fr/core/app_theme.dart';
import '../../data/models/place.dart';
 

class PlacesLayerController {
  final MapboxMap map;
  CircleAnnotationManager? _circleManager;
  PointAnnotationManager? _pointManager;
  final Map<String, Place> _annToPlace = {};

  PlacesLayerController({required this.map});

  Future<void> ensureInitialized() async {
    if (_pointManager == null) {
      try {
        _pointManager = await map.annotations.createPointAnnotationManager();
      } catch (_) {}
    }
    if (_circleManager == null) {
      try {
        _circleManager = await map.annotations.createCircleAnnotationManager();
      } catch (_) {}
    }
  }

  Future<void> updatePlaces(List<Place> places) async {
    _annToPlace.clear();
    // Círculos para distinguir visualmente
    if (_circleManager != null) {
      await _circleManager!.deleteAll();
      final circleOpts = <CircleAnnotationOptions>[];
      for (final p in places) {
        circleOpts.add(
          CircleAnnotationOptions(
            geometry: Point(coordinates: Position(p.longitude, p.latitude)),
            circleColor: AppTheme.primaryMint.toARGB32(),
            circleRadius: 8.0,
            circleStrokeColor: Colors.white.toARGB32(),
            circleStrokeWidth: 2.0,
          ),
        );
      }
      if (circleOpts.isNotEmpty) {
        final anns = await _circleManager!.createMulti(circleOpts);
        for (int i = 0; i < anns.length && i < places.length; i++) {
          final ann = anns[i];
          final plc = places[i];
          if (ann != null) _annToPlace[ann.id] = plc;
        }
      }
    }

    // Etiqueta de texto (sin ícono) usando PointAnnotation
    if (_pointManager != null) {
      await _pointManager!.deleteAll();
      final pointOpts = <PointAnnotationOptions>[];
      for (final p in places) {
        final opt = PointAnnotationOptions(
          geometry: Point(coordinates: Position(p.longitude, p.latitude)),
          textField: p.name,
          textColor: Colors.white.toARGB32(),
          textSize: 12.0,
          textHaloColor: AppTheme.textBlack.toARGB32(),
          textHaloWidth: 1.0,
          textOffset: [1.2, 0.0],
          textAnchor: TextAnchor.LEFT,
        );
        pointOpts.add(opt);
      }
      if (pointOpts.isNotEmpty) {
        final anns = await _pointManager!.createMulti(pointOpts);
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
