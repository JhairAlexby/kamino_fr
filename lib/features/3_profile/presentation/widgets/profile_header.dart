// c:\Users\Josep\Documents\Kmino Complete\kamino_fr\lib\features\3_profile\presentation\widgets\profile_header.dart
import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final int selectedSection;
  final ValueChanged<int> onSectionChange;
  final VoidCallback onSettings;
  final VoidCallback? onStats;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.selectedSection,
    required this.onSectionChange,
    required this.onSettings,
    this.onStats,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final headerHeight = (size.height * 0.30).clamp(280.0, 360.0).toDouble();
    final sidePad = (size.width * 0.05).clamp(16.0, 24.0).toDouble();
    final avatarRadius = (size.width * 0.12).clamp(36.0, 48.0).toDouble();
    final underlineW = (size.width * 0.28).clamp(80.0, 120.0).toDouble();
    return SizedBox(
      height: headerHeight,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryMint,
              AppTheme.primaryMint.withOpacity(0.85),
              AppTheme.primaryMintDark.withOpacity(0.9),
            ],
          ),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryMint.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 10),
            )
          ],
        ),
        padding: EdgeInsets.fromLTRB(sidePad, 16, sidePad, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.bar_chart),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 32, height: 40),
                      color: Colors.white,
                      onPressed: onStats ??
                          () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Estadísticas próximamente')),
                              ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(width: 32, height: 40),
                      color: Colors.white,
                      onPressed: onSettings,
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                email,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textBlack,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSectionChange(0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOut,
                          tween: Tween<double>(begin: 1.0, end: selectedSection == 0 ? 1.0 : 0.98),
                          builder: (context, scale, child) => Transform.scale(
                            scale: scale,
                            child: TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeInOut,
                              tween: Tween<double>(begin: 0, end: selectedSection == 0 ? 0 : 2),
                              builder: (context, value, child) => Transform.translate(
                                offset: Offset(0, value),
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeInOut,
                                  style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle()).copyWith(
                                    color: selectedSection == 0 ? AppTheme.textBlack : Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  child: child!,
                                ),
                              ),
                              child: child,
                            ),
                          ),
                          child: const Text('Mis datos'),
                        ),
                        const SizedBox(height: 6),
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutBack,
                          tween: Tween<double>(begin: 0, end: selectedSection == 0 ? underlineW : 0),
                          builder: (context, w, _) => Container(
                            height: 2,
                            width: w <= 0 ? 0 : w,
                            color: selectedSection == 0 ? AppTheme.textBlack : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSectionChange(1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOut,
                          tween: Tween<double>(begin: 1.0, end: selectedSection == 1 ? 1.0 : 0.98),
                          builder: (context, scale, child) => Transform.scale(
                            scale: scale,
                            child: TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeInOut,
                              tween: Tween<double>(begin: 0, end: selectedSection == 1 ? 0 : 2),
                              builder: (context, value, child) => Transform.translate(
                                offset: Offset(0, value),
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeInOut,
                                  style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle()).copyWith(
                                    color: selectedSection == 1 ? AppTheme.textBlack : Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  child: child!,
                                ),
                              ),
                              child: child,
                            ),
                          ),
                          child: const Text('Mis bitácoras'),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutBack,
                            tween: Tween<double>(begin: 0, end: selectedSection == 1 ? underlineW : 0),
                            builder: (context, w, _) => Container(
                              height: 2,
                              width: w <= 0 ? 0 : w,
                              color: selectedSection == 1 ? AppTheme.textBlack : Colors.transparent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}