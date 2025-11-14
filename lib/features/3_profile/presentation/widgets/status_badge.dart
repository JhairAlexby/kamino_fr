import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final bool isActive;
  const StatusBadge({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.green : Colors.red;
    final label = isActive ? 'Activo' : 'Inactivo';
    return Chip(
      avatar: Icon(Icons.circle, size: 12, color: color),
      label: Text(label),
      backgroundColor: AppTheme.lightMintBackground,
    );
  }
}

