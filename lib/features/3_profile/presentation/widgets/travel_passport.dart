import 'package:flutter/material.dart';
import 'package:kamino_fr/core/app_theme.dart';

class TravelPassport extends StatelessWidget {
  // Dummy data - in a real app, this would come from a provider or view model
  final int visitedPlaces = 78;
  final int exploredCities = 12;
  final List<String> medals = ['Explorador Urbano', 'Amante de la Naturaleza', 'Gourmet'];

  TravelPassport({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2E384E), const Color(0xFF222831).withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryMint.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildStats(),
            const SizedBox(height: 20),
            _buildMedals(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      children: [
        Icon(Icons.auto_stories, color: AppTheme.primaryMint, size: 28),
        SizedBox(width: 12),
        Text(
          'Pasaporte de Viajero',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('Lugares Visitados', visitedPlaces.toString()),
        _buildStatItem('Ciudades Exploradas', exploredCities.toString()),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryMint,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildMedals(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medallas Obtenidas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: medals.map((medal) => _buildMedalChip(medal)).toList(),
        ),
      ],
    );
  }

  Widget _buildMedalChip(String medalName) {
    return Chip(
      avatar: Icon(Icons.military_tech, color: Colors.yellow.shade700, size: 18),
      label: Text(medalName),
      backgroundColor: const Color(0xFF3A475A),
      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      side: BorderSide(color: AppTheme.primaryMint.withOpacity(0.5)),
    );
  }
}