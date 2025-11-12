import 'package:flutter/material.dart';

class RecommendationItem {
  final String title;
  final String category;
  final String distanceText;
  RecommendationItem({
    required this.title,
    required this.category,
    required this.distanceText,
  });
}

class HomeProvider extends ChangeNotifier {
  int currentTab = 0;

  final List<RecommendationItem> recommendations = [
    RecommendationItem(title: 'Café Central', category: 'Café', distanceText: '5 min'),
    RecommendationItem(title: 'Museo de Arte', category: 'Cultura', distanceText: '12 min'),
    RecommendationItem(title: 'Parque Norte', category: 'Naturaleza', distanceText: '8 min'),
  ];

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  void setTab(int index) {
    currentTab = index;
    notifyListeners();
  }

  void onInterestButtonPressed() {
    recommendations.insert(
      0,
      RecommendationItem(title: 'Restaurante La Plaza', category: 'Comida', distanceText: '10 min'),
    );
    notifyListeners();
  }

  void onSelect(RecommendationItem item) {
  }

  void onNavigateTo(RecommendationItem item) {
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