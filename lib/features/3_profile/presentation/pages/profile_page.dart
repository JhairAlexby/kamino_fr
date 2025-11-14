import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:kamino_fr/config/environment_config.dart';
import 'package:kamino_fr/core/auth/token_storage.dart';
import 'package:kamino_fr/core/network/http_client.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:kamino_fr/core/app_router.dart';
import 'package:kamino_fr/features/3_profile/data/profile_api.dart';
import 'package:kamino_fr/features/3_profile/data/profile_repository.dart';
import 'package:kamino_fr/features/3_profile/presentation/provider/profile_provider.dart';
import 'package:kamino_fr/features/3_profile/presentation/widgets/profile_header.dart';
import 'package:kamino_fr/features/3_profile/presentation/widgets/info_row.dart';
import 'package:kamino_fr/features/3_profile/presentation/widgets/status_badge.dart';
import 'package:kamino_fr/features/3_profile/presentation/widgets/detail_item.dart';
import 'package:kamino_fr/features/3_profile/presentation/widgets/metric_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<EnvironmentConfig>(context, listen: false);
    final storage = SecureTokenStorage();
    final http = HttpClient(config, storage);
    final api = ProfileApiImpl(http.dio);
    final repo = ProfileRepository(api: api);
    final appState = Provider.of<AppState>(context, listen: false);

    return ChangeNotifierProvider(
      create: (_) {
        final vm = ProfileProvider(repo: repo, storage: storage, appState: appState);
        vm.loadProfile();
        return vm;
      },
      child: Consumer<ProfileProvider>(
        builder: (context, vm, _) {
          final theme = Theme.of(context);
          Widget content;
          if (vm.isLoading) {
            content = const Center(child: CircularProgressIndicator());
          } else if (vm.sessionExpired) {
            content = Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 48),
                  const SizedBox(height: 12),
                  const Text('Sesión expirada'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      appState.setPath(AppRoutePath.login);
                    },
                    child: const Text('Ir a iniciar sesión'),
                  ),
                ],
              ),
            );
          } else if (vm.errorMessage != null) {
            content = Center(child: Text(vm.errorMessage!));
          } else {
            final u = vm.user;
            content = RefreshIndicator(
              onRefresh: vm.refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 12),
                      title: Text('Perfil'),
                    ),
                    toolbarHeight: 56,
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ProfileHeader(
                          user: u,
                          onEdit: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Editar perfil próximamente')),
                            );
                          },
                        ),
                        const SizedBox(height: 72),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              LayoutBuilder(
                                builder: (context, c) {
                                  final isWide = c.maxWidth >= 700;
                                  final items = [
                                    MetricCard(
                                      label: 'Cuenta activa',
                                      value: (u?.isActive ?? false) ? 'Sí' : 'No',
                                      icon: Icons.verified_user,
                                    ),
                                    MetricCard(
                                      label: 'Antigüedad (días)',
                                      value: u == null ? '—' : '${DateTime.now().difference(u.createdAt).inDays}',
                                      icon: Icons.calendar_today,
                                    ),
                                    MetricCard(
                                      label: 'Última actualización (días)',
                                      value: u == null ? '—' : '${DateTime.now().difference(u.updatedAt).inDays}',
                                      icon: Icons.update,
                                    ),
                                  ];
                                  if (isWide) {
                                    return Row(
                                      children: [
                                        Expanded(child: items[0]),
                                        const SizedBox(width: 12),
                                        Expanded(child: items[1]),
                                        const SizedBox(width: 12),
                                        Expanded(child: items[2]),
                                      ],
                                    );
                                  }
                                  return Column(
                                    children: [
                                      items[0],
                                      const SizedBox(height: 12),
                                      items[1],
                                      const SizedBox(height: 12),
                                      items[2],
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              InfoRow(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value: u?.email ?? '',
                                onTap: () async {
                                  await vm.copyEmail();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Email copiado')),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  StatusBadge(isActive: u?.isActive ?? false),
                                  const SizedBox(width: 8),
                                  Tooltip(
                                    message: 'Estado de la cuenta',
                                    child: const Icon(Icons.info_outline),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, c) {
                                  final isWide = c.maxWidth >= 600;
                                  final children = [
                                    DetailItem(
                                      label: 'Rol',
                                      value: u == null ? '' : ProfileProvider.translateRole(u.role),
                                      tooltip: 'Rol del usuario en la aplicación',
                                    ),
                                    DetailItem(
                                      label: 'Creado',
                                      value: u == null ? '' : ProfileProvider.formatDate(u.createdAt),
                                      tooltip: 'Fecha de creación de la cuenta',
                                    ),
                                    DetailItem(
                                      label: 'Actualizado',
                                      value: u == null ? '' : ProfileProvider.formatDate(u.updatedAt),
                                      tooltip: 'Última actualización de la cuenta',
                                    ),
                                  ];
                                  if (isWide) {
                                    return Row(
                                      children: [
                                        Expanded(child: children[0]),
                                        const SizedBox(width: 12),
                                        Expanded(child: children[1]),
                                        const SizedBox(width: 12),
                                        Expanded(child: children[2]),
                                      ],
                                    );
                                  }
                                  return Column(
                                    children: [
                                      children[0],
                                      const SizedBox(height: 12),
                                      children[1],
                                      const SizedBox(height: 12),
                                      children[2],
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Bitácoras recientes', style: theme.textTheme.titleMedium),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(child: _PlaceholderTile(icon: Icons.menu_book, label: 'Sin registros')),
                                        const SizedBox(width: 12),
                                        Expanded(child: _PlaceholderTile(icon: Icons.explore, label: 'Explora rutas')),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // sección de características principales eliminada
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Scaffold(
            backgroundColor: AppTheme.background,
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: content,
            ),
          );
        },
      ),
    );
  }
}

class _PlaceholderTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlaceholderTile({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.primaryMint),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
