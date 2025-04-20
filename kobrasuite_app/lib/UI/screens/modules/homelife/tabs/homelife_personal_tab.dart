import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../models/homelife/workout_routine.dart';
import '../../../../../models/homelife/shared_calendar_event.dart';
import '../../../../../models/homelife/child_profile.dart';

import '../../../../../providers/homelife/workout_routine_provider.dart';
import '../../../../../providers/homelife/calendar_provider.dart';
import '../../../../../providers/homelife/child_profile_provider.dart';
import '../../../../nav/providers/navigation_store.dart';

class HomelifePersonalTab extends StatefulWidget {
  const HomelifePersonalTab({Key? key}) : super(key: key);

  @override
  State<HomelifePersonalTab> createState() => _HomelifePersonalTabState();
}

class _HomelifePersonalTabState extends State<HomelifePersonalTab> {
  bool _bootstrapped = false;

  /* ───────────────────────── bootstrap & refresh ────────────────────── */
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bootstrapped) return;
    _bootstrapped = true;

    final wr = context.read<WorkoutRoutineProvider>();
    final ca = context.read<CalendarProvider>();
    final cp = context.read<ChildProfileProvider>();

    Future.wait([
      wr.loadWorkoutRoutines(),
      ca.loadCalendarEvents(),
      cp.loadChildProfiles(),
    ]);

    context.read<NavigationStore>().setRefreshCallback(() async {
      await Future.wait([
        wr.loadWorkoutRoutines(),
        ca.loadCalendarEvents(),
        cp.loadChildProfiles(),
      ]);
    });
  }

  /* ───────────────────────── calendar helpers ───────────────────────── */
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<SharedCalendarEvent>> _groupEvents(
      List<SharedCalendarEvent> events) {
    final Map<DateTime, List<SharedCalendarEvent>> data = {};
    for (final e in events) {
      final start = DateTime.parse(e.startDatetime);
      final key = DateTime.utc(start.year, start.month, start.day);
      data.putIfAbsent(key, () => []).add(e);
    }
    return data;
  }

  /* ───────────────────────── small helpers ──────────────────────────── */
  final _dateFmt = DateFormat('MMM d, yyyy');
  final _timeFmt = DateFormat('h:mm a');

  Widget _empty(String asset, String msg) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Column(
      children: [
        SvgPicture.asset(asset, height: 100),
        const SizedBox(height: 12),
        Text(msg,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge),
      ],
    ),
  );

  /* ───────────────────────── card builders ──────────────────────────── */
  Widget _workoutCard(WorkoutRoutine w) => _SimpleCard(
    leading: Icons.fitness_center,
    title: w.title,
    subtitle: w.schedule,
  );

  Widget _calendarCard(SharedCalendarEvent ev) {
    final st = DateTime.parse(ev.startDatetime);
    return _SimpleCard(
      leading: Icons.event,
      title: ev.title,
      subtitle: '${_dateFmt.format(st)} · ${_timeFmt.format(st)}',
    );
  }

  Widget _childCard(ChildProfile c) {
    String subtitle = 'Date of birth not provided';
    if (c.dateOfBirth != null && c.dateOfBirth!.isNotEmpty) {
      final dob = DateTime.parse(c.dateOfBirth!);
      final age = DateTime.now().difference(dob).inDays ~/ 365;
      subtitle = 'Age $age';
    }
    return _SimpleCard(
      leading: Icons.child_care,
      title: c.name,
      subtitle: subtitle,
    );
  }

  /* ───────────────────────────── build ──────────────────────────────── */
  @override
  Widget build(BuildContext context) {
    final wr = context.watch<WorkoutRoutineProvider>();
    final ca = context.watch<CalendarProvider>();
    final cp = context.watch<ChildProfileProvider>();

    /* --------- CALENDAR SECTION (always full‑width) --------- */
    final calendarSliver = SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Material(
          elevation: 1,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: Container(
            color:
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(.4),
            padding: const EdgeInsets.all(16),
            child: ca.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TableCalendar<SharedCalendarEvent>(
              firstDay: DateTime.utc(2020),
              lastDay: DateTime.utc(2100),
              focusedDay: _focusedDay,
              selectedDayPredicate: (d) =>
              _selectedDay != null &&
                  d.year == _selectedDay!.year &&
                  d.month == _selectedDay!.month &&
                  d.day == _selectedDay!.day,
              eventLoader: (day) {
                final map = _groupEvents(ca.calendarEvents);
                final key = DateTime.utc(day.year, day.month, day.day);
                return map[key] ?? [];
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (sel, foc) {
                setState(() {
                  _selectedDay = sel;
                  _focusedDay = foc;
                });
              },
            ),
          ),
        ),
      ),
    );

    /* --------- GRID SECTIONS (adaptive columns) --------- */
    final List<_GridSection> sections = [
      _GridSection(
        header: 'Workout routines',
        icon: Icons.fitness_center,
        content: wr.isLoading
            ? const Center(child: CircularProgressIndicator())
            : (wr.workoutRoutines.isEmpty
            ? _empty('assets/images/empty_workout.svg',
            'No workout routines yet.\nTap ＋ to add one.')
            : Column(
          children:
          wr.workoutRoutines.map(_workoutCard).toList(growable: false),
        )),
      ),
      _GridSection(
        header: 'Upcoming events',
        icon: Icons.calendar_today,
        content: ca.isLoading
            ? const Center(child: CircularProgressIndicator())
            : (ca.calendarEvents.isEmpty
            ? _empty('assets/images/empty_calendar.svg',
            'No events.\nTap ＋ to add one.')
            : Column(
          children: ca.calendarEvents
              .where((e) =>
              DateTime.parse(e.endDatetime)
                  .isAfter(DateTime.now()))
              .map(_calendarCard)
              .toList(growable: false),
        )),
      ),
      _GridSection(
        header: 'Child profiles',
        icon: Icons.family_restroom,
        content: cp.isLoading
            ? const Center(child: CircularProgressIndicator())
            : (cp.childProfiles.isEmpty
            ? _empty('assets/images/empty_family.svg',
            'No child profiles.\nTap ＋ to add one.')
            : Column(
          children:
          cp.childProfiles.map(_childCard).toList(growable: false),
        )),
      ),
    ];

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          wr.loadWorkoutRoutines(),
          ca.loadCalendarEvents(),
          cp.loadChildProfiles(),
        ]);
      },
      child: LayoutBuilder(builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        int columns = 1;
        if (maxWidth >= 1200) {
          columns = 4;
        } else if (maxWidth >= 900) {
          columns = 3;
        } else if (maxWidth >= 600) {
          columns = 2;
        }

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            calendarSliver,
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                      (_, i) => sections[i],
                  childCount: sections.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

/* ───────────────────────── helper widgets ─────────────────────────── */

class _SimpleCard extends StatelessWidget {
  const _SimpleCard({
    required this.leading,
    required this.title,
    required this.subtitle,
  });

  final IconData leading;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(leading,
              size: 28, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _GridSection extends StatelessWidget {
  const _GridSection({
    required this.header,
    required this.icon,
    required this.content,
  });

  final String header;
  final IconData icon;
  final Widget content;

  @override
  Widget build(BuildContext context) => Material(
    elevation: 1,
    borderRadius: BorderRadius.circular(20),
    clipBehavior: Clip.antiAlias,
    child: Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  color: Theme.of(context).colorScheme.secondary, size: 22),
              const SizedBox(width: 6),
              Expanded(
                child: Text(header,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: content),
        ],
      ),
    ),
  );
}