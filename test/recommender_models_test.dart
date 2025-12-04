import 'package:flutter_test/flutter_test.dart';
import 'package:kamino_fr/features/2_home/data/models/recommendation.dart';

void main() {
  test('parse recommend response', () {
    final json = {
      "success": true,
      "user_id": "54e0f7c4-bd50-479e-bd29-d7a012f405d6",
      "strategy": "content_based",
      "recommendations": [
        {
          "place_id": "5713633a-5086-4bd3-b5e3-b83c39985e7c",
          "name": "Poza Señor del Pozo",
          "category": "balneario natural",
          "tags": ["naturaleza", "aventura", "familia"],
          "similarity_score": 0.655,
          "final_score": 0.755,
          "is_hidden_gem": true,
          "reason": "Similar a tus lugares favoritos (gema oculta destacada)"
        }
      ]
    };

    final res = RecommendResponse.fromJson(json);
    expect(res.success, true);
    expect(res.userId, '54e0f7c4-bd50-479e-bd29-d7a012f405d6');
    expect(res.strategy, 'content_based');
    expect(res.recommendations.length, 1);
    final r = res.recommendations.first;
    expect(r.name, 'Poza Señor del Pozo');
    expect(r.category, 'balneario natural');
    expect(r.isHiddenGem, true);
    expect(r.finalScore, 0.755);
  });
}
