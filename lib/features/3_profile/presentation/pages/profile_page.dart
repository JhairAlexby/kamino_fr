import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:kamino_fr/features/3_profile/presentation/widgets/profile_header.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedSection = 0;
  final _firstNameCtrl = TextEditingController(text: 'Nombre');
  final _lastNameCtrl = TextEditingController(text: 'Apellido');
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final Set<String> _interests = {'parques'};

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sidePad = (size.width * 0.05).clamp(16.0, 24.0).toDouble();

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
                  name: 'Nombre Usuario',
                  email: 'Correo@gmail.com',
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
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C303A).withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tus intereses',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        for (final opt in const ['parques', 'restaurantes', 'urbano', 'cine', 'deportivo'])
                                          TweenAnimationBuilder<double>(
                                            duration: const Duration(milliseconds: 200),
                                            curve: Curves.easeInOut,
                                            tween: Tween<double>(begin: 1.0, end: _interests.contains(opt) ? 1.05 : 1.0),
                                            builder: (context, scale, child) {
                                              return Transform.scale(
                                                scale: scale,
                                                child: FilterChip(
                                                  selected: _interests.contains(opt),
                                                  onSelected: (v) => setState(() {
                                                    if (v) {
                                                      _interests.add(opt);
                                                    } else {
                                                      _interests.remove(opt);
                                                    }
                                                  }),
                                                  label: Text(opt, style: TextStyle(color: _interests.contains(opt) ? Colors.white : AppTheme.textBlack)),
                                                  selectedColor: AppTheme.primaryMint,
                                                  backgroundColor: Theme.of(context).cardColor,
                                                  checkmarkColor: Colors.white,
                                                  showCheckmark: false,
                                                ),
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C303A).withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Edita tus datos para mantener tu perfil actualizado',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _firstNameCtrl,
                                      style: const TextStyle(color: AppTheme.primaryMintDark),
                                      cursorColor: AppTheme.primaryMintDark,
                                      decoration: const InputDecoration(
                                        labelText: 'Nombre',
                                        prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryMintDark),
                                        labelStyle: TextStyle(color: AppTheme.primaryMintDark),
                                        hintStyle: TextStyle(color: AppTheme.primaryMintDark),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _lastNameCtrl,
                                      style: const TextStyle(color: AppTheme.primaryMintDark),
                                      cursorColor: AppTheme.primaryMintDark,
                                      decoration: const InputDecoration(
                                        labelText: 'Apellido',
                                        prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryMintDark),
                                        labelStyle: TextStyle(color: AppTheme.primaryMintDark),
                                        hintStyle: TextStyle(color: AppTheme.primaryMintDark),
                                      ),
                                    ),
                                  ],
                                ),
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
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    super.dispose();
  }

  void _showChangePasswordDialog() {
    bool obscureCurrent = true;
    bool obscureNew = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2C303A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: const Text('Cambiar Contraseña', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _currentPasswordCtrl,
                    obscureText: obscureCurrent,
                    style: const TextStyle(color: AppTheme.primaryMintDark),
                    cursorColor: AppTheme.primaryMintDark,
                    decoration: InputDecoration(
                      labelText: 'Contraseña actual',
                      labelStyle: const TextStyle(color: AppTheme.primaryMintDark),
                      suffixIcon: IconButton(
                        icon: Icon(obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppTheme.primaryMintDark),
                        onPressed: () => setStateDialog(() => obscureCurrent = !obscureCurrent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _newPasswordCtrl,
                    obscureText: obscureNew,
                    style: const TextStyle(color: AppTheme.primaryMintDark),
                    cursorColor: AppTheme.primaryMintDark,
                    decoration: InputDecoration(
                      labelText: 'Nueva contraseña',
                      labelStyle: const TextStyle(color: AppTheme.primaryMintDark),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppTheme.primaryMintDark),
                        onPressed: () => setStateDialog(() => obscureNew = !obscureNew),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contraseña actualizada correctamente')),
                    );
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C303A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop(); // Cierra el bottom sheet
                  _showLogoutConfirmationDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C303A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Confirmar Cierre de Sesión', style: TextStyle(color: Colors.white)),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                // Aquí va la lógica para cerrar sesión
                Navigator.of(context).pop(); // Cierra el diálogo
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sesión cerrada exitosamente')),
                );
                // Por ejemplo, podrías navegar a la pantalla de login:
                // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (c) => LoginPage()), (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryMint,
              ),
              child: const Text('Confirmar', style: TextStyle(color: AppTheme.textBlack)),
            ),
          ],
        );
      },
    );
  }
}