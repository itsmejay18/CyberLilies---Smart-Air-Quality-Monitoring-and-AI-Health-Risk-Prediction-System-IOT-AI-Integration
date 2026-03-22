import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/async_value_widget.dart';
import '../../../presentation/widgets/empty_state_card.dart';
import '../../dashboard/application/dashboard_providers.dart';
import '../application/alerts_providers.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);

    return AsyncValueWidget(
      value: alerts,
      loadingMessage: 'Checking farm alerts...',
      data: (items) {
        if (items.isEmpty) {
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              EmptyStateCard(
                icon: Icons.notifications_none,
                title: 'No alerts right now',
                message:
                    'When drought predictions, anomalies, or irrigation actions occur, they will appear here.',
              ),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(alertsProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    final repository = ref.read(farmRepositoryProvider);
                    await repository.markAlertsRead(items);
                    ref.invalidate(alertsProvider);
                  },
                  icon: const Icon(Icons.done_all),
                  label: const Text('Mark all read'),
                ),
              ),
              for (final alert in items) ...[
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: alert.isRead
                          ? Colors.grey.shade200
                          : Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.16),
                      child: Icon(
                        _iconForType(alert.type),
                        color: alert.isRead
                            ? Colors.grey.shade600
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(alert.title),
                    subtitle: Text(
                      '${alert.message}\n${DateFormat.yMMMd().add_jm().format(alert.createdAt)}',
                    ),
                    isThreeLine: true,
                    trailing: alert.isRead
                        ? null
                        : const Icon(Icons.brightness_1, size: 12),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        );
      },
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'prediction':
        return Icons.psychology;
      case 'action':
        return Icons.power;
      case 'anomaly':
        return Icons.warning_amber;
      default:
        return Icons.notifications;
    }
  }
}
