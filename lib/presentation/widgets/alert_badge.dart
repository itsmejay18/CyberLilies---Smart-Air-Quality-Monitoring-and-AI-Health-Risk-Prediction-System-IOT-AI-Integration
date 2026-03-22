import 'package:flutter/material.dart';

class AlertBadge extends StatelessWidget {
  const AlertBadge({super.key, required this.count, required this.child});

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return child;

    return Badge(label: Text(count.toString()), child: child);
  }
}
