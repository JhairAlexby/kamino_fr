class Recommendation {
  final String placeId;
  final String name;
  final String category;
  final List<String> tags;
  final double similarityScore;
  final double finalScore;
  final bool isHiddenGem;
  final String reason;

  Recommendation({
    required this.placeId,
    required this.name,
    required this.category,
    required this.tags,
    required this.similarityScore,
    required this.finalScore,
    required this.isHiddenGem,
    required this.reason,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      placeId: (json['place_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      similarityScore: _toDouble(json['similarity_score']),
      finalScore: _toDouble(json['final_score']),
      isHiddenGem: json['is_hidden_gem'] == true,
      reason: (json['reason'] ?? '').toString(),
    );
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    final s = v?.toString() ?? '0';
    return double.tryParse(s) ?? 0.0;
  }
}

class RecommendResponse {
  final bool success;
  final String userId;
  final String strategy;
  final List<Recommendation> recommendations;

  RecommendResponse({
    required this.success,
    required this.userId,
    required this.strategy,
    required this.recommendations,
  });

  factory RecommendResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['recommendations'] as List?) ?? const [];
    return RecommendResponse(
      success: json['success'] == true,
      userId: (json['user_id'] ?? '').toString(),
      strategy: (json['strategy'] ?? '').toString(),
      recommendations: list.map((e) => Recommendation.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
