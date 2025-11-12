import 'package:kamino_fr/core/app_router.dart';
import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/features/1_auth/presentation/provider/login_provider.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_header.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_input.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_primary_button.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_logo.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_bottom_prompt.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginProvider(),
      child: Scaffold(
        backgroundColor: AppTheme.textBlack,
        body: SafeArea(
          child: Consumer<LoginProvider>(
            builder: (context, provider, child) {
              final isLoading = provider.isLoading;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthHeader(
                      title: 'Hola!',
                      subtitle: 'Bienvenido de vuelta',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 50.0),
                          const Text(
                            'Iniciar Sesion',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20.0),
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
                                    if (!RegExp(r"^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}")
                                        .hasMatch(value.trim())) {
                                      return 'Ingresa un correo válido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20.0),
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
                              ],
                            ),
                          ),
                          const SizedBox(height: 10.0),
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
                          const SizedBox(height: 25.0),
                          AuthPrimaryButton(
                            text: 'Iniciar Sesión',
                            isLoading: isLoading,
                            onPressed: isLoading ? null : () => provider.login(context),
                          ),
                          const SizedBox(height: 30.0),
                          AuthBottomPrompt(
                            text: 'No tienes cuenta? ',
                            actionText: 'Registrate',
                            onTap: () {
                              context.read<AppState>().setPath(AppRoutePath.register);
                            },
                          ),
                          const SizedBox(height: 20.0),
                          const Align(
                            alignment: Alignment.center,
                            child: AuthLogo(size: 100),
                          ),
                          const SizedBox(height: 50.0),
                        ],
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