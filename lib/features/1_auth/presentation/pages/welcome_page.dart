import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Importa tus componentes reutilizables
import '../widgets/auth_logo.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_bottom_prompt.dart';

// Importa tu tema y ViewModel
import 'package:kamino_fr/core/app_theme.dart';
import '../provider/welcome_provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      // Hacemos la barra transparente para que se vea el degradado (o negro si prefieres)
      statusBarColor: Colors.transparent, 
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return ChangeNotifierProvider(
      create: (_) => WelcomeProvider(),
      child: Scaffold(
        // 1. Quitamos el color sólido del Scaffold
        // backgroundColor: AppTheme.textBlack, 
        
        // 2. Usamos un Container con BoxDecoration para el degradado
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center, // El punto de luz en el centro
              radius: 1.3, // Qué tanto se expande la luz
              colors: [
                Color(0xFF2C303A), // Centro: Un gris azulado sutil (la luz)
                AppTheme.textBlack, // Bordes: Tu negro mate (la oscuridad)
              ],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: Consumer<WelcomeProvider>(
              builder: (context, provider, child) {
                // --- TU LÓGICA RESPONSIVA ORIGINAL ---
                final size = MediaQuery.of(context).size;
                final insets = MediaQuery.of(context).padding;
                final viewportHeight = size.height - insets.top - insets.bottom;
                final gapTop = (viewportHeight * 0.08).clamp(24.0, 64.0).toDouble();
                final gapL = (viewportHeight * 0.04).clamp(16.0, 40.0).toDouble();
                final small = viewportHeight < 640;
                final titleSize = small ? 24.0 : 28.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: SizedBox(
                        height: viewportHeight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                SizedBox(height: gapTop),
                                const AuthLogo(size: 120),
                                SizedBox(height: gapL),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                    children: const [
                                      TextSpan(text: 'Conecta. '),
                                      TextSpan(
                                        text: 'Descubre.',
                                        style: TextStyle(color: AppTheme.primaryMint),
                                      ),
                                      TextSpan(text: ' Avanza.'),
                                    ],
                                  ),
                                ),
                                SizedBox(height: gapL * 3.0),
                                // Imagen 3D del mapa
                                ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: FractionallySizedBox(
                                    widthFactor: small ? 0.95 : 0.85,
                                    child: Image.asset(
                                      'assets/images/3dmapa.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/Welcome_img.png',
                                          fit: BoxFit.contain,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                AuthPrimaryButton(
                                  text: 'Registrate',
                                  isLoading: false,
                                  onPressed: () => provider.navigateToRegister(context),
                                ),
                                const SizedBox(height: 16),
                                AuthBottomPrompt(
                                  text: 'Ya tienes cuenta? ',
                                  actionText: 'Inicia Sesion',
                                  onTap: () => provider.navigateToLogin(context),
                                ),
                                SizedBox(height: gapL),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
