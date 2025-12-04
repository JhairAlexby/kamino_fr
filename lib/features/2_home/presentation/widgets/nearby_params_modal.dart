import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_input.dart';
import 'package:kamino_fr/features/1_auth/presentation/widgets/auth_primary_button.dart';

class NearbyParamsModal extends StatefulWidget {
  final double initialRadius;
  final int initialLimit;
  final bool initialUseManual;
  final void Function({required bool useManual, required double radius, required int limit}) onSave;
  const NearbyParamsModal({super.key, required this.initialRadius, required this.initialLimit, required this.initialUseManual, required this.onSave});

  @override
  State<NearbyParamsModal> createState() => _NearbyParamsModalState();
}

class _NearbyParamsModalState extends State<NearbyParamsModal> {
  late TextEditingController _radiusCtrl;
  late TextEditingController _limitCtrl;
  late bool _useManual;

  @override
  void initState() {
    super.initState();
    _radiusCtrl = TextEditingController(text: widget.initialRadius.toString());
    _limitCtrl = TextEditingController(text: widget.initialLimit.toString());
    _useManual = false;
  }

  @override
  void dispose() {
    _radiusCtrl.dispose();
    _limitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.3,
            colors: [Color(0xFF2C303A), AppTheme.textBlack],
            stops: [0.0, 1.0],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AuthInput(
              controller: _radiusCtrl,
              hintText: 'Ingresa radio',
              labelText: 'Radio (km)',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                // Solo números y punto decimal, máximo 5 caracteres
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                LengthLimitingTextInputFormatter(5),
              ],
            ),
            const SizedBox(height: 12),
            AuthInput(
              controller: _limitCtrl,
              hintText: 'Ingresa límite',
              labelText: 'Límite (lugares)',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            AuthPrimaryButton(
              text: 'Guardar',
              isLoading: false,
              onPressed: () {
                final r = double.tryParse(_radiusCtrl.text) ?? widget.initialRadius;
                final l = int.tryParse(_limitCtrl.text) ?? widget.initialLimit;

                // Validaciones lógicas antes de guardar
                if (r > 500) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El radio máximo es de 500 km')),
                  );
                  return;
                }

                if (l > 50) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El límite máximo es de 50 lugares')),
                  );
                  return;
                }

                widget.onSave(useManual: _useManual, radius: r, limit: l);
                Navigator.of(context).pop(true);
              },
            ),
          ],
        ),
      ),
    );
  }
}
