import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';

class GenerationModal extends StatefulWidget {
  const GenerationModal({super.key});

  @override
  State<GenerationModal> createState() => _GenerationModalState();
}

class _GenerationModalState extends State<GenerationModal> with SingleTickerProviderStateMixin {
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
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A), // Dark background
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Header with close button
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryMint,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Cuanto tiempo tienes\ndisponible?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.25),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2C303A), Colors.black],
                        ).createShader(bounds),
                        blendMode: BlendMode.srcIn,
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

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
                    debugPrint('Error cargando assets/images/reloj3d.png: ' + error.toString());
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
                Navigator.of(context).pop();
                // Add logic to handle destination search
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
      ),
    );
  }
}