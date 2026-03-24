import 'package:flutter/material.dart';

import '../../core/models/app_runtime_status.dart';

class RuntimeStatusBanner extends StatelessWidget {
  const RuntimeStatusBanner({super.key, required this.status});

  final AppRuntimeStatus status;

  @override
  Widget build(BuildContext context) {
    final isSetup = status.needsSetup;
    final noData = !status.liveDataAvailable && !isSetup;
    final tone = isSetup
        ? Colors.blueGrey.shade100
        : noData
        ? Colors.orange.shade100
        : Colors.green.shade100;
    final accent = isSetup
        ? Colors.blueGrey.shade900
        : noData
        ? Colors.orange.shade900
        : Colors.green.shade900;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tone,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isSetup
                ? Icons.settings_ethernet_outlined
                : noData
                ? Icons.cloud_off_outlined
                : Icons.cloud_done_outlined,
            color: accent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSetup
                      ? 'Backend setup required'
                      : noData
                      ? 'Waiting for live readings'
                      : 'Live data mode',
                  style: TextStyle(color: accent, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  isSetup
                      ? 'Supabase credentials are missing or incomplete for this build.'
                      : noData
                      ? 'The app is connected, but no real monitoring-area or sensor records have arrived yet.'
                      : 'Supabase project tables are live and the app is reading real environmental data.',
                  style: TextStyle(color: accent),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MiniPill(
                      label: status.supabaseConfigured
                          ? 'Supabase configured'
                          : 'Supabase missing',
                    ),
                    _MiniPill(
                      label: status.aiServerAvailable
                          ? 'AI server online'
                          : 'AI server offline',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
