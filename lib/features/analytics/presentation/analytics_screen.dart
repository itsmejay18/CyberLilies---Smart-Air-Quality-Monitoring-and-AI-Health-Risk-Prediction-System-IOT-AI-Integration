import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/async_value_widget.dart';
import '../../../data/models/sensor_data_point.dart';
import '../../../data/repositories/farm_repository.dart';
import '../../dashboard/application/dashboard_providers.dart';
import '../../zone/application/zone_providers.dart';
import '../application/analytics_providers.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zones = ref.watch(zonesProvider);
    final range = ref.watch(analyticsRangeProvider);
    final selectedZoneId = ref.watch(analyticsSelectedZoneIdProvider);

    return AsyncValueWidget(
      value: zones,
      loadingMessage: 'Preparing analytics...',
      data: (zoneItems) {
        final zoneId = selectedZoneId ?? zoneItems.first.id;
        final history = ref.watch(
          zoneHistoryProvider((zoneId: zoneId, range: range)),
        );

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DropdownMenu<String>(
                  initialSelection: zoneId,
                  label: const Text('Zone'),
                  onSelected: (value) {
                    ref
                        .read(analyticsSelectedZoneIdProvider.notifier)
                        .setZone(value);
                  },
                  dropdownMenuEntries: zoneItems
                      .map(
                        (zone) =>
                            DropdownMenuEntry(value: zone.id, label: zone.name),
                      )
                      .toList(),
                ),
                SegmentedButton(
                  segments: AnalyticsRange.values
                      .map(
                        (value) => ButtonSegment(
                          value: value,
                          label: Text(value.label),
                        ),
                      )
                      .toList(),
                  selected: {range},
                  onSelectionChanged: (selection) {
                    ref
                        .read(analyticsRangeProvider.notifier)
                        .setRange(selection.first);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            history.when(
              data: (points) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    height: 340,
                    child: _AnalyticsChart(points: points.reversed.toList()),
                  ),
                ),
              ),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Unable to load analytics: $error'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AnalyticsChart extends StatelessWidget {
  const _AnalyticsChart({required this.points});

  final List<SensorDataPoint> points;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(DateFormat.Md().format(points[index].recordedAt)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 42),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: [
          _line(points, (p) => p.soilMoisture, const Color(0xFF2F7D32)),
          _line(points, (p) => p.temperature, const Color(0xFFE65100)),
          _line(points, (p) => p.humidity, const Color(0xFF0277BD)),
        ],
      ),
    );
  }

  LineChartBarData _line(
    List<SensorDataPoint> points,
    double Function(SensorDataPoint) selector,
    Color color,
  ) {
    return LineChartBarData(
      spots: List.generate(
        points.length,
        (index) => FlSpot(index.toDouble(), selector(points[index])),
      ),
      isCurved: true,
      barWidth: 3,
      color: color,
      dotData: const FlDotData(show: false),
    );
  }
}
