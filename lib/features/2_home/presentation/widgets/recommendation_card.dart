import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:kamino_fr/features/2_home/data/models/recommendation.dart';

class RecommendationCard extends StatelessWidget {
  final Recommendation item;
  final VoidCallback? onTap;
  const RecommendationCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 220,
        height: 140,
        decoration: BoxDecoration(
          color: AppTheme.lightMintBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryMintDark.withOpacity(0.35)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textBlack, fontSize: 14),
                  ),
                ),
                if (item.isHiddenGem)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: const Text('Gema', style: TextStyle(color: AppTheme.textBlack, fontWeight: FontWeight.w700, fontSize: 10)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryMint.withOpacity(0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppTheme.primaryMint, fontWeight: FontWeight.w600),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textBlack),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
