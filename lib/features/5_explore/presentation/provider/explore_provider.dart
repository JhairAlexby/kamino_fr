import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kamino_fr/features/2_home/data/models/place.dart';
import 'package:kamino_fr/features/2_home/data/places_repository.dart';

class ExploreProvider extends ChangeNotifier {
  final PlacesRepository repository;
  ExploreProvider({required this.repository});

  List<Place> _places = [];
  bool _loading = false;
  String? _error;
  Timer? _debounce;

  List<Place> get places => _places;
  bool get loading => _loading;
  String? get error => _error;

  // Filters
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void disposeDebounce() {
    _debounce?.cancel();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
    
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      loadPlaces();
    });
  }

  Future<void> loadPlaces() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await repository.findAll(
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
      _places = data;
    } catch (e) {
      _error = 'No se pudieron cargar los lugares';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}