import 'package:flutter/material.dart';
import '../../data/models/popularity_ranking.dart';

class RankingPodium extends StatefulWidget {
  final List<RankingItem> items;
  final Function(RankingItem) onItemTap;

  const RankingPodium({
    super.key,
    required this.items,
    required this.onItemTap,
  });

  @override
  State<RankingPodium> createState() => _RankingPodiumState();
}

class _RankingPodiumState extends State<RankingPodium> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.length < 3) return const SizedBox();

    final first = widget.items[0];
    final second = widget.items[1];
    final third = widget.items[2];

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 2nd Place
            _buildPodiumItem(second, 2, const Color(0xFFC0C0C0), 110),
            const SizedBox(width: 8),
            // 1st Place
            _buildPodiumItem(first, 1, const Color(0xFFFFD700), 140),
            const SizedBox(width: 8),
            // 3rd Place
            _buildPodiumItem(third, 3, const Color(0xFFCD7F32), 90),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumItem(RankingItem item, int rank, Color color, double height) {
    return GestureDetector(
      onTap: () => widget.onItemTap(item),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar/Icon
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, spreadRadius: 1)
              ]
            ),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF2A3038),
              radius: rank == 1 ? 30 : 22,
              child: Text(
                item.name.isNotEmpty ? item.name.substring(0, 1).toUpperCase() : '?',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: rank == 1 ? 24 : 18)
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Bar
          Container(
            width: rank == 1 ? 90 : 80,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.withOpacity(0.8), color.withOpacity(0.3)]
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8)
              ),
              border: Border.all(color: color.withOpacity(0.5), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '#$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                   decoration: BoxDecoration(
                     color: Colors.black26,
                     borderRadius: BorderRadius.circular(4)
                   ),
                   child: Text(
                    item.predictedScore.toStringAsFixed(3), 
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 9
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}