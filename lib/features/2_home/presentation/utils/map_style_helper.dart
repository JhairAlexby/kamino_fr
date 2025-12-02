import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapStyleHelper {
  static Future<void> configureMapStyle(MapboxMap mapboxMap) async {
    final style = mapboxMap.style;

    // 1. Terrain & Atmosphere
    try {
      if (!await style.styleSourceExists('mapbox-dem')) {
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
      }
      await style.setStyleTerrainProperty('source', 'mapbox-dem');
      await style.setStyleTerrainProperty('exaggeration', 1.0);
      
      // Basemap configuration
      await style.setStyleImportConfigProperty('basemap', 'lightPreset', 'dusk');
      await style.setStyleImportConfigProperty('basemap', 'showPointOfInterestLabels', true);
    } catch (e) {
      debugPrint('Error configuring terrain/atmosphere: $e');
    }

    // 2. 3D Buildings
    try {
      if (await style.styleSourceExists('composite')) {
        // Check if layer already exists to avoid duplicate error
        if (!await style.styleLayerExists('3d-buildings')) {
           final buildingsLayer = FillExtrusionLayer(
            id: '3d-buildings',
            sourceId: 'composite',
            sourceLayer: 'building',
            minZoom: 15.0,
            filter: ['==', ['get', 'extrude'], 'true'],
            fillExtrusionColor: Colors.grey.shade800.value,
            fillExtrusionOpacity: 0.6,
            fillExtrusionHeight: 20.0, 
            fillExtrusionBase: 0.0,
            fillExtrusionAmbientOcclusionIntensity: 0.3,
          );
          await style.addLayer(buildingsLayer);
        }
      }
    } catch (e) {
      debugPrint('Error adding 3D buildings: $e');
    }
  }
}