import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';

class EtaIndicator extends StatelessWidget {
  final String etaText;
  final String navMode;

  const EtaIndicator({
    Key? key,
    required this.etaText,
    required this.navMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (etaText.isEmpty) return const SizedBox.shrink();

    IconData icon;
    if (navMode == 'driving') {
      icon = Icons.directions_car;
    } else if (navMode == 'cycling') {
      icon = Icons.directions_bike;
    } else {
      icon = Icons.directions_walk;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryMint.withOpacity(0.35), width: 1),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Text('ETA',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Text(etaText, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}