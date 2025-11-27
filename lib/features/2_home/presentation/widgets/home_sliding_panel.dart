import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';

class HomeCollapsedPanel extends StatelessWidget {
  const HomeCollapsedPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      child: Container(
        padding: const EdgeInsets.only(top: 6),
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF2C303A), AppTheme.textBlack],
            stops: [0.0, 1.0],
          ),
          boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, -4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 32, height: 3, decoration: BoxDecoration(color: AppTheme.primaryMint, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 4),
            const Text('Recomendaciones', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primaryMint)),
          ],
        ),
      ),
    );
  }
}

class HomeExpandedPanel extends StatelessWidget {
  final ScrollController scrollController;

  const HomeExpandedPanel({super.key, required this.scrollController});

  Widget _buildCard(String title) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.lightMintBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryMintDark.withOpacity(0.35)),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryMint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textBlack)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF2C303A), AppTheme.textBlack],
            stops: [0.0, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Joyas ocultas de la semana', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryMint)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _buildCard('Nombre Lugar')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildCard('Nombre Lugar')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildCard('Nombre Lugar')),
                ]),
                const SizedBox(height: 20),
                const Text('Basado en tus últimas rutas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryMint)),
                const SizedBox(height: 12),
                _buildCard('Nombre Lugar'),
                const SizedBox(height: 20),
                const Text('Destacados de la semana', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryMint)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _buildCard('Nombre Lugar')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildCard('Nombre Lugar')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildCard('Nombre Lugar')),
                ]),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}