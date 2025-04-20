/// Lightweight wrapper around the `table_calendar` package.
/// Add `table_calendar: ^3.0.9` (or newer) to pubspec.yaml!

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// Signature for the day‑selection callback.
typedef OnDaySelect = void Function(DateTime selected, DateTime focused);

class PersonalMonthCalendar extends StatefulWidget {
  const PersonalMonthCalendar({
    super.key,
    required this.events,
    required this.onDaySelected,
  });

  /// Map whose *key* is a UTC date (YYYY‑MM‑DD at 00:00) and *value*
  /// is the list of events occurring that day.
  final Map<DateTime, List<dynamic>> events;
  final OnDaySelect onDaySelected;

  @override
  State<PersonalMonthCalendar> createState() => _PersonalMonthCalendarState();
}

class _PersonalMonthCalendarState extends State<PersonalMonthCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<dynamic> _loader(DateTime day) {
    final key = DateTime.utc(day.year, day.month, day.day);
    return widget.events[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TableCalendar(
      firstDay: DateTime.utc(2020),
      lastDay: DateTime.utc(2100),
      focusedDay: _focusedDay,
      eventLoader: _loader,
      selectedDayPredicate: (d) =>
      _selectedDay != null &&
          d.year == _selectedDay!.year &&
          d.month == _selectedDay!.month &&
          d.day == _selectedDay!.day,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarStyle: CalendarStyle(
        markerDecoration: BoxDecoration(
          color: cs.secondary,
          shape: BoxShape.circle,
        ),
      ),
      onDaySelected: (sel, foc) {
        setState(() {
          _selectedDay = sel;
          _focusedDay = foc;
        });
        widget.onDaySelected(sel, foc);
      },
    );
  }
}