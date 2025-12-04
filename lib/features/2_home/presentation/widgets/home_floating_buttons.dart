import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';
 

class HomeFloatingButtons extends StatelessWidget {
  final VoidCallback onHideTooltip;
  final VoidCallback onCenterCamera;

  const HomeFloatingButtons({
    Key? key,
    required this.onHideTooltip,
    required this.onCenterCamera,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        
        FloatingActionButton(
          heroTag: 'location_btn',
          backgroundColor: AppTheme.primaryMint,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onPressed: () {
            onHideTooltip();
            onCenterCamera();
          },
          child: const Icon(Icons.my_location, color: AppTheme.textBlack),
        ),
        const SizedBox(height: 8),
        const SizedBox.shrink(),
      ],
    );
  }
}
