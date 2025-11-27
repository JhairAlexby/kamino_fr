import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:kamino_fr/features/3_profile/presentation/widgets/profile_header.dart';
import 'package:kamino_fr/features/3_profile/presentation/widgets/profile_interests_section.dart';
import 'package:kamino_fr/features/3_profile/presentation/widgets/profile_data_section.dart';
import 'package:kamino_fr/features/3_profile/presentation/widgets/profile_change_password_dialog.dart';
import 'package:kamino_fr/features/3_profile/presentation/widgets/profile_settings_modal.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/features/3_profile/presentation/provider/profile_provider.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedSection = 0;
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final Set<String> _interests = {'parques'};
  bool _areControllersInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sidePad = (size.width * 0.05).clamp(16.0, 24.0).toDouble();

    final profileProvider = context.watch<ProfileProvider>();
    final user = profileProvider.user;

    if (user != null && !_areControllersInitialized) {
      _firstNameCtrl.text = user.firstName;
      _lastNameCtrl.text = user.lastName;
      _areControllersInitialized = true;
    } else if (user == null) {
      _areControllersInitialized = false;
      _firstNameCtrl.clear();
      _lastNameCtrl.clear();
    }

    return Scaffold(
      backgroundColor: AppTheme.textBlack,
      body: SafeArea(
        left: false,
        right: false,
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileHeader(
                isLoading: profileProvider.isLoading,
                name: user != null ? '${user.firstName} ${user.lastName}' : 'Cargando...',
                email: user?.email ?? '',
                selectedSection: _selectedSection,
                onSectionChange: (i) => setState(() => _selectedSection = i),
                onSettings: () => _showSettings(context),
                onStats: () {},
              ),
              const SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sidePad),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(anim),
                      child: child,
                    ),
                  ),
                  child: _selectedSection == 0
                      ? Column(
                          key: const ValueKey('datos'),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ProfileInterestsSection(
                              selectedInterests: _interests,
                              onToggleInterest: (opt) {
                                setState(() {
                                  if (_interests.contains(opt)) {
                                    _interests.remove(opt);
                                  } else {
                                    _interests.add(opt);
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            ProfileDataSection(
                              firstNameController: _firstNameCtrl,
                              lastNameController: _lastNameCtrl,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _showChangePasswordDialog,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: const BorderSide(color: AppTheme.primaryMint),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text('Cambiar contraseña', style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Datos guardados')));
                              },
                              child: const Text('Guardar cambios'),
                            ),
                          ],
                        )
                      : Column(
                          key: const ValueKey('bitacoras'),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text('Bitácoras recientes (placeholder)'),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => const ProfileChangePasswordDialog(),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C303A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ProfileSettingsModal(),
    );
  }
}