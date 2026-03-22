import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_value_widget.dart';
import '../../../data/models/iot_device.dart';
import '../../../presentation/widgets/empty_state_card.dart';
import '../../../presentation/widgets/iot_device_card.dart';
import '../../../presentation/widgets/zone_card.dart';
import '../../../presentation/widgets/runtime_status_banner.dart';
import '../../alerts/application/alerts_providers.dart';
import '../../devices/application/device_providers.dart';
import '../application/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zones = ref.watch(zonesProvider);
    final unreadCount = ref.watch(unreadAlertsCountProvider);
    final runtimeStatus = ref.watch(appRuntimeStatusProvider).asData?.value;
    final iotDevices =
        ref.watch(iotDevicesProvider).asData?.value ?? const <IoTDevice>[];

    return AsyncValueWidget(
      value: zones,
      loadingMessage: 'Loading live farm zones...',
      data: (items) {
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(zonesProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2F7D32), Color(0xFF7FB069)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farm overview',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Monitor plant health, stress signals, and irrigation activity across all zones.',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              if (runtimeStatus != null) ...[
                const SizedBox(height: 16),
                RuntimeStatusBanner(status: runtimeStatus),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatisticCard(
                      label: 'Active zones',
                      value: '${items.length}',
                      icon: Icons.grid_view_rounded,
                      accent: const Color(0xFF2F7D32),
                      subtitle: 'Zones',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatisticCard(
                      label: 'Unread alerts',
                      value: '$unreadCount',
                      icon: Icons.notifications_active_outlined,
                      accent: const Color(0xFFD97706),
                      subtitle: 'Alerts',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatisticCard(
                      label: 'IoT nodes online',
                      value:
                          '${iotDevices.where((device) => device.connectionState == IoTConnectionState.online).length}',
                      icon: Icons.router_outlined,
                      accent: const Color(0xFF1565C0),
                      subtitle: 'Online',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (iotDevices.isNotEmpty) ...[
                Text(
                  'IoT node monitoring',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                for (final device in iotDevices.take(2)) ...[
                  IoTDeviceCard(device: device, compact: true),
                  const SizedBox(height: 12),
                ],
              ] else ...[
                const EmptyStateCard(
                  icon: Icons.router_outlined,
                  title: 'No IoT nodes yet',
                  message:
                      'Register an ESP32 node from the Devices screen, then start sending telemetry to see it here.',
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    onPressed: () => context.push('/devices'),
                    icon: const Icon(Icons.memory_outlined),
                    label: const Text('Open Devices'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (items.isEmpty) ...[
                const EmptyStateCard(
                  icon: Icons.dashboard_outlined,
                  title: 'No zones loaded yet',
                  message:
                      'This app stays empty until real zone data and sensor telemetry are available.',
                ),
                const SizedBox(height: 12),
              ],
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

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.subtitle,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1D251C),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
