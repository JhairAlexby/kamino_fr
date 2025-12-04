import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/mint_dialog_shell.dart';
import 'package:kamino_fr/features/4_routes/data/models/generated_routes_response.dart';

class GeneratedRoutesModal extends StatelessWidget {
  final GenerateRoutesResponse response;
  final void Function(GeneratedRoute route) onStartRoute;
  const GeneratedRoutesModal({super.key, required this.response, required this.onStartRoute});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: MintDialogShell(
          title: 'Rutas generadas',
          onClose: () => Navigator.of(context).pop(),
          children: [
            const SizedBox(height: 16),
            Text(
              'Tiempo disponible: ${response.availableTimeMinutes} min',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...response.routes.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final route = entry.value;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E0B36),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ruta $idx',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${route.totalDurationMinutes} min · ${route.totalDistanceKm.toStringAsFixed(2)} km · ${route.numberOfPlaces} lugares',
                          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...route.places.map((p) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryMint,
                                shape: BoxShape.circle,
                              ),
                              child: Text('${p.order}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${p.category} · ${p.visitDurationMinutes} min · ${p.arrivalTime} - ${p.departureTime}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: p.tags.take(4).map((t) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2A2240),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(t, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                    )).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () { onStartRoute(route); },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                          backgroundColor: AppTheme.primaryMint,
                          foregroundColor: AppTheme.textBlack,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Comenzar ruta', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
