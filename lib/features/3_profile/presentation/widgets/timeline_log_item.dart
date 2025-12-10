import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kamino_fr/core/app_theme.dart';
import 'package:kamino_fr/features/3_profile/data/logbook_entry.dart';

class TimelineLogItem extends StatelessWidget {
  final LogbookEntry log;
  final bool isFirst;
  final bool isLast;

  const TimelineLogItem({super.key, required this.log, this.isFirst = false, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTimeline(context),
          const SizedBox(width: 16),
          Expanded(child: _buildCard(context)),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return SizedBox(
      width: 30,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Container(
              width: 2,
              color: isFirst ? Colors.transparent : AppTheme.primaryMint.withOpacity(0.5),
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppTheme.primaryMint,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.textBlack, width: 2),
            ),
          ),
          Expanded(
            child: Container(
              width: 2,
              color: isLast ? Colors.transparent : AppTheme.primaryMint.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLogDetails(context, log),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: const Color(0xFF2A3038),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('d MMMM, y', 'es').format(log.visitDate),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                log.placeName ?? 'Lugar Desconocido',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogDetails(BuildContext context, LogbookEntry log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A3038),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          log.placeName ?? 'Lugar Desconocido',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          log.description.isNotEmpty ? log.description : 'No hay descripción para esta entrada.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar', style: TextStyle(color: AppTheme.primaryMint)),
          ),
        ],
      ),
    );
  }
}
