import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kamino_fr/features/2_home/presentation/provider/navigation_provider.dart';
import 'package:kamino_fr/features/2_home/presentation/provider/home_provider.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/place_preview_modal.dart';
import 'package:kamino_fr/features/2_home/data/models/place.dart';
import 'package:kamino_fr/core/utils/app_animations.dart';
import 'package:kamino_fr/features/5_explore/presentation/provider/explore_provider.dart';
import 'package:kamino_fr/features/3_profile/presentation/provider/profile_provider.dart';
import 'package:kamino_fr/config/environment_config.dart';
import 'package:kamino_fr/core/auth/token_storage.dart';
import 'package:kamino_fr/core/network/http_client.dart';
import 'package:kamino_fr/features/5_chat/data/chat_api.dart';
import 'package:kamino_fr/features/5_chat/data/chat_repository.dart';
import 'package:kamino_fr/features/5_chat/presentation/widgets/chat_bottom_sheet.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/place_info_modal.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreProvider>().loadPlaces();
      // Load profile if not loaded
      final profileProvider = context.read<ProfileProvider>();
      if (profileProvider.user == null && !profileProvider.isLoading) {
        profileProvider.loadProfile();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.textBlack,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explorar',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Consumer<ExploreProvider>(
                    builder: (context, provider, _) {
                      if (_searchController.text != provider.searchQuery) {
                        _searchController.text = provider.searchQuery;
                        _searchController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _searchController.text.length));
                      }
                      return TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          provider.setSearchQuery(value);
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Buscar lugares...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.4)),
                          suffixIcon: provider.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.white70),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.setSearchQuery('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppTheme.primaryMint, width: 2),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<ExploreProvider>(
                builder: (context, provider, child) {
                  if (provider.loading && provider.places.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (provider.error != null && provider.places.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.white.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            provider.error!,
                            style: TextStyle(color: Colors.white.withOpacity(0.7)),
                          ),
                          TextButton(
                            onPressed: () => provider.loadPlaces(),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.places.isEmpty) {
                     return Center(
                      child: Text(
                        'No se encontraron lugares',
                        style: TextStyle(color: Colors.white.withOpacity(0.5)),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: provider.places.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final place = provider.places[index];
                      return _PlaceCard(place: place);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final Place place;

  const _PlaceCard({required this.place});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final isLiked = profileProvider.isLiked(place.id);
    final isVisited = profileProvider.isVisited(place.id);

    return GestureDetector(
      onTap: () {
        AppAnimations.showFluidModalBottomSheet(
          context: context,
          builder: (ctx) => PlacePreviewModal(
            place: place,
            onNavigate: () async {
              Navigator.pop(ctx);
              final navProvider = context.read<NavigationProvider>();
              final homeProvider = context.read<HomeProvider>();
              
              try {
                final geoPos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
                
                await navProvider.calculateRoute(
                  latOrigin: geoPos.latitude,
                  lonOrigin: geoPos.longitude,
                  latDest: place.latitude,
                  lonDest: place.longitude,
                  currentSpeed: geoPos.speed,
                  showOverlay: false,
                  destinationName: place.name,
                );
                
                // Switch to map tab (index 0)
                homeProvider.setTab(0);
                
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al calcular ruta: $e')),
                );
              }
            },
            onChat: () {
              Navigator.pop(ctx);
              final config = Provider.of<EnvironmentConfig>(context, listen: false);
              final http = HttpClient(config, SecureTokenStorage());
              final api = ChatApiImpl(http.dio);
              final repo = ChatRepository(api: api);
              AppAnimations.showFluidModalBottomSheet(
                context: context,
                builder: (_) => ChatBottomSheet(repository: repo, title: 'Chat: ${place.name}'),
              );
            },
            onDetails: () {
              Navigator.pop(ctx);
              showDialog(
                context: context,
                barrierColor: Colors.transparent,
                builder: (context) => PlaceInfoModal(
                  destinationName: place.name,
                  imageUrl: place.imageUrl,
                  description: place.description,
                ),
              );
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2329),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                place.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[800],
                    child: const Icon(Icons.image_not_supported, color: Colors.white54),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        place.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryMint,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isVisited)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryMint.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppTheme.primaryMint.withOpacity(0.5)),
                          ),
                          child: const Text(
                            'Visitado',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.primaryMint,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.address,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                InkWell(
                  onTap: () async {
                    await context.read<ProfileProvider>().toggleFavorite(place.id);
                  },
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: isLiked ? Colors.redAccent : Colors.white54,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.white54,
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