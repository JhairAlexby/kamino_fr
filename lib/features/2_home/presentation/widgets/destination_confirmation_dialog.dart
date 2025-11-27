import 'package:flutter/material.dart';

class DestinationConfirmationDialog extends StatefulWidget {
  final String initialMode;

  const DestinationConfirmationDialog({super.key, required this.initialMode});

  @override
  State<DestinationConfirmationDialog> createState() => _DestinationConfirmationDialogState();
}

class _DestinationConfirmationDialogState extends State<DestinationConfirmationDialog> {
  late String _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmación'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('¿Deseas ir a esta ubicación?'),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Modo: '),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedMode,
                items: const [
                  DropdownMenuItem(value: 'driving', child: Text('Conducción')),
                  DropdownMenuItem(value: 'walking', child: Text('Caminando')),
                  DropdownMenuItem(value: 'cycling', child: Text('Bicicleta')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _selectedMode = v;
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedMode);
          },
          child: const Text('Ir'),
        ),
      ],
    );
  }
}