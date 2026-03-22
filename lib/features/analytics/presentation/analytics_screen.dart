import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/async_value_widget.dart';
import '../../../data/models/sensor_data_point.dart';
import '../../../data/repositories/farm_repository.dart';
import '../../../presentation/widgets/empty_state_card.dart';
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
        if (zoneItems.isEmpty) {
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              EmptyStateCard(
                icon: Icons.insights_outlined,
                title: 'No analytics yet',
                message:
                    'Add farm zones and sensor records in Supabase to unlock live analytics here.',
              ),
            ],
          );
        }

        final zoneId = selectedZoneId ?? zoneItems.first.id;
        final history = ref.watch(
          zoneHistoryProvider((zoneId: zoneId, range: range)),
        );

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E5631), Color(0xFF4C9A5F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Crop climate trends',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track soil moisture, temperature, and humidity patterns over time.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
              data: (points) {
                final orderedPoints = points.reversed.toList();
                if (orderedPoints.isEmpty) {
                  return const EmptyStateCard(
                    icon: Icons.show_chart,
                    title: 'No history for this zone',
                    message:
                        'Once sensors start sending values, trend charts will appear here.',
                  );
                }

                final latest = orderedPoints.last;
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _MetricSummaryCard(
                            label: 'Soil Moisture',
                            value: '${latest.soilMoisture.toStringAsFixed(1)}%',
                            color: const Color(0xFF2F7D32),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricSummaryCard(
                            label: 'Temperature',
                            value: '${latest.temperature.toStringAsFixed(1)}C',
                            color: const Color(0xFFE65100),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricSummaryCard(
                            label: 'Humidity',
                            value: '${latest.humidity.toStringAsFixed(1)}%',
                            color: const Color(0xFF0277BD),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const _ChartLegend(),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 340,
                              child: _AnalyticsChart(points: orderedPoints),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
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

class _MetricSummaryCard extends StatelessWidget {
  const _MetricSummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: const [
        _LegendChip(label: 'Soil Moisture', color: Color(0xFF2F7D32)),
        _LegendChip(label: 'Temperature', color: Color(0xFFE65100)),
        _LegendChip(label: 'Humidity', color: Color(0xFF0277BD)),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
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
