import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/features/3_profile/presentation/provider/profile_provider.dart';
import 'package:kamino_fr/features/2_home/data/models/place.dart';
import 'package:kamino_fr/features/2_home/data/places_repository.dart';
import 'package:kamino_fr/core/app_theme.dart';

import 'package:kamino_fr/features/4_routes/presentation/widgets/logbook_modal.dart';

class MyRoutesPage extends StatefulWidget {
  const MyRoutesPage({super.key});

  @override
  State<MyRoutesPage> createState() => _MyRoutesPageState();
}

class _MyRoutesPageState extends State<MyRoutesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Place> _visitedPlacesList = [];
  List<Place> _favoritePlacesList = [];
  bool _isLoadingVisited = false;
  bool _isLoadingFavorites = false;
  Set<String> _loadedVisitedIds = {};
  Set<String> _loadedFavoriteIds = {};
  String? _visitedError;
  String? _favoritesError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      if (profileProvider.user == null && !profileProvider.isLoading) {
        profileProvider.loadProfile().then((_) {
          _loadVisitedPlaces();
          _loadFavoritePlaces();
        });
      } else {
        _loadVisitedPlaces();
        _loadFavoritePlaces();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVisitedPlaces() async {
    final profileProvider = context.read<ProfileProvider>();
    final visitedIds = profileProvider.user?.visitedPlaces ?? [];
    
    print('MyRoutesPage: loading visited places. IDs: $visitedIds');

    if (visitedIds.isEmpty) {
      print('MyRoutesPage: no visited places to load.');
      if (mounted) {
        setState(() {
          _visitedPlacesList = [];
          _loadedVisitedIds = {};
        });
      }
      return;
    }

    if (visitedIds.toSet().difference(_loadedVisitedIds).isEmpty && 
        _loadedVisitedIds.difference(visitedIds.toSet()).isEmpty && 
        _visitedPlacesList.isNotEmpty) {
      print('MyRoutesPage: visited places already loaded and up to date.');
      return;
    }

    if (mounted) setState(() => _isLoadingVisited = true);

    try {
      final placesRepo = context.read<PlacesRepository>();
      final List<Place> loaded = [];
      
      for (final id in visitedIds) {
        try {
          print('MyRoutesPage: fetching details for visited place $id');
          final place = await placesRepo.getById(id);
          if (place != null) {
            print('MyRoutesPage: loaded visited details for ${place.name}');
            loaded.add(place);
          } else {
            print('MyRoutesPage: failed to load visited details for $id (returned null)');
          }
        } catch (e) {
          print('MyRoutesPage: error loading visited place $id: $e');
        }
      }

      if (mounted) {
        setState(() {
          _visitedPlacesList = loaded;
          _loadedVisitedIds = visitedIds.toSet();
          _isLoadingVisited = false;
          if (loaded.isEmpty && visitedIds.isNotEmpty) {
            _visitedError = 'No se pudieron cargar los lugares. Verifica tu conexión.';
          } else {
            _visitedError = null;
          }
        });
      }
    } catch (e) {
      print('MyRoutesPage: error loading visited places: $e');
      if (mounted) {
        setState(() {
          _isLoadingVisited = false;
          _visitedError = 'Error al cargar: $e';
        });
      }
    }
  }

  Future<void> _loadFavoritePlaces() async {
    final profileProvider = context.read<ProfileProvider>();
    final favoriteIds = profileProvider.user?.favoritePlaces ?? [];
    
    print('MyRoutesPage: loading favorite places. IDs: $favoriteIds');

    if (favoriteIds.isEmpty) {
      print('MyRoutesPage: no favorite places to load.');
      if (mounted) {
        setState(() {
          _favoritePlacesList = [];
          _loadedFavoriteIds = {};
        });
      }
      return;
    }

    if (favoriteIds.toSet().difference(_loadedFavoriteIds).isEmpty && 
        _loadedFavoriteIds.difference(favoriteIds.toSet()).isEmpty && 
        _favoritePlacesList.isNotEmpty) {
      print('MyRoutesPage: favorite places already loaded and up to date.');
      return;
    }

    if (mounted) setState(() => _isLoadingFavorites = true);

    try {
      final placesRepo = context.read<PlacesRepository>();
      final List<Place> loaded = [];
      
      for (final id in favoriteIds) {
        try {
          print('MyRoutesPage: fetching details for favorite place $id');
          final place = await placesRepo.getById(id);
          if (place != null) {
            print('MyRoutesPage: loaded favorite details for ${place.name}');
            loaded.add(place);
          } else {
            print('MyRoutesPage: failed to load favorite details for $id (returned null)');
          }
        } catch (e) {
          print('MyRoutesPage: error loading favorite place $id: $e');
        }
      }

      if (mounted) {
        setState(() {
          _favoritePlacesList = loaded;
          _loadedFavoriteIds = favoriteIds.toSet();
          _isLoadingFavorites = false;
          if (loaded.isEmpty && favoriteIds.isNotEmpty) {
            _favoritesError = 'No se pudieron cargar los lugares. Verifica tu conexión.';
          } else {
            _favoritesError = null;
          }
        });
      }
    } catch (e) {
      print('MyRoutesPage: error loading favorite places: $e');
      if (mounted) {
        setState(() {
          _isLoadingFavorites = false;
          _favoritesError = 'Error al cargar: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    
    // Check for updates on every build
    final currentVisitedIds = profileProvider.user?.visitedPlaces ?? [];
    if (!_isLoadingVisited && 
        (currentVisitedIds.length != _loadedVisitedIds.length || 
         !currentVisitedIds.toSet().containsAll(_loadedVisitedIds))) {
       WidgetsBinding.instance.addPostFrameCallback((_) => _loadVisitedPlaces());
    }

    final currentFavoriteIds = profileProvider.user?.favoritePlaces ?? [];
    if (!_isLoadingFavorites && 
        (currentFavoriteIds.length != _loadedFavoriteIds.length || 
         !currentFavoriteIds.toSet().containsAll(_loadedFavoriteIds))) {
       WidgetsBinding.instance.addPostFrameCallback((_) => _loadFavoritePlaces());
    }

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text(
                'Mis Rutas',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryMint,
              labelColor: AppTheme.primaryMint,
              unselectedLabelColor: Colors.white60,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Visitados'),
                Tab(text: 'Favoritos'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Visitados
                  _buildPlaceList(
                    isLoading: _isLoadingVisited,
                    places: _visitedPlacesList,
                    emptyMessage: 'Aún no has visitado ningún lugar',
                    emptyIcon: Icons.check_circle_outline,
                    errorMessage: _visitedError,
                    onRetry: _loadVisitedPlaces,
                  ),
                  // Tab 2: Favoritos
                  _buildPlaceList(
                    isLoading: _isLoadingFavorites,
                    places: _favoritePlacesList,
                    emptyMessage: 'Aún no tienes lugares favoritos',
                    emptyIcon: Icons.favorite_border,
                    errorMessage: _favoritesError,
                    onRetry: _loadFavoritePlaces,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceList({
    required bool isLoading,
    required List<Place> places,
    required String emptyMessage,
    required IconData emptyIcon,
    String? errorMessage,
    VoidCallback? onRetry,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    
    if (places.isEmpty) {
      if (errorMessage != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 48, color: Colors.orangeAccent),
                const SizedBox(height: 16),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryMint,
                    foregroundColor: AppTheme.textBlack,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: places.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final place = places[index];
        final profileProvider = context.watch<ProfileProvider>();
        final existingLog = profileProvider.getLogForPlace(place.id);

        return _RouteCard(
          place: place, 
          hasLog: existingLog != null,
          onLogAction: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => LogbookModal(
                placeId: place.id,
                placeName: place.name,
                placeImageUrl: place.imageUrl,
                existingLog: existingLog,
                onSave: (log) {
                  context.read<ProfileProvider>().addLog(log);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bitácora guardada correctamente')),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _RouteCard extends StatefulWidget {
  final Place place;
  final bool hasLog;
  final VoidCallback onLogAction;

  const _RouteCard({
    required this.place, 
    required this.hasLog,
    required this.onLogAction,
  });

  @override
  State<_RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<_RouteCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        // Aquí iría la navegación al detalle de la ruta
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [Color(0xFF0F172A), AppTheme.textBlack],
              stops: [0.0, 1.0],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.place.imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey[800],
                    child: const Icon(Icons.image_not_supported, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.place.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Consumer<ProfileProvider>(
                          builder: (context, profile, _) {
                            final isLiked = profile.isLiked(widget.place.id);
                            return InkWell(
                              onTap: () => profile.toggleFavorite(widget.place.id),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: isLiked ? const Color(0xFFFF4757) : Colors.white54,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 12, color: Colors.white.withOpacity(0.6)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.place.address,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Botón de Bitácora
                    InkWell(
                      onTap: widget.onLogAction,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.hasLog 
                              ? AppTheme.primaryMint.withOpacity(0.15) 
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: widget.hasLog 
                                ? AppTheme.primaryMint.withOpacity(0.5) 
                                : Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.hasLog ? Icons.menu_book : Icons.add_circle_outline,
                              size: 16,
                              color: widget.hasLog ? AppTheme.primaryMint : Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.hasLog ? 'Ver Bitácora' : 'Crear Bitácora',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: widget.hasLog ? AppTheme.primaryMint : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}