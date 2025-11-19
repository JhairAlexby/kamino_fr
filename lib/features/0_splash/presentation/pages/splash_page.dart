import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/core/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:kamino_fr/core/auth/token_storage.dart';
import 'package:kamino_fr/core/auth/jwt_utils.dart';
import 'package:kamino_fr/config/environment_config.dart';
import 'package:kamino_fr/core/network/http_client.dart';
import 'package:kamino_fr/features/1_auth/data/auth_api.dart';

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
      if (!mounted) return;
      context.go('/home');
      return;
    }
    final refresh = await storage.getRefreshToken();
    if (refresh != null && refresh.isNotEmpty) {
      try {
        final config = Provider.of<EnvironmentConfig>(context, listen: false);
        final http = HttpClient(config, storage);
        final api = AuthApiImpl(http.dio);
        final r = await api.refresh(refreshToken: refresh);
        await storage.saveTokens(accessToken: r.accessToken, refreshToken: r.refreshToken);
        appState.login();
        if (!mounted) return;
        context.go('/home');
        return;
      } catch (_) {
        await storage.clearTokens();
      }
    }
    if (!mounted) return;
    context.go('/welcome');
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