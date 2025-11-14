import 'package:kamino_fr/core/app_router.dart';
import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/features/1_auth/presentation/provider/login_provider.dart';
import 'package:kamino_fr/features/1_auth/data/auth_repository.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_header.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_input.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_primary_button.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_logo.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_bottom_prompt.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => LoginProvider(ctx.read<AuthRepository>()),
      child: Scaffold(
        backgroundColor: AppTheme.textBlack,
        body: SafeArea(
          child: Consumer<LoginProvider>(
            builder: (context, provider, child) {
              final isLoading = provider.isLoading;
              final size = MediaQuery.of(context).size;
              final gapXL = (size.height * 0.06).clamp(32.0, 60.0).toDouble();
              final gapL = (size.height * 0.04).clamp(20.0, 40.0).toDouble();
              final gapM = (size.height * 0.025).clamp(14.0, 28.0).toDouble();
              final gapS = (size.height * 0.018).clamp(10.0, 22.0).toDouble();
              final gapXS = (size.height * 0.012).clamp(6.0, 16.0).toDouble();
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthHeader(
                      title: 'Hola!',
                      subtitle: 'Bienvenido de vuelta',
                    ),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          SizedBox(height: gapXL),
                          const Text(
                            'Iniciar Sesion',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: gapM),
                          Form(
                            key: provider.formKey,
                            child: Column(
                              children: [
                                AuthInput(
                                  controller: provider.emailController,
                                  hintText: 'Tu@correo.com',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'El correo es obligatorio';
                                    }
                                    final email = value.trim();
                                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                                    if (!emailRegex.hasMatch(email)) {
                                      return 'Ingresa un correo válido';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: gapS),
                                AuthInput(
                                  controller: provider.passwordController,
                                  hintText: 'Contraseña',
                                  obscureText: provider.obscurePassword,
                                  onToggleObscure: provider.togglePasswordVisibility,
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
                                if (provider.statusMessage != null) ...[
                                  SizedBox(height: gapS),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: provider.statusIsError
                                          ? Colors.red.withValues(alpha: 0.15)
                                          : AppTheme.primaryMint.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: provider.statusIsError ? Colors.red : AppTheme.primaryMint,
                                      ),
                                    ),
                                    child: Text(
                                      provider.statusMessage!,
                                      style: TextStyle(
                                        color: provider.statusIsError ? Colors.red : AppTheme.primaryMint,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: gapXS),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  color: AppTheme.primaryMint,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: gapM),
                          AuthPrimaryButton(
                            text: 'Iniciar Sesión',
                            isLoading: isLoading,
                            onPressed: isLoading ? null : () => provider.login(context),
                          ),
                          SizedBox(height: gapL),
                          AuthBottomPrompt(
                            text: 'No tienes cuenta? ',
                            actionText: 'Registrate',
                            onTap: () {
                              context.read<AppState>().setPath(AppRoutePath.register);
                            },
                          ),
                          SizedBox(height: gapS),
                          const Align(
                            alignment: Alignment.center,
                            child: AuthLogo(size: 100),
                          ),
                          SizedBox(height: gapXL),
                          ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
