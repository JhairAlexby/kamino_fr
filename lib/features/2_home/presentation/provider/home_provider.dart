import 'package:flutter/material.dart';
import 'package:kamino_fr/features/2_home/data/models/recommendation.dart';
import 'package:kamino_fr/features/2_home/data/recommender_repository.dart';

class HomeProvider extends ChangeNotifier {
  final RecommenderRepository recommenderRepository;
  HomeProvider({required this.recommenderRepository}) {
    loadRecommendations();
  }

  int currentTab = 0;

  List<Recommendation> _recommendations = [];
  bool _loadingRecommendations = false;
  String? _recommendationsError;

  List<Recommendation> _hiddenTop = [];
  List<Recommendation> _nonHidden = [];
  List<Recommendation> _topWeek = [];

  List<Recommendation> get recommendations => _recommendations;
  bool get loadingRecommendations => _loadingRecommendations;
  String? get recommendationsError => _recommendationsError;
  List<Recommendation> get hiddenTop => _hiddenTop;
  List<Recommendation> get nonHidden => _nonHidden;
  List<Recommendation> get topWeek => _topWeek;

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  void setTab(int index) {
    currentTab = index;
    notifyListeners();
  }

  Future<void> loadRecommendations() async {
    _loadingRecommendations = true;
    _recommendationsError = null;
    notifyListeners();
    try {
      final res = await recommenderRepository.getRecommendations();
      _recommendations = res.recommendations;
      _computeSlices();
    } catch (_) {
      _recommendationsError = 'No se pudieron cargar las recomendaciones';
    } finally {
      _loadingRecommendations = false;
      notifyListeners();
    }
  }

  void _computeSlices() {
    final recs = _recommendations;
    final hidden = recs.where((e) => e.isHiddenGem).toList()
      ..sort((a, b) => b.finalScore.compareTo(a.finalScore));
    _hiddenTop = hidden.take(10).toList();
    _nonHidden = recs.where((e) => !e.isHiddenGem).toList();
    final overall = [...recs]..sort((a, b) => b.finalScore.compareTo(a.finalScore));
    _topWeek = overall.take(10).toList();
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
