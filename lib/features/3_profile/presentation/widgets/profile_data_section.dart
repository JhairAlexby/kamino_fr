import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kamino_fr/core/app_theme.dart';


class ProfileDataSection extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;

  const ProfileDataSection({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C303A).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
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
            controller: firstNameController,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
              LengthLimitingTextInputFormatter(50),
            ],
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
            controller: lastNameController,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
              LengthLimitingTextInputFormatter(50),
            ],
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
    );
  }
}