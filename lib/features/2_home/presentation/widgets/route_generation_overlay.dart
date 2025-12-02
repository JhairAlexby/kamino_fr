import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';

class RouteGenerationOverlay extends StatefulWidget {
  final bool isVisible;

  const RouteGenerationOverlay({super.key, required this.isVisible});

  @override
  State<RouteGenerationOverlay> createState() => _RouteGenerationOverlayState();
}

class _RouteGenerationOverlayState extends State<RouteGenerationOverlay> with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _shimmerController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2)
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si no es visible, devolvemos un SizedBox.shrink() para no ocupar espacio,
    // pero AnimatedOpacity necesita que el widget esté en el árbol para animar la salida.
    // Sin embargo, si usamos este widget dentro de un Stack y controlamos su presencia
    // con un `if` en el padre, la animación de salida se perdería.
    // Lo ideal es que este widget SIEMPRE esté en el árbol pero con opacidad 0 y ignoringPointer
    // si queremos animar entrada y salida suavemente.
    // O bien, que el padre controle el `if` y aquí solo manejemos la construcción.
    
    // Para simplificar y mantener el comportamiento actual del `home_page.dart`:
    // El padre usa `if (_isGeneratingRoute)` para mostrarlo.
    // Así que aquí asumiremos que si se construye, se debe animar la entrada.
    // Pero el `AnimatedOpacity` en el padre estaba controlando la opacidad basada en el booleano.
    
    // Vamos a hacer que este widget reciba `isVisible` y maneje su propia opacidad y visibilidad.
    
    return IgnorePointer(
      ignoring: !widget.isVisible,
      child: AnimatedOpacity(
        opacity: widget.isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: Align(
              alignment: const Alignment(0, -0.2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Image.asset(
                      'assets/images/welcome_graphic.png',
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      final slide = _shimmerController.value * 2.0 - 1.0; // Rango de -1.0 a 1.0
                      return ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment(slide - 1.0, 0), // El gradiente se mueve de izquierda a derecha
                          end: Alignment(slide, 0),
                          colors: const [
                            AppTheme.primaryMint,
                            Colors.white,
                            AppTheme.primaryMint,
                          ],
                          stops: const [0.4, 0.5, 0.6],
                          tileMode: TileMode.clamp,
                        ).createShader(bounds),
                        child: child,
                      );
                    },
                    child: const Text(
                      'GENERANDO RUTA',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: AppTheme.primaryMintDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryMint),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}