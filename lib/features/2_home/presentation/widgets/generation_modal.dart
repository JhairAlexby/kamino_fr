import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';

class GenerationModal extends StatefulWidget {
  const GenerationModal({super.key});

  @override
  State<GenerationModal> createState() => _GenerationModalState();
}

class _GenerationModalState extends State<GenerationModal> {
  final List<String> _interests = ['Comida', 'Música', 'Caminata', 'Naturaleza', 'Nocturno'];
  final List<String> _selectedInterests = [];
  double _hours = 1.5;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Text(
                    '¿Qué te apetece descubrir hoy?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textBlack,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.primaryMintDark),
                  splashRadius: 20,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryMint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 10),
            _buildChoiceChips(_interests, _selectedInterests),
            const SizedBox(height: 20),
            _buildSectionTitle('Tiempo disponible'),
            _buildTimeSlider(),
            const SizedBox(height: 20),
            _buildSectionTitle('Ambiente'),
            const SizedBox(height: 10),
            _buildChoiceChips(['Opción 1', 'Opción 2', 'Opción 3'], []),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppTheme.primaryMint,
                foregroundColor: AppTheme.textBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '¡Generar mi ruta!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textBlack,
      ),
    );
  }

  Widget _buildChoiceChips(List<String> options, List<String> selected) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (bool val) {
            setState(() {
              if (val) {
                selected.add(option);
              } else {
                selected.remove(option);
              }
            });
          },
          backgroundColor: AppTheme.lightMintBackground,
          selectedColor: AppTheme.primaryMint,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.textBlack : AppTheme.textBlack,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? AppTheme.primaryMintDark : AppTheme.primaryMint.withValues(alpha: 0.35),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeSlider() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppTheme.primaryMint,
        inactiveTrackColor: AppTheme.lightMintBackground,
        thumbColor: AppTheme.primaryMintDark,
        overlayColor: AppTheme.primaryMint.withValues(alpha: 0.2),
        trackHeight: 4,
        activeTickMarkColor: AppTheme.primaryMintDark,
        inactiveTickMarkColor: AppTheme.primaryMint.withValues(alpha: 0.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Slider(
            value: _hours,
            min: 1,
            max: 8,
            divisions: 7,
            label: '${_hours.toStringAsFixed(1)} horas',
            onChanged: (double value) => setState(() => _hours = value),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [Text('1 hora'), Text('8 horas')],
            ),
          ),
        ],
      ),
    );
  }
}