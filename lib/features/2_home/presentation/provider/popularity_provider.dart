import 'package:flutter/material.dart';
import '../../data/models/popularity_ranking.dart';
import '../../data/popularity_repository.dart';

class PopularityProvider extends ChangeNotifier {
  final PopularityRepository repository;
  PopularityProvider({required this.repository});

  bool _loading = false;
  String? _error;
  List<RankingItem> _top = const [];
  int _total = 0;

  bool get loading => _loading;
  String? get error => _error;
  List<RankingItem> get top => _top;
  int get total => _total;

  Future<void> loadRanking() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await repository.getRanking();
      _top = res.topPlaces;
      _total = res.totalPlaces;
    } catch (_) {
      _error = 'No se pudo cargar el ranking';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
