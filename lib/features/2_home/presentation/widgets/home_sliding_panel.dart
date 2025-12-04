import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/features/2_home/presentation/provider/home_provider.dart';
import 'package:kamino_fr/features/2_home/data/models/recommendation.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/recommendation_card.dart';

class HomeCollapsedPanel extends StatelessWidget {
  const HomeCollapsedPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF222831), // Fondo sólido gris oscuro para contraste
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppTheme.primaryMint, width: 3), // Borde superior grueso color menta
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 15,
            spreadRadius: 2,
            offset: Offset(0, -4), // Sombra fuerte hacia arriba
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 32, height: 3, decoration: BoxDecoration(color: AppTheme.primaryMint.withOpacity(0.5), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 4),
          const Text('Recomendaciones', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}

class HomeExpandedPanel extends StatelessWidget {
  final ScrollController scrollController;

  const HomeExpandedPanel({super.key, required this.scrollController});

  Widget _buildCard(Recommendation item) {
    return RecommendationCard(item: item);
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HomeProvider>(context);
    final topHidden = vm.hiddenTop;
    final nonHidden = vm.nonHidden;
    final topWeek = vm.topWeek;

    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF2A3038), AppTheme.textBlack],
            stops: [0.0, 1.0],
          ),
          boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 20, offset: Offset(0, -6))],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ListView(
            controller: scrollController,
            children: [
                if (vm.loadingRecommendations)
                  const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppTheme.primaryMint)))
                else if (vm.recommendationsError != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(vm.recommendationsError!, style: const TextStyle(color: Colors.white)),
                  )
                else ...[
                  const Text('Joyas ocultas de la semana', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryMint)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: topHidden.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => _buildCard(topHidden[i]),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Basado en tus últimas rutas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryMint)),
                  const SizedBox(height: 12),
                  if (nonHidden.isNotEmpty)
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: nonHidden.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => _buildCard(nonHidden[i]),
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Text('Destacados de la semana', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryMint)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: topWeek.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => _buildCard(topWeek[i]),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
            ],
          ),
        ),
      ),
    );
  }
}
