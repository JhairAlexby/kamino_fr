import 'package:flutter/material.dart';

class WelcomeProvider extends ChangeNotifier {
  // Aquí puedes añadir lógica de negocio si la pantalla la requiere.
  // Por ahora, solo manejaremos la navegación.

  void navigateToRegister(BuildContext context) {
    // Implementa la navegación a la pantalla de registro
    // Por ejemplo:
    // Navigator.pushNamed(context, '/register'); 
    // Por ahora, solo un placeholder
    print('Navegando a Registro');
    // Si ya tienes las rutas definidas, usarías algo como:
    // Navigator.pushNamed(context, AppRoutes.register);
  }

  void navigateToLogin(BuildContext context) {
    // Implementa la navegación a la pantalla de login
    // Por ejemplo:
    // Navigator.pushNamed(context, '/login');
    // Por ahora, solo un placeholder
    print('Navegando a Login');
    // Si ya tienes las rutas definidas, usarías algo como:
    // Navigator.pushNamed(context, AppRoutes.login);
  }
}