import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class WelcomeProvider extends ChangeNotifier {

  void navigateToRegister(BuildContext context) {
    context.push('/register');
  }

  void navigateToLogin(BuildContext context) {
    context.push('/login');
  }
}