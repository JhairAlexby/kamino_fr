import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_router.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/features/1_auth/data/auth_repository.dart';

class LoginProvider extends ChangeNotifier {

  LoginProvider(this._repo);

  final AuthRepository _repo;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;
  bool _statusIsError = false;
  bool get statusIsError => _statusIsError;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners(); 
  }

  Future<void> login(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return; 
    }

    _isLoading = true;
    _statusMessage = null;
    _statusIsError = false;
    notifyListeners(); 
    final email = emailController.text.trim();
    final password = passwordController.text;
    try {
      await _repo.login(email: email, password: password);
      _statusMessage = 'Sesión iniciada';
      _statusIsError = false;
      _isLoading = false;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!context.mounted) return;
      context.read<AppState>().login();
      context.read<AppState>().setPath(AppRoutePath.home);
    } catch (e) {
      _isLoading = false;
      _statusMessage = 'No se pudo iniciar sesión';
      _statusIsError = true;
      notifyListeners();
      return;
    }
    _isLoading = false;
    notifyListeners(); 
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
