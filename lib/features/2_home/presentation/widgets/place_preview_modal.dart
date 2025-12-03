import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:kamino_fr/features/2_home/data/models/place.dart';

class PlacePreviewModal extends StatefulWidget {
  final Place place;
  final VoidCallback onNavigate;
  final VoidCallback onChat;
  final VoidCallback onDetails;

  const PlacePreviewModal({
    super.key,
    required this.place,
    required this.onNavigate,
    required this.onChat,
    required this.onDetails,
  });

  @override
  State<PlacePreviewModal> createState() => _PlacePreviewModalState();
}

class _PlacePreviewModalState extends State<PlacePreviewModal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
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
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [Color(0xFF0F172A), AppTheme.textBlack],
          stops: [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fila Superior: Imagen + Info + Textos
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen con Icono de Info Animado
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      widget.place.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  // Icono de Info Animado (Respirando)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: widget.onDetails,
                      child: AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black26, blurRadius: 4),
                                ],
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: AppTheme.primaryMint,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Información del Lugar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.place.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.place.distance.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryMint.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.place.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryMint,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Fila de Botones: Chat (pequeño) y Vamos (grande)
          Row(
            children: [
              // Botón Chat
              Material(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: widget.onChat,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Botón Vamos (Expandido)
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onNavigate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryMint,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '¡Vamos!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textBlack,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}