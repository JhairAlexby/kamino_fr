import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:kamino_fr/features/1_auth/data/models/user.dart';

class ProfileHeader extends StatelessWidget {
  final User? user;
  final VoidCallback onEdit;
  const ProfileHeader({super.key, required this.user, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final u = user;
    final name = u == null ? '' : '${u.firstName} ${u.lastName}';
    final subtitle = u == null ? '' : 'Perfil ${u.isActive ? 'activo' : 'inactivo'}';

    return SizedBox(
      height: 240,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryMint,
                  AppTheme.primaryMint.withOpacity(0.85),
                  AppTheme.primaryMintDark.withOpacity(0.9),
                ],
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryMint.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Text(
                          name.isEmpty ? '' : name,
                          key: ValueKey(name),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.settings),
                      color: Colors.white,
                      onPressed: onEdit,
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.bar_chart, color: Colors.white70),
                  ],
                )
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 130,
            child: Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: AppTheme.background,
                  child: Icon(Icons.person, color: AppTheme.textBlack, size: 48),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
