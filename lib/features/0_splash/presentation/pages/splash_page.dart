import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/core/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:kamino_fr/core/auth/token_storage.dart';
import 'package:kamino_fr/core/auth/jwt_utils.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final storage = SecureTokenStorage();
    final token = await storage.getAccessToken();
    if (token != null && token.isNotEmpty && JwtUtils.isValid(token)) {
      appState.login();
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      context.go('/home');
    } else {
      await storage.clearTokens();
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Image.asset('assets/images/logo.png', width: 180),
      ),
    );
  }
}