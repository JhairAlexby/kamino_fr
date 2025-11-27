import 'package:flutter/material.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_input.dart';

class LoginInputsSection extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final double gap;

  const LoginInputsSection({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    this.gap = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthInput(
          controller: emailController,
          hintText: 'Tu@correo.com',
          labelText: 'Correo Electrónico',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'El correo es obligatorio';
            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) return 'Correo inválido';
            return null;
          },
        ),
        SizedBox(height: gap),
        AuthInput(
          controller: passwordController,
          hintText: 'Contraseña',
          labelText: 'Contraseña',
          prefixIcon: Icons.lock_outline,
          obscureText: obscurePassword,
          onToggleObscure: onTogglePassword,
          validator: (value) {
            if (value == null || value.isEmpty) return 'La contraseña es obligatoria';
            return null;
          },
        ),
      ],
    );
  }
}