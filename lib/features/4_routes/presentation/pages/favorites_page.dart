import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:kamino_fr/features/3_profile/presentation/provider/profile_provider.dart';
import 'package:kamino_fr/features/5_explore/presentation/provider/explore_provider.dart';
import 'package:kamino_fr/features/2_home/data/models/place.dart';
import 'package:kamino_fr/config/environment_config.dart';
import 'package:kamino_fr/core/auth/token_storage.dart';
import 'package:kamino_fr/core/network/http_client.dart';
import 'package:kamino_fr/features/2_home/data/places_api.dart';
import 'package:kamino_fr/features/2_home/data/places_repository.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _resolving = false;
  List<Place> _favById = const [];
  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>();
    if (profile.user == null && !profile.isLoading) {
      profile.loadProfile();
    }
    final explore = context.read<ExploreProvider>();
    if (explore.places.isEmpty && !explore.loading) {
      explore.loadPlaces();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureFavoritesLoaded());
  }

  Future<void> _ensureFavoritesLoaded() async {
    final profile = context.read<ProfileProvider>();
    final ids = profile.user?.favoritePlaces ?? const <String>[];
    if (ids.isEmpty || _resolving || _favById.isNotEmpty) return;
    setState(() {
      _resolving = true;
    });
    try {
      final config = Provider.of<EnvironmentConfig>(context, listen: false);
      final http = HttpClient(config, SecureTokenStorage());
      final api = PlacesApiImpl(http.dio);
      final repo = PlacesRepository(api: api, maxRetries: config.maxRetries);
      final results = await Future.wait(ids.map((id) => repo.getById(id)));
      final resolved = results.whereType<Place>().toList();
      setState(() {
        _favById = resolved;
      });
    } catch (_) {
      // Silencioso: si falla, la UI seguirá intentando mostrar desde explore
    } finally {
      if (mounted) {
        setState(() {
          _resolving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final explore = context.watch<ExploreProvider>();

    final favIds = profile.user?.favoritePlaces ?? const <String>[];
    final places = explore.places;
    final favPlaces = places.where((p) => favIds.contains(p.id)).toList();
    final display = favPlaces.isNotEmpty ? favPlaces : _favById;

    if (favIds.isNotEmpty && _favById.isEmpty && !_resolving) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _ensureFavoritesLoaded());
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
                'Favoritos',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: (profile.isLoading || explore.loading) && !_resolving
                  ? const Center(child: CircularProgressIndicator())
                  : favIds.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite_border, size: 64, color: Colors.white.withOpacity(0.3)),
                              const SizedBox(height: 16),
                              Text(
                                'Aún no tienes lugares favoritos',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : (display.isEmpty && _resolving)
                          ? const Center(child: CircularProgressIndicator())
                          : display.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error_outline, size: 64, color: Colors.white.withOpacity(0.3)),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No pudimos cargar los detalles de tus favoritos',
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
                          itemCount: display.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final place = display[index];
                            return _FavoriteCard(place: place);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Place place;
  const _FavoriteCard({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          SizedBox(
            width: 72,
            height: 72,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _ThumbImage(url: place.imageUrl),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                const SizedBox(height: 6),
                Text(
                  place.category.isNotEmpty ? place.category : 'Lugar',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: AppTheme.primaryMint),
            onPressed: () {
              final provider = context.read<ProfileProvider>();
              provider.toggleFavorite(place.id);
            },
          ),
        ],
      ),
    );
  }
}

class _ThumbImage extends StatelessWidget {
  final String url;
  const _ThumbImage({required this.url});

  @override
  Widget build(BuildContext context) {
    final placeholder = Image.asset(
      'assets/images/3dmapa.png',
      fit: BoxFit.cover,
    );
    if (url.isEmpty) return placeholder;
    return Image.network(
      url,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      cacheWidth: 144,
      cacheHeight: 144,
      errorBuilder: (context, error, stackTrace) => placeholder,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.black26,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }
}
