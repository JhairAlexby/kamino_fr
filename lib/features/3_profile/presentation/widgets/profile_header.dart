import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final int selectedSection;
  final ValueChanged<int> onSectionChange;
  final VoidCallback onSettings;
  final VoidCallback? onStats;
  final bool isLoading;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.selectedSection,
    required this.onSectionChange,
    required this.onSettings,
    this.onStats,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sidePad = (size.width * 0.05).clamp(16.0, 24.0).toDouble();
    final avatarRadius = (size.width * 0.10).clamp(28.0, 36.0).toDouble();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryMint,
            AppTheme.primaryMint.withValues(alpha: 0.95),
            AppTheme.primaryMintDark,
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryMint.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      padding: EdgeInsets.fromLTRB(sidePad, 12, sidePad, 16),
      child: Stack(
        children: [
          // Decorative Circle for depth
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),

          Column(
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
                        constraints:
                            const BoxConstraints.tightFor(width: 32, height: 40),
                        color: Colors.white,
                        onPressed: onStats ??
                            () => ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Estadísticas próximamente')),
                                ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints.tightFor(width: 32, height: 40),
                        color: Colors.white,
                        onPressed: onSettings,
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(3), // Reduced ring thickness
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white
                        .withValues(alpha: 0.2), // Semi-transparent ring
                  ),
                  child: CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: avatarRadius - 2, // Inner border
                      backgroundColor: Colors.grey.shade200,
                      child: isLoading
                          ? const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryMint),
                            )
                          : Icon(Icons.person,
                              size: avatarRadius * 1.2,
                              color: Colors.grey.shade400), // Default icon
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  email,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textBlack,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              // Tab Selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF181A20).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onSectionChange(0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedSection == 0
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: selectedSection == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Mis datos',
                              style: TextStyle(
                                color: selectedSection == 0
                                    ? AppTheme.textBlack
                                    : Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onSectionChange(1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedSection == 1
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(16), // Consistent radius
                            boxShadow: selectedSection == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Mis bitácoras',
                              style: TextStyle(
                                color: selectedSection == 1
                                    ? AppTheme.textBlack
                                    : Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}