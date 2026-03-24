import 'package:flutter/material.dart';

import '../../core/utils/status_color_helper.dart';
import '../../data/models/zone.dart';

class ZoneCard extends StatelessWidget {
  const ZoneCard({super.key, required this.zone, required this.onTap});

  final Zone zone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final currentColor = StatusColorHelper.forLevel(zone.currentStress);
    final predictedColor = StatusColorHelper.forLevel(zone.predictedStress);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      zone.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: Colors.grey.shade500),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricChip(
                    label: 'Air Quality',
                    value: '${zone.soilMoisture.toStringAsFixed(0)}%',
                  ),
                  _MetricChip(
                    label: 'Temp',
                    value: '${zone.temperature.toStringAsFixed(1)}C',
                  ),
                  _MetricChip(
                    label: 'Humidity',
                    value: '${zone.humidity.toStringAsFixed(0)}%',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _StatusPill(
                    label: 'Current ${zone.currentStress.name} risk',
                    color: currentColor,
                  ),
                  const SizedBox(width: 8),
                  _StatusPill(
                    label: 'AI ${zone.predictedStress.name} risk',
                    color: predictedColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label\n',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
