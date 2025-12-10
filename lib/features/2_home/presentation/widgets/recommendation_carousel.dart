import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:kamino_fr/features/2_home/data/models/recommendation.dart';

class RecommendationCarousel extends StatelessWidget {
  final List<Recommendation> recommendations;
  final Function(Recommendation) onTap;

  const RecommendationCarousel({
    super.key,
    required this.recommendations,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 180,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: recommendations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = recommendations[index];
          return _FeaturedCard(item: item, onTap: () => onTap(item));
        },
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Recommendation item;
  final VoidCallback onTap;

  const _FeaturedCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final matchPercent = (item.finalScore * 100).clamp(0, 100).toInt();
    final isGem = item.isHiddenGem;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isGem
                ? [const Color(0xFF2E1A47), const Color(0xFF4A148C)] // Purple for Gems
                : [const Color(0xFF1A2332), const Color(0xFF0F172A)], // Dark Blue for others
          ),
          border: Border.all(
            color: isGem ? Colors.purpleAccent.withOpacity(0.5) : Colors.white.withOpacity(0.1),
            width: isGem ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isGem ? Colors.purpleAccent.withOpacity(0.2) : Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Decoration
            Positioned(
              right: -20,
              top: -20,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: isGem 
                    ? Colors.purpleAccent.withOpacity(0.1) 
                    : AppTheme.primaryMint.withOpacity(0.05),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Category & Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      if (isGem)
                        const Icon(Icons.diamond_outlined, color: Colors.purpleAccent, size: 20),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Main Content
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Footer: Score & Reason
                  Row(
                    children: [
                      // Circular Score
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: item.finalScore.clamp(0.0, 1.0),
                              strokeWidth: 3,
                              backgroundColor: Colors.white10,
                              color: isGem ? Colors.purpleAccent : AppTheme.primaryMint,
                            ),
                            Text(
                              '$matchPercent%',
                              style: TextStyle(
                                color: isGem ? Colors.purpleAccent : AppTheme.primaryMint,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'COINCIDENCIA',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 8,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.reason,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}