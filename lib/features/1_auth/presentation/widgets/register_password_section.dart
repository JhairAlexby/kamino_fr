import 'package:flutter/material.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_input.dart';

class RegisterPasswordSection extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final double gap;

  const RegisterPasswordSection({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    this.gap = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthInput(
          controller: passwordController,
          hintText: 'Contraseña',
          labelText: 'Contraseña',
          prefixIcon: Icons.lock_outline,
          obscureText: obscurePassword,
          onToggleObscure: onTogglePassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La contraseña es obligatoria';
            }
            if (value.length < 6) {
              return 'La contraseña debe tener al menos 6 caracteres';
            }
            return null;
          },
        ),
        SizedBox(height: gap),
        AuthInput(
          controller: confirmPasswordController,
          hintText: 'Confirmar Contraseña',
          labelText: 'Confirmar Contraseña',
          prefixIcon: Icons.lock_outline,
          obscureText: obscureConfirmPassword,
          onToggleObscure: onToggleConfirmPassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Confirma tu contraseña';
            }
            if (value != passwordController.text) {
              return 'Las contraseñas no coinciden';
            }
            return null;
          },
        ),
      ],
    );
  }
}