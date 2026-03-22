import 'package:flutter/material.dart';

import '../../data/repositories/farm_repository.dart';

class TimeRangeSelector extends StatelessWidget {
  const TimeRangeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final AnalyticsRange selected;
  final ValueChanged<AnalyticsRange> onSelected;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AnalyticsRange>(
      segments: AnalyticsRange.values
          .map(
            (range) => ButtonSegment<AnalyticsRange>(
              value: range,
              label: Text(range.label),
            ),
          )
          .toList(),
      selected: {selected},
      onSelectionChanged: (selection) => onSelected(selection.first),
    );
  }
}
