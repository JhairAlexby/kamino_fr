import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';

class ProfileActionButtons extends StatelessWidget {
  final VoidCallback onChangePassword;
  final VoidCallback onSaveChanges;

  const ProfileActionButtons({
    super.key,
    required this.onChangePassword,
    required this.onSaveChanges,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton(
          onPressed: onChangePassword,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: const BorderSide(color: AppTheme.primaryMint),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Cambiar contraseña', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onSaveChanges,
          child: const Text('Guardar cambios'),
        ),
      ],
    );
  }
}