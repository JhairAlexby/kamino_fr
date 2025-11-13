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
              final insets = MediaQuery.of(context).padding;
              final viewportHeight = size.height - insets.top - insets.bottom;
              final small = viewportHeight < 640;
              final gapXL = (viewportHeight * 0.05).clamp(16.0, 40.0) as double;
              final gapL = (viewportHeight * 0.035).clamp(12.0, 28.0) as double;
              final gapM = (viewportHeight * 0.02).clamp(8.0, 20.0) as double;
              final gapS = (viewportHeight * 0.012).clamp(6.0, 14.0) as double;
              final titleSize = small ? 24.0 : 28.0;

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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
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
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
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
                                    child: AuthLogo(size: 56),
                                  ),
                                  SizedBox(height: gapXL),
                                ],
                              ),
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
