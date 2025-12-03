import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/features/3_profile/presentation/provider/profile_provider.dart';

class ProfileSettingsModal extends StatelessWidget {
  const ProfileSettingsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2C303A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.of(context).pop(); // Cierra el bottom sheet
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C303A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Confirmar Cierre de Sesión', style: TextStyle(color: Colors.white)),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                context.read<ProfileProvider>().appState.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryMint,
              ),
              child: const Text('Confirmar', style: TextStyle(color: AppTheme.textBlack)),
            ),
          ],
        );
      },
    );
  }
}