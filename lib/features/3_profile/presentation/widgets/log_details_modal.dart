import 'package:flutter/material.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/mint_dialog_shell.dart';

class LogDetailsModal extends StatelessWidget {
  final Map<String, String> log;

  const LogDetailsModal({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: MintDialogShell(
        title: log['placeName'] ?? 'Bitácora',
        onClose: () => Navigator.of(context).pop(),
        children: [
          const SizedBox(height: 24),
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              log['image']!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[800],
                  child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 48),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Note Content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Text(
              log['excerpt']!,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}