import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:provider/provider.dart';
import '../provider/register_provider.dart';
import 'package:kamino_fr/core/app_router.dart';
import 'package:kamino_fr/features/1_auth/data/auth_repository.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_header.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_input.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_primary_button.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_logo.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_bottom_prompt.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => RegisterProvider(ctx.read<AuthRepository>()),
      child: Scaffold(
        backgroundColor: AppTheme.textBlack,
        body: SafeArea(
          child: Consumer<RegisterProvider>(
            builder: (context, provider, child) {
              final isLoading = provider.isLoading;
              final size = MediaQuery.of(context).size;
              final insets = MediaQuery.of(context).padding;
              final viewportHeight = size.height - insets.top - insets.bottom;
              final small = viewportHeight < 640;
              final gapXL = (viewportHeight * 0.04).clamp(12.0, 32.0).toDouble();
              final gapL = (viewportHeight * 0.03).clamp(10.0, 24.0).toDouble();
              final gapM = (viewportHeight * 0.018).clamp(8.0, 16.0).toDouble();
              final gapS = (viewportHeight * 0.01).clamp(6.0, 12.0).toDouble();
              final titleSize = small ? 22.0 : 26.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    title: 'Hola!',
                    subtitle: 'Estas listo para una nueva aventura?',
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: gapXL),
                              Text(
                                'Crear Cuenta',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: gapM),
                              Form(
                                key: provider.formKey,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AuthInput(
                                            controller: provider.firstNameController,
                                            hintText: 'Nombre',
                                            keyboardType: TextInputType.name,
                                            validator: (value) {
                                              if (value == null || value.trim().isEmpty) {
                                                return 'El nombre es obligatorio';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        SizedBox(width: gapS),
                                        Expanded(
                                          child: AuthInput(
                                            controller: provider.lastNameController,
                                            hintText: 'Apellido',
                                            keyboardType: TextInputType.name,
                                            validator: (value) {
                                              if (value == null || value.trim().isEmpty) {
                                                return 'El apellido es obligatorio';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
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
                              const Spacer(),
                              AuthPrimaryButton(
                                text: 'Registrarse',
                                isLoading: isLoading,
                                onPressed: isLoading ? null : () => context.read<RegisterProvider>().register(context),
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
                                child: AuthLogo(size: 56),
                              ),
                              SizedBox(height: gapM),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
