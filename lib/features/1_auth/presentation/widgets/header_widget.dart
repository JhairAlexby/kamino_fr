import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';

class HeaderWidget extends StatelessWidget {
  final AnimationController animationController;
  final Animation<Offset> slideAnimation;
  final String title;
  final String subtitle;
  final EdgeInsetsGeometry padding;

  const HeaderWidget({
    super.key,
    required this.animationController,
    required this.slideAnimation,
    required this.title,
    required this.subtitle,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return SlideTransition(
          position: slideAnimation,
          child: Container(
            width: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryMint,
                  AppTheme.primaryMint.withValues(alpha: 0.8),
                  AppTheme.primaryMint.withValues(alpha: 0.9),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryMint.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}