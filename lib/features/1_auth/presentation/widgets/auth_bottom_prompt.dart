import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';

class AuthBottomPrompt extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onTap;

  const AuthBottomPrompt({
    Key? key,
    required this.text,
    required this.actionText,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
          TextButton(
            onPressed: onTap,
            child: Text(
              actionText,
              style: const TextStyle(
                color: AppTheme.primaryMint,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}