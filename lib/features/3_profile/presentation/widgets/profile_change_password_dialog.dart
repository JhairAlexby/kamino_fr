import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';

class ProfileChangePasswordDialog extends StatefulWidget {
  const ProfileChangePasswordDialog({super.key});

  @override
  State<ProfileChangePasswordDialog> createState() => _ProfileChangePasswordDialogState();
}

class _ProfileChangePasswordDialogState extends State<ProfileChangePasswordDialog> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2C303A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('Cambiar Contraseña', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _currentPasswordCtrl,
            obscureText: _obscureCurrent,
            style: const TextStyle(color: AppTheme.primaryMintDark),
            cursorColor: AppTheme.primaryMintDark,
            decoration: InputDecoration(
              labelText: 'Contraseña actual',
              labelStyle: const TextStyle(color: AppTheme.primaryMintDark),
              suffixIcon: IconButton(
                icon: Icon(_obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppTheme.primaryMintDark),
                onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _newPasswordCtrl,
            obscureText: _obscureNew,
            style: const TextStyle(color: AppTheme.primaryMintDark),
            cursorColor: AppTheme.primaryMintDark,
            decoration: InputDecoration(
              labelText: 'Nueva contraseña',
              labelStyle: const TextStyle(color: AppTheme.primaryMintDark),
              suffixIcon: IconButton(
                icon: Icon(_obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppTheme.primaryMintDark),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: () async {
             // Simulación de lógica de cambio de contraseña (aquí deberías llamar a tu repositorio)
             // Si falla:
             /*
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(
                 content: Text('Error al cambiar contraseña: [Razón]'),
                 backgroundColor: Colors.redAccent,
               ),
             );
             */
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contraseña actualizada correctamente')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryMint,
            foregroundColor: AppTheme.textBlack,
            elevation: 8,
            shadowColor: AppTheme.primaryMint.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Confirmar',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}