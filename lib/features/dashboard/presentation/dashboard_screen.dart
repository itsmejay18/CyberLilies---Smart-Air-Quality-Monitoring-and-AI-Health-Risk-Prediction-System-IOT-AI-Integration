import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_value_widget.dart';
import '../../../presentation/widgets/zone_card.dart';
import '../../alerts/application/alerts_providers.dart';
import '../application/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zones = ref.watch(zonesProvider);
    final unreadCount = ref.watch(unreadAlertsCountProvider);

    return AsyncValueWidget(
      value: zones,
      loadingMessage: 'Loading live farm zones...',
      data: (items) {
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(zonesProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active zones',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${items.length}',
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unread alerts',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '$unreadCount',
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              for (final zone in items) ...[
                ZoneCard(
                  zone: zone,
                  onTap: () => context.push('/zone/${zone.id}'),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        );
      },
    );
  }
}
