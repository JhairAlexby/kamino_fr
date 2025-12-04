import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/features/3_profile/presentation/provider/profile_provider.dart';
import 'package:kamino_fr/features/2_home/data/models/place.dart';
import 'package:kamino_fr/features/2_home/data/places_repository.dart';
import 'package:kamino_fr/core/app_theme.dart';

class MyRoutesPage extends StatefulWidget {
  const MyRoutesPage({super.key});

  @override
  State<MyRoutesPage> createState() => _MyRoutesPageState();
}

class _MyRoutesPageState extends State<MyRoutesPage> {
  List<Place> _visitedPlacesList = [];
  bool _isLoadingPlaces = false;
  Set<String> _loadedIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      if (profileProvider.user == null && !profileProvider.isLoading) {
        profileProvider.loadProfile().then((_) => _loadVisitedPlaces());
      } else {
        _loadVisitedPlaces();
      }
    });
  }

  Future<void> _loadVisitedPlaces() async {
    final profileProvider = context.read<ProfileProvider>();
    final visitedIds = profileProvider.user?.visitedPlaces ?? [];
    
    if (visitedIds.isEmpty) {
      setState(() {
        _visitedPlacesList = [];
        _loadedIds = {};
      });
      return;
    }

    if (visitedIds.toSet().difference(_loadedIds).isEmpty && 
        _loadedIds.difference(visitedIds.toSet()).isEmpty && 
        _visitedPlacesList.isNotEmpty) {
      return;
    }

    setState(() => _isLoadingPlaces = true);

    try {
      final placesRepo = context.read<PlacesRepository>();
      final List<Place> loaded = [];
      
      for (final id in visitedIds) {
        final place = await placesRepo.getById(id);
        if (place != null) {
          loaded.add(place);
        }
      }

      if (mounted) {
        setState(() {
          _visitedPlacesList = loaded;
          _loadedIds = visitedIds.toSet();
          _isLoadingPlaces = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPlaces = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    
    final currentIds = profileProvider.user?.visitedPlaces ?? [];
    if (!_isLoadingPlaces && 
        (currentIds.length != _loadedIds.length || 
         !currentIds.toSet().containsAll(_loadedIds))) {
       WidgetsBinding.instance.addPostFrameCallback((_) => _loadVisitedPlaces());
    }

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                'Mis Rutas',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: _isLoadingPlaces 
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : _visitedPlacesList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map_outlined, size: 64, color: Colors.white.withOpacity(0.3)),
                              const SizedBox(height: 16),
                              Text(
                                'Aún no has realizado ninguna ruta',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: _visitedPlacesList.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final place = _visitedPlacesList[index];
                            final hasLog = false; // TODO: Implement log logic

                            return _RouteCard(place: place, hasLog: hasLog);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteCard extends StatefulWidget {
  final Place place;
  final bool hasLog;

  const _RouteCard({required this.place, required this.hasLog});

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
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Abrir/Crear bitácora próximamente')),
                        );
                      },
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