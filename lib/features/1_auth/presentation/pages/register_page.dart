import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:provider/provider.dart';
import '../provider/register_provider.dart';
import 'package:kamino_fr/core/app_router.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_header.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_input.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_primary_button.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_logo.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_bottom_prompt.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterProvider(),
      child: Scaffold(
        backgroundColor: AppTheme.textBlack,
        body: SafeArea(
          child: Consumer<RegisterProvider>(
            builder: (context, provider, child) {
              final isLoading = provider.isLoading;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthHeader(
                      title: 'Hola!',
                      subtitle: 'Estas listo para una nueva aventura?',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40.0),
                          const Text(
                            'Crear Cuenta',
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
                                  controller: provider.nameController,
                                  hintText: 'Nombre',
                                  keyboardType: TextInputType.name,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'El nombre es obligatorio';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20.0),
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
                                      return 'Mínimo 6 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20.0),
                                AuthInput(
                                  controller: provider.confirmPasswordController,
                                  hintText: 'Confirmar Contraseña',
                                  obscureText: provider.obscureConfirmPassword,
                                  onToggleObscure: provider.toggleConfirmPasswordVisibility,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Confirma tu contraseña';
                                    }
                                    if (value != provider.passwordController.text) {
                                      return 'Las contraseñas no coinciden';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25.0),
                          AuthPrimaryButton(
                            text: 'Registrarse',
                            isLoading: isLoading,
                            onPressed: isLoading ? null : () => context.read<RegisterProvider>().register(),
                          ),
                          const SizedBox(height: 30.0),
                          AuthBottomPrompt(
                            text: 'Ya tienes cuenta? ',
                            actionText: 'Inicia Sesion',
                            onTap: () {
                              context.read<AppState>().setPath(AppRoutePath.login);
                            },
                          ),
                          const SizedBox(height: 5.0),
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