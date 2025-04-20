/// Very small week‑only calendar bar built on `table_calendar`.
/// Requires `table_calendar` in pubspec.yaml.

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

typedef OnDaySelect = void Function(DateTime selected, DateTime focused);

class PersonalWeekCalendar extends StatefulWidget {
  const PersonalWeekCalendar({
    super.key,
    required this.onDaySelected,
  });

  final OnDaySelect onDaySelected;

  @override
  State<PersonalWeekCalendar> createState() => _PersonalWeekCalendarState();
}

class _PersonalWeekCalendarState extends State<PersonalWeekCalendar> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TableCalendar(
      firstDay: DateTime.utc(2020),
      lastDay: DateTime.utc(2100),
      focusedDay: _focused,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarFormat: CalendarFormat.week,
      availableCalendarFormats: const {CalendarFormat.week: 'Week'},
      headerVisible: false,
      daysOfWeekHeight: 18,
      rowHeight: 46,
      selectedDayPredicate: (day) =>
      _selected != null &&
          day.year == _selected!.year &&
          day.month == _selected!.month &&
          day.day == _selected!.day,
      calendarStyle: CalendarStyle(
        todayDecoration:
        BoxDecoration(color: cs.primary, shape: BoxShape.circle),
        selectedDecoration:
        BoxDecoration(color: cs.secondary, shape: BoxShape.circle),
        defaultDecoration:
        const BoxDecoration(shape: BoxShape.circle, color: Colors.transparent),
      ),
      onDaySelected: (sel, foc) {
        setState(() {
          _selected = sel;
          _focused = foc;
        });
        widget.onDaySelected(sel, foc);
      },
    );
  }
}