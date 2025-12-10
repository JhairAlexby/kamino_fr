import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/features/2_home/presentation/provider/home_provider.dart';
import 'package:kamino_fr/features/2_home/data/models/recommendation.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/recommendation_list_item.dart';
import 'package:kamino_fr/features/2_home/data/places_repository.dart';
import 'package:kamino_fr/features/2_home/presentation/provider/navigation_provider.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:kamino_fr/config/environment_config.dart';
import 'package:kamino_fr/core/network/http_client.dart';
import 'package:kamino_fr/core/auth/token_storage.dart';
import 'package:kamino_fr/features/2_home/data/narrator_api.dart';
import 'package:kamino_fr/features/2_home/data/narrator_repository.dart';
import 'package:kamino_fr/core/services/narrator_service.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:kamino_fr/features/2_home/presentation/provider/popularity_provider.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/popularity_list_item.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/ranking_podium.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/recommendation_carousel.dart';
import 'package:kamino_fr/features/2_home/data/models/popularity_ranking.dart';

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
  final PanelController panelController;

  const HomeExpandedPanel({super.key, required this.scrollController, required this.panelController});

  Future<void> _handleRecommendationNavigation(BuildContext context, Recommendation item) async {
    try {
      final repo = Provider.of<PlacesRepository>(context, listen: false);
      final navVm = Provider.of<NavigationProvider>(context, listen: false);
      final homeVm = Provider.of<HomeProvider>(context, listen: false);
      final config = Provider.of<EnvironmentConfig>(context, listen: false);
      final place = await repo.getById(item.placeId);
      if (place == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lugar no disponible')));
        return;
      }
      final pos = await geo.Geolocator.getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.best);
      homeVm.setTab(0);
      try { panelController.close(); } catch (_) {}
      await navVm.calculateRoute(
        latOrigin: pos.latitude,
        lonOrigin: pos.longitude,
        latDest: place.latitude,
        lonDest: place.longitude,
        currentSpeed: pos.speed,
        destinationName: place.name,
        destinationId: place.id,
      );
      try {
        final http = HttpClient(config, SecureTokenStorage());
        final api = NarratorApiImpl(http.dio);
        final nrepo = NarratorRepository(api: api);
        final narrator = NarratorService(repository: nrepo);
        final ok = await narrator.narratePlace(place.id);
        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Narración no disponible para este lugar')));
        }
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al iniciar la narración')));
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo generar la ruta')));
    }
  }

  Widget _buildItem(BuildContext context, Recommendation item) {
    return RecommendationListItem(
      item: item,
      onNavigate: () => _handleRecommendationNavigation(context, item),
    );
  }

  Future<void> _handleRankingNavigation(BuildContext context, RankingItem item) async {
    try {
      final repo = Provider.of<PlacesRepository>(context, listen: false);
      final navVm = Provider.of<NavigationProvider>(context, listen: false);
      final homeVm = Provider.of<HomeProvider>(context, listen: false);
      
      final place = await repo.getById(item.placeId);
      if (place == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lugar no disponible')));
        return;
      }
      
      final pos = await geo.Geolocator.getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.best);
      homeVm.setTab(0);
      try { panelController.close(); } catch (_) {}
      
      await navVm.calculateRoute(
        latOrigin: pos.latitude,
        lonOrigin: pos.longitude,
        latDest: place.latitude,
        lonDest: place.longitude,
        currentSpeed: pos.speed,
        destinationName: place.name,
        destinationId: place.id,
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo iniciar la navegación')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HomeProvider>(context);
    final pop = Provider.of<PopularityProvider>(context);
    final items = [...vm.recommendations]..sort((a, b) => b.finalScore.compareTo(a.finalScore));

    // Split recommendations: Top 5 for carousel, rest for list
    final topRecs = items.take(5).toList();
    final otherRecs = items.skip(5).toList();

    // Split top places for podium
    final topPlaces = pop.top;
    final showPodium = topPlaces.length >= 3;
    final podiumItems = showPodium ? topPlaces.take(3).toList() : <RankingItem>[];
    final listItems = showPodium ? topPlaces.skip(3).toList() : topPlaces;

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
                  const Text('Recomendaciones para ti', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryMint)),
                  const SizedBox(height: 12),
                  
                  // New Carousel for Top Picks
                  if (topRecs.isNotEmpty) ...[
                    RecommendationCarousel(
                      recommendations: topRecs,
                      onTap: (item) => _handleRecommendationNavigation(context, item),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // List for the rest
                  if (otherRecs.isNotEmpty)
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: otherRecs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _buildItem(context, otherRecs[i]),
                    ),
                  
                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No hay recomendaciones disponibles por ahora', style: TextStyle(color: Colors.white54)),
                    ),

                  const SizedBox(height: 24),
                ],
                const Text('Ranking de lugares populares', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryMint)),
                const SizedBox(height: 12),
                if (pop.loading)
                  const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppTheme.primaryMint)))
                else if (pop.error != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(pop.error!, style: const TextStyle(color: Colors.white)),
                  )
                else
                  Column(
                    children: [
                      if (showPodium)
                        RankingPodium(
                          items: podiumItems,
                          onItemTap: (item) => _handleRankingNavigation(context, item),
                        ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: listItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final r = listItems[i];
                          // Adjust rank index based on podium
                          final rankIndex = showPodium ? i + 3 : i;
                          
                          return PopularityListItem(
                            item: r,
                            index: rankIndex,
                            onTap: () => _handleRankingNavigation(context, r),
                          );
                        },
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
