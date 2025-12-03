import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/mint_dialog_shell.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/place_info_modal.dart';

class DestinationConfirmationDialog extends StatefulWidget {
  final String initialMode;
  final String destinationName;
  final String distance;
  final String duration;

  const DestinationConfirmationDialog({
    super.key,
    required this.initialMode,
    required this.destinationName,
    required this.distance,
    required this.duration,
  });

  @override
  State<DestinationConfirmationDialog> createState() => _DestinationConfirmationDialogState();
}

class _DestinationConfirmationDialogState extends State<DestinationConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late String _selectedMode;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: MintDialogShell(
          title: 'Encontramos tu lugar\nindicado para visitar',
          onClose: () => Navigator.of(context).pop(),
          children: [
            const SizedBox(height: 24),
            
            // Imagen del Lugar
            Stack(
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/images/3dmapa.png'), // Placeholder
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.transparent, // Para permitir el efecto de blur
                        builder: (context) => PlaceInfoModal(
                          destinationName: widget.destinationName,
                        ),
                      );
                    },
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryMint,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryMint.withOpacity(0.6),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              color: AppTheme.textBlack,
                              size: 26,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Nombre del Lugar
            Text(
              widget.destinationName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // Opciones de Transporte
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildModeOption(
                  mode: 'walking',
                  icon: Icons.directions_walk,
                  time: '10m', // Mocked logic could be dynamic based on mode
                  isSelected: _selectedMode == 'walking',
                ),
                _buildModeOption(
                  mode: 'cycling',
                  icon: Icons.directions_bike,
                  time: '5m',
                  isSelected: _selectedMode == 'cycling',
                ),
                _buildModeOption(
                  mode: 'driving',
                  icon: Icons.directions_car,
                  time: '2m',
                  isSelected: _selectedMode == 'driving',
                ),
              ],
            ),
            const SizedBox(height: 40),
            
            // Botones de Acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(_selectedMode);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryMint,
                      foregroundColor: AppTheme.textBlack,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 8, // Sombra para destacar
                      shadowColor: AppTheme.primaryMint.withOpacity(0.4), // Sombra con color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Más redondeado pero no píldora
                      ),
                    ),
                    child: const Text(
                      'Vamos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800, // Más negrita
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop('regenerate');
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Otra opción',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryMintDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption({
    required String mode,
    required IconData icon,
    required String time,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryMint : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppTheme.primaryMint : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryMint.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white54,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryMint : Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}