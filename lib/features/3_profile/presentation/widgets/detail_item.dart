import 'package:flutter/material.dart';

class DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final String? tooltip;
  const DetailItem({super.key, required this.label, required this.value, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
    return Tooltip(
      message: tooltip ?? '',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: content,
      ),
    );
  }
}

