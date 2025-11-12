import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_router.dart';
import 'package:provider/provider.dart';

class LoginProvider extends ChangeNotifier {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners(); 
  }

  Future<void> login(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return; 
    }

    _isLoading = true;
    notifyListeners(); 
    await Future.delayed(const Duration(seconds: 2));
    _isLoading = false;
    notifyListeners(); 

    context.read<AppState>().setPath(AppRoutePath.home);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}