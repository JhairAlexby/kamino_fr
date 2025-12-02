import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:kamino_fr/features/2_home/presentation/provider/nearby_places_provider.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/nearby_params_modal.dart';

class HomeFloatingButtons extends StatelessWidget {
  final VoidCallback onHideTooltip;
  final VoidCallback onCenterCamera;
  final Function(BuildContext) onCameraChanged;

  const HomeFloatingButtons({
    Key? key,
    required this.onHideTooltip,
    required this.onCenterCamera,
    required this.onCameraChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'settings_btn',
          backgroundColor: AppTheme.primaryMint,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onPressed: () async {
            onHideTooltip();
            final vmNearby = context.read<NearbyPlacesProvider>();
            final changed = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (ctx) => NearbyParamsModal(
                initialRadius: vmNearby.manualRadius,
                initialLimit: vmNearby.manualLimit,
                initialUseManual: vmNearby.useManual,
                onSave: ({required bool useManual, required double radius, required int limit}) {
                  vmNearby.setManualParams(useManual: useManual, radius: radius, limit: limit);
                },
              ),
            );
            if (changed == true) {
              onCameraChanged(context);
            }
          },
          child: const Icon(Icons.tune, color: AppTheme.textBlack),
        ),
        const SizedBox(height: 12),
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