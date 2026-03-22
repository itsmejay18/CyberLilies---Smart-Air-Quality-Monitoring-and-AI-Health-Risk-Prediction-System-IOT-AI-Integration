import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/alerts/application/alerts_providers.dart';
import '../features/alerts/presentation/alerts_screen.dart';
import '../features/analytics/presentation/analytics_screen.dart';
import '../features/dashboard/application/dashboard_providers.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'widgets/alert_badge.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _screens = [
    DashboardScreen(),
    AlertsScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  static const _titles = ['Farm Dashboard', 'Alerts', 'Analytics', 'Settings'];

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadAlertsCountProvider);
    final runtimeStatus = ref.watch(appRuntimeStatusProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          if (runtimeStatus != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: runtimeStatus.isDemoMode
                        ? Colors.amber.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    runtimeStatus.isDemoMode ? 'DEMO' : 'LIVE',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: runtimeStatus.isDemoMode
                          ? Colors.amber.shade900
                          : Colors.green.shade900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: AlertBadge(
              count: unreadCount,
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: AlertBadge(
              count: unreadCount,
              child: const Icon(Icons.notifications),
            ),
            label: 'Alerts',
          ),
          const NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Analytics',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
