import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';

class ProfileInterestsSection extends StatelessWidget {
  final Set<String> selectedInterests;
  final ValueChanged<String> onToggleInterest;

  const ProfileInterestsSection({
    super.key,
    required this.selectedInterests,
    required this.onToggleInterest,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tus intereses',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final opt in const [
                'parques',
                'restaurantes',
                'urbano',
                'cine',
                'deportivo'
              ])
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(
                      begin: 1.0, end: selectedInterests.contains(opt) ? 1.05 : 1.0),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: FilterChip(
                        selected: selectedInterests.contains(opt),
                        onSelected: (v) => onToggleInterest(opt),
                        label: Text(opt,
                            style: TextStyle(
                                color: selectedInterests.contains(opt)
                                    ? Colors.white
                                    : AppTheme.textBlack)),
                        selectedColor: AppTheme.primaryMint,
                        backgroundColor: Theme.of(context).cardColor,
                        checkmarkColor: Colors.white,
                        showCheckmark: false,
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}