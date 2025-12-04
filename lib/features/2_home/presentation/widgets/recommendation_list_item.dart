import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:kamino_fr/features/2_home/data/models/recommendation.dart';

class RecommendationListItem extends StatelessWidget {
  final Recommendation item;
  final VoidCallback? onTap;
  final VoidCallback? onNavigate;
  const RecommendationListItem({super.key, required this.item, this.onTap, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.lightMintBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryMintDark.withOpacity(0.35)),
        ),
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
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textBlack, fontSize: 16),
                  ),
                ),
                if (item.isHiddenGem)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: const Text('Gema oculta', style: TextStyle(color: AppTheme.textBlack, fontWeight: FontWeight.w700, fontSize: 10)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.primaryMint.withOpacity(0.14), borderRadius: BorderRadius.circular(8)),
              child: Text(
                item.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppTheme.primaryMint, fontWeight: FontWeight.w600),
              ),
            ),
            if (item.reason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item.reason,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppTheme.textBlack),
              ),
            ],
            if (item.tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: item.tags.take(6).map((t) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(t, style: const TextStyle(fontSize: 12, color: Colors.white)),
                )).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                ElevatedButton(
                  onPressed: onNavigate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryMint,
                    foregroundColor: AppTheme.textBlack,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
