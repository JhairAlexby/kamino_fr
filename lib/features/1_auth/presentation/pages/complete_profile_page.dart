import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:kamino_fr/features/3_profile/data/profile_repository.dart';
import 'package:kamino_fr/features/1_auth/presentation/provider/complete_profile_provider.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/register_gender_dropdown.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_primary_button.dart';

class CompleteProfilePage extends StatelessWidget {
  const CompleteProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<ProfileRepository>(context, listen: false);

    return ChangeNotifierProvider(
      create: (_) => CompleteProfileProvider(repo),
      child: Scaffold(
        backgroundColor: AppTheme.textBlack,
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            color: AppTheme.textBlack,
            child: Consumer<CompleteProfileProvider>(
              builder: (context, vm, _) {
                return AuthPrimaryButton(
                  text: 'Guardar y continuar',
                  isLoading: vm.isLoading,
                  onPressed: () {
                    if (vm.gender == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona tu género')));
                      return;
                    }
                    if (vm.age == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa tu edad')));
                      return;
                    }
                    if (vm.selectedInterests.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona al menos un interés')));
                      return;
                    }
                    vm.saveProfile(context);
                  },
                );
              },
            ),
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.3,
              colors: [Color(0xFF2C303A), AppTheme.textBlack],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: Consumer<CompleteProfileProvider>(
              builder: (context, vm, _) {
                final insets = MediaQuery.of(context).viewInsets.bottom;
                return SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: insets + 20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            const Text(
                              'Completa tu perfil',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Paso 2 de 2',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            RegisterGenderDropdown(
                              value: vm.gender,
                              onChanged: (v) => vm.setGender(v),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Edad',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 120,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                onChanged: vm.setAge,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                decoration: InputDecoration(
                                  hintText: 'Ej. 25',
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                  filled: true,
                                  fillColor: const Color(0xFF1E0B36),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Selecciona tus intereses',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                for (final opt in vm.availableInterests)
                                  TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    tween: Tween<double>(
                                      begin: 1.0,
                                      end: vm.selectedInterests.contains(opt) ? 1.05 : 1.0,
                                    ),
                                    builder: (context, scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: FilterChip(
                                          selected: vm.selectedInterests.contains(opt),
                                          onSelected: (_) => vm.toggleInterest(opt),
                                          label: Text(
                                            opt,
                                            style: TextStyle(
                                              color: vm.selectedInterests.contains(opt)
                                                  ? Colors.white
                                                  : AppTheme.textBlack,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          selectedColor: AppTheme.primaryMint,
                                          backgroundColor: Theme.of(context).cardColor,
                                          checkmarkColor: Colors.white,
                                          showCheckmark: true,
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}