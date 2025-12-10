import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kamino_fr/features/3_profile/presentation/provider/profile_provider.dart';
import 'package:kamino_fr/features/3_profile/presentation/widgets/timeline_log_item.dart';

class ProfileLogsTab extends StatelessWidget {
  const ProfileLogsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = context.watch<ProfileProvider>().logs;

    if (logs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book_outlined, size: 64, color: Colors.white.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text(
                'Aún no tienes bitácoras',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return TimelineLogItem(
          log: log,
          isFirst: index == 0,
          isLast: index == logs.length - 1,
        );
      },
    );
  }
}