import 'package:flutter/material.dart';

import '../../data/models/zone.dart';

class StatusColorHelper {
  const StatusColorHelper._();

  static Color forLevel(StressLevel level) {
    switch (level) {
      case StressLevel.healthy:
        return const Color(0xFF2E7D32);
      case StressLevel.warning:
        return const Color(0xFFF9A825);
      case StressLevel.critical:
        return const Color(0xFFC62828);
    }
  }
}
