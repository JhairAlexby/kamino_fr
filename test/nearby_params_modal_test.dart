import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/nearby_params_modal.dart';
import 'package:kamino_fr/features/2_home/presentation/provider/nearby_places_provider.dart';
import 'package:kamino_fr/features/2_home/data/places_repository.dart';
import 'package:kamino_fr/features/2_home/data/models/place.dart';
import 'package:kamino_fr/features/2_home/data/places_api.dart';

class _FakePlacesApi implements PlacesApi {
  @override
  Future<List<Place>> nearby({required double latitude, required double longitude, required double radius, int limit = 100}) async {
    return const [];
  }

  @override
  Future<List<Place>> findAll({
    String? search,
    String? category,
    List<String>? tags,
    double? latitude,
    double? longitude,
    double? radius,
    bool? isHiddenGem,
    String? sortBy,
    String? sortOrder,
  }) async {
    return const [];
  }
}

void main() {
  testWidgets('NearbyParamsModal construye y guarda sin ProviderNotFound', (tester) async {
    final repo = PlacesRepository(api: _FakePlacesApi());
    final provider = NearbyPlacesProvider(repository: repo);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<NearbyPlacesProvider>.value(
            value: provider,
          child: NearbyParamsModal(
            initialRadius: 5.0,
            initialLimit: 10,
            initialUseManual: false,
            onSave: ({required bool useManual, required double radius, required int limit}) {},
          ),
          ),
        ),
      ),
    );

    expect(find.text('Usar parámetros manuales'), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);

    // Solo verificamos construcción sin excepciones de ProviderNotFound.
  });
}
