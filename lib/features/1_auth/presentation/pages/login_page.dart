import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para la barra transparente
import 'package:go_router/go_router.dart'; // Navegación (Amigo)
import 'package:provider/provider.dart';

// Core y Tema
import 'package:kamino_fr/core/app_theme.dart';

// Lógica y Datos
import 'package:kamino_fr/features/1_auth/data/auth_repository.dart';
import 'package:kamino_fr/features/1_auth/presentation/provider/login_provider.dart';

// Widgets Reutilizables (El diseño visual de tu equipo)
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
    
    // 1. Configuración Visual: Barra transparente
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return ChangeNotifierProvider(
      // 2. Lógica: Inyección del Repositorio
      create: (ctx) => LoginProvider(ctx.read<AuthRepository>()),
      child: Scaffold(
        // 3. Visual: Fondo con Degradado Radial
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
            child: Consumer<LoginProvider>(
              builder: (context, provider, child) {
                final isLoading = provider.isLoading;
                
                // 4. Visual: Cálculos Responsivos (Tu lógica)
                final size = MediaQuery.of(context).size;
                final gapXL = (size.height * 0.06).clamp(32.0, 60.0).toDouble();
                final gapL = (size.height * 0.04).clamp(20.0, 40.0).toDouble();
                final gapM = (size.height * 0.025).clamp(14.0, 28.0).toDouble();
                final gapS = (size.height * 0.018).clamp(10.0, 22.0).toDouble();

                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      // Header del equipo
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
                                  'Iniciar Sesión',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                
                                SizedBox(height: gapM),

                                // Formulario usando los Widgets de tu amigo
                                Form(
                                  key: provider.formKey,
                                  child: Column(
                                    children: [
                                      AuthInput(
                                        controller: provider.emailController,
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
                                      
                                      SizedBox(height: gapS),
                                      
                                      AuthInput(
                                        controller: provider.passwordController,
                                        hintText: 'Contraseña',
                                        labelText: 'Contraseña',
                                        prefixIcon: Icons.lock_outline,
                                        obscureText: provider.obscurePassword,
                                        onToggleObscure: provider.togglePasswordVisibility,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) return 'La contraseña es obligatoria';
                                          return null;
                                        },
                                      ),

                                      // Mensaje de Error (Estilo visual de tu amigo)
                                      if (provider.statusMessage != null) ...[
                                        SizedBox(height: gapS),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: provider.statusIsError
                                                ? Colors.red.withOpacity(0.15)
                                                : AppTheme.primaryMint.withOpacity(0.15),
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
                                
                                SizedBox(height: gapS),
                                
                                // Olvidaste contraseña
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
                                
                                // Botón Principal (Widget de tu amigo)
                                AuthPrimaryButton(
                                  text: 'Iniciar Sesión',
                                  isLoading: isLoading,
                                  onPressed: isLoading ? null : () => provider.login(context),
                                ),
                                
                                SizedBox(height: gapL),
                                
                                // Prompt Inferior con GoRouter (Navegación de tu amigo)
                                AuthBottomPrompt(
                                  text: 'No tienes cuenta? ',
                                  actionText: 'Registrate',
                                  onTap: () {
                                    context.push('/register');
                                  },
                                ),
                                
                                SizedBox(height: gapL + gapS),
                                
                                // Logo (Widget de tu amigo)
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
      ),
    );
  }
}