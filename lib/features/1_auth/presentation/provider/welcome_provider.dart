import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/core/app_router.dart';

class WelcomeProvider extends ChangeNotifier {

  void navigateToRegister(BuildContext context) {
    context.read<AppState>().setPath(AppRoutePath.register);
  }

  void navigateToLogin(BuildContext context) {
    context.read<AppState>().setPath(AppRoutePath.login);
  }
}