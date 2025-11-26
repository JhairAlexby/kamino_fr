import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para la barra transparente
import 'package:kamino_fr/core/app_theme.dart';
import 'package:provider/provider.dart';
import '../provider/register_provider.dart';
import 'package:kamino_fr/features/1_auth/data/auth_repository.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_header.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_input.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_primary_button.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_logo.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_bottom_prompt.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    
    // 1. Barra de estado transparente para que se vea el degradado
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return ChangeNotifierProvider(
      create: (ctx) => RegisterProvider(ctx.read<AuthRepository>()),
      child: Scaffold(
        // Quitamos el color sólido para que se vea el degradado del Container
        // backgroundColor: AppTheme.textBlack,
        
        // 2. Fondo con Degradado Radial (Tu requerimiento visual)
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.3,
              colors: [
                Color(0xFF2C303A), // Centro iluminado
                AppTheme.textBlack, // Bordes oscuros
              ],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: Consumer<RegisterProvider>(
              builder: (context, provider, child) {
                final isLoading = provider.isLoading;
                final size = MediaQuery.of(context).size;
                final insets = MediaQuery.of(context).padding;
                final viewportHeight = size.height - insets.top - insets.bottom;
                final small = viewportHeight < 640;
                
                // Tus cálculos de espaciado originales
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
                            child: SingleChildScrollView(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                              ),
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
                                  
                                  // Tu Formulario Original (Sin cambios de lógica)
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
                                                labelText: 'Nombre',
                                                prefixIcon: Icons.person_outline,
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
                                                labelText: 'Apellido',
                                                prefixIcon: Icons.person_outline,
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
                                          labelText: 'Correo Electrónico',
                                          prefixIcon: Icons.email_outlined,
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
                                        
                                        // Selector de Género
                                        DropdownButtonFormField<String>(
                                          value: provider.gender,
                                          items: const [
                                            DropdownMenuItem(value: 'MALE', child: Text('Hombre')),
                                            DropdownMenuItem(value: 'FEMALE', child: Text('Mujer')),
                                            DropdownMenuItem(value: 'NON_BINARY', child: Text('No binario')),
                                            DropdownMenuItem(value: 'OTHER', child: Text('Otro')),
                                          ],
                                          onChanged: (v) {
                                            if (v != null) provider.setGender(v);
                                          },
                                          style: const TextStyle(fontSize: 16, color: Colors.white),
                                          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryMintDark),
                                          dropdownColor: const Color(0xFF2C303A),
                                          decoration: InputDecoration(
                                            labelText: 'Género',
                                            hintText: 'Género',
                                            
                                            // Icono del dropdown
                                            prefixIcon: const Icon(Icons.wc),
                                            prefixIconColor: WidgetStateColor.resolveWith((states) =>
                                                states.contains(WidgetState.focused)
                                                    ? AppTheme.primaryMint
                                                    : AppTheme.primaryMintDark),
                                                    
                                            // Fondo glass
                                            filled: true,
                                            fillColor: Colors.white.withValues(alpha: 0.05),
                                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                            
                                            // Bordes
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: const BorderSide(color: AppTheme.primaryMint, width: 2.0),
                                            ),
                                            
                                            // Textos
                                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                                            labelStyle: const TextStyle(color: AppTheme.primaryMintDark),
                                            floatingLabelStyle: const TextStyle(color: AppTheme.primaryMint, fontWeight: FontWeight.w600),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Selecciona un género';
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: gapS),
                                        
                                        AuthInput(
                                          controller: provider.passwordController,
                                          hintText: 'Contraseña',
                                          labelText: 'Contraseña',
                                          prefixIcon: Icons.lock_outline,
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
                                        SizedBox(height: gapS),
                                        AuthInput(
                                          controller: provider.confirmPasswordController,
                                          hintText: 'Confirmar Contraseña',
                                          labelText: 'Confirmar Contraseña',
                                          prefixIcon: Icons.lock_outline,
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
                                  
                                  // Spacer no funciona bien dentro de SingleChildScrollView, usamos SizedBox dinámico
                                  // o simplemente dejamos que fluya con el gapL
                                  SizedBox(height: gapL),
                                  
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
                                      context.push('/login');
                                    },
                                  ),
                                  
                                  SizedBox(height: gapL + gapS),
                                  
                                  const Align(
                                    alignment: Alignment.center,
                                    child: AuthLogo(size: 56),
                                  ),
                                  
                                  SizedBox(height: gapXL),
                                ],
                              ),
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
      ),
    );
  }
}