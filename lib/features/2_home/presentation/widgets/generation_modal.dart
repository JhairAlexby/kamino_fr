import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/mint_dialog_shell.dart';

class GenerationModal extends StatefulWidget {
  const GenerationModal({super.key});

  @override
  State<GenerationModal> createState() => _GenerationModalState();
}

class _GenerationModalState extends State<GenerationModal>
    with SingleTickerProviderStateMixin {
  int _selectedHours = 4;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late TextEditingController _hoursController;

  @override
  void initState() {
    super.initState();
    _hoursController = TextEditingController(text: _selectedHours.toString());
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: MintDialogShell(
          title: 'Cuanto tiempo tienes\ndisponible?',
          onClose: () => Navigator.of(context).pop(),
          children: [
            const SizedBox(height: 32), // Agregué 'const' y aseguré la coma

            // 3D Clock Image
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                height: 200,
                width: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/reloj3d.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint(
                        'Error cargando assets/images/reloj3d.png: $error');
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Helper text
            const Text(
              'El siguiente dato nos ayudara\na generarte tu mejor eleccion',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Time selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Hrs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryMint,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E0B36), // Dark purple/blue box
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _hoursController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedHours = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Disponibles',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryMint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Action Button
            ElevatedButton(
              onPressed: () {
                if (_selectedHours > 24) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El máximo de horas disponibles es 24')),
                  );
                  return;
                }
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppTheme.primaryMint,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Buscar destino',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}