import 'package:flutter/material.dart';

// --- ARREGLO 1: IMPORTA LOS ARCHIVOS ---
// Necesitas importar las clases que estás usando.
// (Asegúrate de que estas rutas coincidan con tu estructura de carpetas)
import 'core/app_theme.dart';
import 'features/1_auth/presentation/pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kmino',
      debugShowCheckedModeBanner: false,
      
      // Esto ahora funcionará gracias a la importación
      theme: AppTheme.getTheme(),
      
      // --- ARREGLO 2: QUITA EL 'const' ---
      // LoginPage no es una constante, así que quitamos 'const'
      home: LoginPage(), 
    );
  }
}