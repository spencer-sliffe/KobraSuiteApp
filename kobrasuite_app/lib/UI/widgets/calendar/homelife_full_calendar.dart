// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:table_calendar/table_calendar.dart';
// import '../../../../models/homelife/shared_calendar_event.dart';
// import '../../../../providers/homelife/calendar_provider.dart';
//
// class HomelifeFullCalendar extends StatefulWidget {
//   const HomelifeFullCalendar({super.key});
//
//   @override
//   State<HomelifeFullCalendar> createState() => _HomelifeFullCalendarState();
// }
//
// class _HomelifeFullCalendarState extends State<HomelifeFullCalendar> {
//   late DateTime _focused;
//   DateTime? _selected;
//
//   @override
//   void initState() {
//     super.initState();
//     _focused = DateTime.now();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadMonth(_focused);
//     });
//   }
//
//   void _loadMonth(DateTime date) {
//     context.read<CalendarProvider>().loadCalendarEventsRange(
//       DateTime(date.year, date.month, 1),
//       DateTime(date.year, date.month + 1, 0, 23, 59, 59),
//     );
//   }
//
//   Map<DateTime, List<SharedCalendarEvent>> _group(
//       List<SharedCalendarEvent> items) {
//     final map = <DateTime, List<SharedCalendarEvent>>{};
//     for (final e in items) {
//       final key = DateTime(e.start.year, e.start.month, e.start.day);
//       map.putIfAbsent(key, () => []).add(e);
//     }
//     return map;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<CalendarProvider>();
//     final groups = _group(provider.calendarEvents);
//     final sel = _selected ?? _focused;
//     final key = DateTime(sel.year, sel.month, sel.day);
//     final compact = MediaQuery.of(context).size.width < 600;
//
//     return Column(
//       children: [
//         TableCalendar<SharedCalendarEvent>(
//           firstDay: DateTime.utc(2000, 1, 1),
//           lastDay: DateTime.utc(2100, 12, 31),
//           focusedDay: _focused,
//           calendarFormat: CalendarFormat.month,
//           selectedDayPredicate: (d) => _selected != null && isSameDay(d, _selected),
//           eventLoader: (d) => groups[DateTime(d.year, d.month, d.day)] ?? [],
//           calendarBuilders: CalendarBuilders<SharedCalendarEvent>(
//             markerBuilder: (ctx, date, events) => events.isEmpty
//                 ? const SizedBox.shrink()
//                 : Positioned(
//               bottom: 4,
//               left: 0,
//               right: 0,
//               child: compact
//                   ? Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(
//                   events.length.clamp(0, 3),
//                       (_) => Container(
//                     width: 5,
//                     height: 5,
//                     margin:
//                     const EdgeInsets.symmetric(horizontal: 1),
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Theme.of(context)
//                           .colorScheme
//                           .secondary,
//                     ),
//                   ),
//                 ),
//               )
//                   : Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 3, vertical: 1),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context)
//                       .colorScheme
//                       .secondaryContainer,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   events.first.title,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: Theme.of(context)
//                       .textTheme
//                       .labelSmall
//                       ?.copyWith(
//                     color: Theme.of(context)
//                         .colorScheme
//                         .onSecondaryContainer,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           onDaySelected: (sel, foc) => setState(() {
//             _selected = sel;
//             _focused = foc;
//           }),
//           onPageChanged: (foc) {
//             _focused = foc;
//             _loadMonth(foc);
//           },
//         ),
//         const SizedBox(height: 12),
//         Expanded(
//           child: provider.isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : ListView(
//             key: ValueKey(key),
//             children: [
//               for (final e in groups[key] ?? [])
//                 ListTile(
//                   leading: const Icon(Icons.event),
//                   title: Text(e.title),
//                   subtitle: Text(
//                     '${DateFormat('h:mm a').format(e.start)} – '
//                         '${DateFormat('h:mm a').format(e.end)}',
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }