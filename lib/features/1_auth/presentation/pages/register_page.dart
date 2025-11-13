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
              final size = MediaQuery.of(context).size;
              final gapXL = (size.height * 0.06).clamp(32.0, 60.0) as double;
              final gapL = (size.height * 0.04).clamp(20.0, 40.0) as double;
              final gapM = (size.height * 0.025).clamp(14.0, 28.0) as double;
              final gapS = (size.height * 0.018).clamp(10.0, 22.0) as double;
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthHeader(
                      title: 'Hola!',
                      subtitle: 'Estas listo para una nueva aventura?',
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
                            'Crear Cuenta',
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
                                SizedBox(height: gapS),
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
                                      return 'Mínimo 6 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: gapS),
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
                          SizedBox(height: gapM),
                          AuthPrimaryButton(
                            text: 'Registrarse',
                            isLoading: isLoading,
                            onPressed: isLoading ? null : () => context.read<RegisterProvider>().register(),
                          ),
                          SizedBox(height: gapL),
                          AuthBottomPrompt(
                            text: 'Ya tienes cuenta? ',
                            actionText: 'Inicia Sesion',
                            onTap: () {
                              context.read<AppState>().setPath(AppRoutePath.login);
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
