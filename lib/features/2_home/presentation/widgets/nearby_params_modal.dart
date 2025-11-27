import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/features/2_home/presentation/provider/nearby_places_provider.dart';

class NearbyParamsModal extends StatefulWidget {
  const NearbyParamsModal({super.key});

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
    final vm = Provider.of<NearbyPlacesProvider>(context, listen: false);
    _radiusCtrl = TextEditingController(text: vm.manualRadius.toString());
    _limitCtrl = TextEditingController(text: vm.manualLimit.toString());
    _useManual = vm.useManual;
  }

  @override
  void dispose() {
    _radiusCtrl.dispose();
    _limitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<NearbyPlacesProvider>(context, listen: false);
    
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Usar parámetros manuales'),
                Switch(
                  value: _useManual,
                  onChanged: (v) {
                    setState(() {
                      _useManual = v;
                    });
                  },
                ),
              ],
            ),
            TextField(
              controller: _radiusCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Radio (km)'),
            ),
            TextField(
              controller: _limitCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Límite (lugares)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final r = double.tryParse(_radiusCtrl.text) ?? vm.manualRadius;
                final l = int.tryParse(_limitCtrl.text) ?? vm.manualLimit;
                vm.setManualParams(useManual: _useManual, radius: r, limit: l);
                Navigator.of(context).pop(true); // Retorna true si se guardó
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}