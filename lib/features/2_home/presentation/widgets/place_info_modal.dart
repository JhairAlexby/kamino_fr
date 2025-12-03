import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:kamino_fr/features/2_home/presentation/widgets/mint_dialog_shell.dart';

class PlaceInfoModal extends StatelessWidget {
  final String destinationName;

  const PlaceInfoModal({
    super.key,
    required this.destinationName,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos Stack para poner el blur detrás del diálogo
    return Stack(
      children: [
        // Filtro de desenfoque para todo el fondo
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.black.withOpacity(0.3), // Tinte oscuro ligero
            ),
          ),
        ),
        // El diálogo en sí
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: MintDialogShell(
              // El nombre del lugar va en el header (título)
              title: destinationName,
              onClose: () => Navigator.of(context).pop(),
              children: [
                const SizedBox(height: 24),
                
                // Imagen del Lugar (Más grande)
                Container(
                  height: 280, // Aumentado el tamaño
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/images/3dmapa.png'), // Placeholder
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Descripción (Texto más pequeño)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Este es un lugar increíble para visitar, lleno de historia y belleza natural. Disfruta de las vistas panorámicas y la experiencia única que ofrece este destino. Perfecto para relajarse y conectar con la naturaleza.',
                    style: TextStyle(
                      color: Colors.white70, // Texto un poco más apagado para lectura
                      fontSize: 14, // Texto más pequeño
                      height: 1.6, // Mayor altura de línea para legibilidad
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Botón para Chat Bot
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Acción para abrir el chat bot
                      Navigator.of(context).pop(); // O navegar al chat
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Abriendo chat con guía IA...')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryMint,
                      foregroundColor: AppTheme.textBlack,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      elevation: 8,
                      shadowColor: AppTheme.primaryMint.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.chat_bubble_outline, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Preguntar al guía IA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}