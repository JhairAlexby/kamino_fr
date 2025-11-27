import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';

class LoginErrorDisplay extends StatelessWidget {
  final String? message;
  final bool isError;

  const LoginErrorDisplay({
    super.key,
    this.message,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isError
            ? Colors.red.withValues(alpha: 0.15)
            : AppTheme.primaryMint.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? Colors.red : AppTheme.primaryMint,
        ),
      ),
      child: Text(
        message!,
        style: TextStyle(
          color: isError ? Colors.red : AppTheme.primaryMint,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}