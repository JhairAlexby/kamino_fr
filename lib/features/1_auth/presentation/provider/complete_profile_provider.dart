import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kamino_fr/features/3_profile/data/profile_repository.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/core/app_router.dart';
import 'package:dio/dio.dart';

class CompleteProfileProvider extends ChangeNotifier {
  final ProfileRepository repo;

  CompleteProfileProvider(this.repo);

  String? gender;
  int? age;
  final List<String> selectedInterests = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<String> availableInterests = [
    'Tradicional',
    'Música',
    'Cultura',
    'Educativo',
    'Arte',
    'Naturaleza',
    'Gastronomía',
    'Aventura',
    'Familia',
    'Ciencia',
    'Historia',
    'Tecnología',
  ];

  void setGender(String? value) {
    gender = value;
    notifyListeners();
  }

  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
    notifyListeners();
  }

  void setAge(String value) {
    final v = int.tryParse(value);
    if (v == null) {
      age = null;
    } else {
      age = v.clamp(0, 130);
    }
    notifyListeners();
  }

  Future<void> saveProfile(BuildContext context) async {
    if (gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona tu género')),
      );
      return;
    }
    if (selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un interés')),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await repo.updateProfile(gender: gender, age: age);
      await repo.updateTags(selectedInterests);
      _isLoading = false;
      notifyListeners();
      if (context.mounted) {
        context.read<AppState>().markProfileComplete();
        context.read<AppState>().clearRequireProfileCompletion();
        context.go('/home');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      String msg = 'Error al guardar perfil';
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['error'] is String) {
          msg = data['error'] as String;
        } else if (e.message != null) {
          msg = e.message!;
        }
      } else {
        msg = e.toString();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    }
  }
}