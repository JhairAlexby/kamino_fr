import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:kamino_fr/features/3_profile/presentation/widgets/profile_header.dart';
import 'package:kamino_fr/features/3_profile/presentation/widgets/profile_interests_section.dart';
import 'package:kamino_fr/features/3_profile/presentation/widgets/profile_data_section.dart';
import 'package:kamino_fr/features/3_profile/presentation/widgets/profile_change_password_dialog.dart';
import 'package:kamino_fr/features/3_profile/presentation/widgets/profile_settings_modal.dart';
import 'package:kamino_fr/features/3_profile/presentation/widgets/profile_action_buttons.dart';
import 'package:kamino_fr/features/3_profile/presentation/widgets/profile_logs_tab.dart';
import 'package:kamino_fr/core/utils/app_animations.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/features/3_profile/presentation/provider/profile_provider.dart';
import 'package:dio/dio.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedSection = 0;
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final Set<String> _interests = {};
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
      _interests
        ..clear()
        ..addAll(user.preferredTags);
      _areControllersInitialized = true;
    } else if (user == null) {
      _areControllersInitialized = false;
      _firstNameCtrl.clear();
      _lastNameCtrl.clear();
      _interests.clear();
    }

    return Scaffold(
      backgroundColor: AppTheme.textBlack,
      body: SafeArea(
        left: false,
        right: false,
        top: false,
        bottom: true,
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                            
                            // REEMPLAZO POR COMPONENTE
                            ProfileActionButtons(
                              onChangePassword: _showChangePasswordDialog,
                              onSaveChanges: () async {
                                try {
                                  await profileProvider.updateProfileData(
                                    firstName: _firstNameCtrl.text.trim(),
                                    lastName: _lastNameCtrl.text.trim(),
                                    tags: _interests.toList(),
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Datos actualizados'),
                                        backgroundColor: Colors.green,
                                      )
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    String msg = 'No se pudo actualizar los datos';
                                    if (e is DioException) {
                                      final data = e.response?.data;
                                      if (data is Map && data['message'] != null) {
                                         msg = data['message'].toString();
                                      } else if (data is Map && data['error'] != null) {
                                         msg = data['error'].toString();
                                      }
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(msg),
                                        backgroundColor: Colors.redAccent,
                                      )
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        )
                      : const ProfileLogsTab(key: ValueKey('bitacoras')),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
          ],
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
    AppAnimations.showFluidDialog(
      context: context,
      builder: (context) => const ProfileChangePasswordDialog(),
    );
  }

  void _showSettings(BuildContext context) {
    AppAnimations.showFluidModalBottomSheet(
      context: context,
      builder: (context) => const ProfileSettingsModal(),
    );
  }
}