import 'package:flutter/material.dart';
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
      theme: AppTheme.getTheme(),
      home: LoginPage(), 
    );
  }
}