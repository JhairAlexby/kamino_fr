import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';

class AuthInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final String? labelText;
  final IconData? prefixIcon;
  final Iterable<String>? autofillHints;

  const AuthInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.obscureText = false,
    this.onToggleObscure,
    this.labelText,
    this.prefixIcon,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      autofillHints: autofillHints,
      // Texto blanco para mayor legibilidad
      style: const TextStyle(fontSize: 16, color: Colors.white),
      cursorColor: AppTheme.primaryMint,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        // Icono dinámico: Cambia de color al enfocar
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        prefixIconColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.focused)
                ? AppTheme.primaryMint
                : AppTheme.primaryMintDark),
        
        // Fondo sutil estilo "Glass"
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppTheme.primaryMintDark,
                ),
                onPressed: onToggleObscure,
              )
            : null,
            
        // Bordes redondeados y sutiles
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        
        // Borde enfocado brillante
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primaryMint, width: 2.0),
        ),
        
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        labelStyle: const TextStyle(color: AppTheme.primaryMintDark),
        floatingLabelStyle: const TextStyle(color: AppTheme.primaryMint, fontWeight: FontWeight.w600),
        errorStyle: const TextStyle(fontSize: 12, color: Color(0xFFFF6B6B)),
      ),
    );
  }
}