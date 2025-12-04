import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:kamino_fr/config/environment_config.dart';
import 'package:kamino_fr/core/auth/token_storage.dart';
import 'package:kamino_fr/core/network/http_client.dart';
import 'package:kamino_fr/features/2_home/data/places_api.dart';
import 'package:kamino_fr/features/2_home/data/places_repository.dart';
import 'package:kamino_fr/features/2_home/data/models/place.dart';
import 'package:kamino_fr/features/3_profile/presentation/provider/profile_provider.dart';
import 'package:kamino_fr/core/utils/app_animations.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Place> _favorites = const [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      if (profileProvider.user == null && !profileProvider.isLoading) {
        profileProvider.loadProfile();
      }
      profileProvider.addListener(_onProfileChanged);
    });
  }

  void _onProfileChanged() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final profileProvider = context.read<ProfileProvider>();
    final ids = profileProvider.user?.favoritePlaces ?? const [];
    if (ids.isEmpty) {
      setState(() {
        _favorites = const [];
        _error = null;
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final config = Provider.of<EnvironmentConfig>(context, listen: false);
      final http = HttpClient(config, SecureTokenStorage());
      final api = PlacesApiImpl(http.dio);
      final repo = PlacesRepository(api: api, maxRetries: config.maxRetries);

      final all = await repo.findAll();
      final favs = all.where((p) => ids.contains(p.id)).toList();
      setState(() {
        _favorites = favs;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudieron cargar tus favoritos';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: AppTheme.textBlack,
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
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryMint))
                  : (_error != null)
                      ? Center(
                          child: Text(
                            _error!,
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
                          ),
                        )
                      : (_favorites.isEmpty)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.favorite_border, size: 64, color: Colors.white.withOpacity(0.3)),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aún no tienes lugares favoritos',
                                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
                                  ),
                                ],
                              ),
                            )
                          : _FavoritesList(places: _favorites),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    try {
      context.read<ProfileProvider>().removeListener(_onProfileChanged);
    } catch (_) {}
    super.dispose();
  }
}

class _FavoritesList extends StatelessWidget {
  final List<Place> places;

  const _FavoritesList({required this.places});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: places.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = places[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [Color(0xFF0F172A), AppTheme.textBlack],
              stops: [0.0, 1.0],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6)),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: p.imageUrl.isNotEmpty
                    ? Image.network(p.imageUrl, width: 72, height: 72, fit: BoxFit.cover)
                    : Container(width: 72, height: 72, color: Colors.white10),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Consumer<ProfileProvider>(
                          builder: (context, profile, _) {
                            final isLiked = profile.isLiked(p.id);
                            return InkWell(
                              onTap: () => profile.toggleFavorite(p.id),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: isLiked ? Colors.red : Colors.white54,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.address,
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


