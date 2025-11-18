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
      style: const TextStyle(fontSize: 16, color: AppTheme.primaryMintDark),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: null,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.primaryMintDark) : null,
        filled: true,
        fillColor: AppTheme.background.withValues(alpha: 0.92),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppTheme.primaryMintDark,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppTheme.primaryMintDark, width: 2.5),
        ),
        hintStyle: const TextStyle(color: AppTheme.primaryMintDark),
        labelStyle: const TextStyle(color: AppTheme.textBlack),
        errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
      ),
    );
  }
}