class RankingItem {
  final String placeId;
  final String name;
  final String category;
  final List<String> tags;
  final double predictedScore;
  final String interpretation;

  RankingItem({
    required this.placeId,
    required this.name,
    required this.category,
    required this.tags,
    required this.predictedScore,
    required this.interpretation,
  });

  factory RankingItem.fromJson(Map<String, dynamic> json) {
    return RankingItem(
      placeId: json['place_id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      predictedScore: (json['predicted_score'] as num).toDouble(),
      interpretation: json['interpretation'] as String,
    );
  }
}

class PopularityRankingResponse {
  final bool success;
  final int totalPlaces;
  final List<RankingItem> topPlaces;

  PopularityRankingResponse({
    required this.success,
    required this.totalPlaces,
    required this.topPlaces,
  });

  factory PopularityRankingResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['top_places'] as List?) ?? const [];
    return PopularityRankingResponse(
      success: (json['success'] as bool?) ?? true,
      totalPlaces: (json['total_places'] as num?)?.toInt() ?? list.length,
      topPlaces: list.map((e) => RankingItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
