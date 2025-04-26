/// lib/widgets/calendar/homelife_full_calendar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../models/homelife/shared_calendar_event.dart';
import '../../../providers/homelife/calendar_provider.dart';

class HomelifeFullCalendar extends StatefulWidget {
  const HomelifeFullCalendar({super.key});

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
    final t = DateTime.now();
    _focused = t;
    _selected = t;
    _controller =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 250))
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<DateTime, List<SharedCalendarEvent>> _map(List<SharedCalendarEvent> evs) {
    final m = <DateTime, List<SharedCalendarEvent>>{};
    for (final e in evs) {
      final k = DateTime(e.start.year, e.start.month, e.start.day);
      m.putIfAbsent(k, () => []).add(e);
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CalendarProvider>();
    if (prov.isLoading) return const Center(child: CircularProgressIndicator());

    final evDay = _map(prov.calendarEvents);

    return Column(
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: TableCalendar<SharedCalendarEvent>(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focused,
              selectedDayPredicate: (d) =>
              _selected != null &&
                  d.year == _selected!.year &&
                  d.month == _selected!.month &&
                  d.day == _selected!.day,
              eventLoader: (d) => evDay[DateTime(d.year, d.month, d.day)] ?? [],
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              rowHeight: 44,
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                leftChevronMargin: EdgeInsets.zero,
                rightChevronMargin: EdgeInsets.zero,
              ),
              calendarStyle: CalendarStyle(
                markersAlignment: Alignment.bottomCenter,
                markersMaxCount: 3,
                markerDecoration:
                const BoxDecoration(color: Color(0xFF3B82F6), shape: BoxShape.circle),
                todayDecoration:
                const BoxDecoration(color: Color(0xFF6366F1), shape: BoxShape.circle),
                selectedDecoration:
                const BoxDecoration(color: Color(0xFFEC4899), shape: BoxShape.circle),
              ),
              onDaySelected: (sel, foc) {
                setState(() {
                  _selected = sel;
                  _focused = foc;
                });
                _controller.forward(from: 0);
              },
            ),
          ),
        ),
        Expanded(
          child: SizeTransition(
            sizeFactor:
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            axisAlignment: -1,
            child: _selected == null
                ? const SizedBox.shrink()
                : _DayEventList(
              events: evDay[DateTime(
                  _selected!.year, _selected!.month, _selected!.day)] ??
                  [],
            ),
          ),
        ),
      ],
    );
  }
}

class _DayEventList extends StatelessWidget {
  const _DayEventList({required this.events});
  final List<SharedCalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
          child: Text('No events', style: Theme.of(context).textTheme.bodyMedium));
    }

    return ListView.separated(
      padding: EdgeInsets.only(
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
        left: 4,
        right: 4,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final e = events[i];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.event),
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
      '${d.hour.toString().padLeft(2, "0")}:${d.minute.toString().padLeft(2, "0")}';
}