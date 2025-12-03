import 'package:flutter/material.dart';

class AppAnimations {
  // Diálogo con efecto de escala y rebote suave (Pop-in)
  static Future<T?> showFluidDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.7), // Fondo más oscuro para resaltar
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return builder(context);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack, // Efecto de rebote suave al final
        );
        
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  // BottomSheet que desliza suavemente desde abajo
  static Future<T?> showFluidModalBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 400), // Duración controlada
      ),
      builder: builder, // El modal estándar ya tiene animación slide, pero podemos personalizarla si se requiere
    );
  }
}