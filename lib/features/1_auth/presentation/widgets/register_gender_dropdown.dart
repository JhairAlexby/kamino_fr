import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';

class RegisterGenderDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const RegisterGenderDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: const [
        DropdownMenuItem(value: 'MALE', child: Text('Hombre', style: TextStyle(color: Colors.white))),
        DropdownMenuItem(value: 'FEMALE', child: Text('Mujer', style: TextStyle(color: Colors.white))),
        DropdownMenuItem(value: 'NON_BINARY', child: Text('No binario', style: TextStyle(color: Colors.white))),
        DropdownMenuItem(value: 'OTHER', child: Text('Otro', style: TextStyle(color: Colors.white))),
      ],
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 16, 
        color: Colors.white, 
        fontWeight: FontWeight.w600, // Consistent bold
        fontFamily: 'Inter',
      ),
      icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryMintDark),
      dropdownColor: const Color(0xFF2C303A),
      hint: Text(
        'Género',
        style: TextStyle(
          color: AppTheme.primaryMintDark,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
      decoration: InputDecoration(
        // labelText removed to avoid double label
        // hintText removed in favor of hint widget property for better control in Dropdown
        
        // Icono del dropdown
        prefixIcon: const Icon(Icons.wc),
        prefixIconColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.focused)
                ? AppTheme.primaryMint
                : AppTheme.primaryMintDark),
                
        // Fondo glass
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        
        // Bordes
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primaryMint, width: 2.0),
        ),
        
        // Textos
        // hintStyle removed as we use the hint widget
        labelStyle: const TextStyle(color: AppTheme.primaryMintDark),
        floatingLabelStyle: const TextStyle(color: AppTheme.primaryMint, fontWeight: FontWeight.w600),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Selecciona un género';
        }
        return null;
      },
    );
  }
}