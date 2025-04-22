import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../models/homelife/shared_calendar_event.dart';
import '../../../providers/homelife/calendar_provider.dart';

class HomelifeFullCalendar extends StatefulWidget {
  const HomelifeFullCalendar({Key? key}) : super(key: key);

  @override
  State<HomelifeFullCalendar> createState() => _HomelifeFullCalendarState();
}

class _HomelifeFullCalendarState extends State<HomelifeFullCalendar>
    with SingleTickerProviderStateMixin {
  late DateTime _focused;
  DateTime? _selected;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _focused = DateTime.now();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<DateTime, List<SharedCalendarEvent>> _eventMap(
      List<SharedCalendarEvent> events) {
    final map = <DateTime, List<SharedCalendarEvent>>{};
    for (var e in events) {
      final key = DateTime(e.start.year, e.start.month, e.start.day);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CalendarProvider>();
    if (prov.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final eventsByDay = _eventMap(prov.calendarEvents);
    return Column(
      children: [
        TableCalendar<SharedCalendarEvent>(
          firstDay: DateTime.utc(2023, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focused,
          selectedDayPredicate: (day) =>
          _selected != null &&
              day.year == _selected!.year &&
              day.month == _selected!.month &&
              day.day == _selected!.day,
          eventLoader: (day) =>
          eventsByDay[DateTime(day.year, day.month, day.day)] ?? [],
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          onDaySelected: (selected, focused) {
            setState(() {
              _selected = selected;
              _focused = focused;
            });
            _controller.forward(from: 0);
          },
        ),
        SizeTransition(
          sizeFactor: CurvedAnimation(parent: _controller, curve: Curves.easeIn),
          axisAlignment: -1,
          child: _selected == null
              ? const SizedBox.shrink()
              : _DayEventList(
            events: eventsByDay[
            DateTime(_selected!.year, _selected!.month, _selected!.day)] ??
                [],
          ),
        ),
      ],
    );
  }
}

class _DayEventList extends StatelessWidget {
  final List<SharedCalendarEvent> events;
  const _DayEventList({required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(
          'No events',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 16),
      itemCount: events.length,
      itemBuilder: (context, i) {
        final e = events[i];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(Icons.event,
                color: Theme.of(context).colorScheme.primary),
            title: Text(e.title),
            subtitle: Text(
              '${_fmt(e.start)} – ${_fmt(e.end)}${e.location.isNotEmpty ? ' • ${e.location}' : ''}',
            ),
          ),
        );
      },
    );
  }

  String _fmt(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}