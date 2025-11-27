import 'package:flutter/material.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_input.dart';

class RegisterNamesSection extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final double gap;

  const RegisterNamesSection({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    this.gap = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AuthInput(
            controller: firstNameController,
            hintText: 'Nombre',
            labelText: 'Nombre',
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es obligatorio';
              }
              return null;
            },
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: AuthInput(
            controller: lastNameController,
            hintText: 'Apellido',
            labelText: 'Apellido',
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El apellido es obligatorio';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}