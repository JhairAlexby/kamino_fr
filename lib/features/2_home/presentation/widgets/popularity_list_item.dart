import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';
import '../../data/models/popularity_ranking.dart';

class PopularityListItem extends StatelessWidget {
  final RankingItem item;
  final int index;
  final VoidCallback? onTap;

  const PopularityListItem({super.key, required this.item, required this.index, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A3038),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primaryMint.withOpacity(0.35), width: 1),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.primaryMint.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Text('${index + 1}', style: const TextStyle(color: AppTheme.primaryMint, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('${item.category} • ${item.interpretation}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryMint.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(item.predictedScore.toStringAsFixed(3), style: const TextStyle(color: AppTheme.primaryMint, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
