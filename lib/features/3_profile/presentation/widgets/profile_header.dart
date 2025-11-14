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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightMintBackground,
            AppTheme.primaryMint.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppTheme.background,
            child: Icon(Icons.person, color: AppTheme.textBlack, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    name.isEmpty ? ' ' : name,
                    key: ValueKey(name),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Perfil de usuario',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onEdit,
            child: const Text('Editar perfil'),
          )
        ],
      ),
    );
  }
}

