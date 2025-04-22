import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../providers/homelife/workout_routine_provider.dart';
import '../../../../../providers/homelife/calendar_provider.dart';
import '../../../../../providers/homelife/child_profile_provider.dart';
import '../../../../nav/providers/navigation_store.dart';
import '../../../../widgets/calendar/personal_week_calendar.dart';

class HomelifePersonalTab extends StatefulWidget {
  const HomelifePersonalTab({Key? key}) : super(key: key);

  @override
  State<HomelifePersonalTab> createState() => _HomelifePersonalTabState();
}

class _HomelifePersonalTabState extends State<HomelifePersonalTab> {
  bool _boot = false;
  DateTime _selectedDay = DateTime.now();

  /* ── bootstrap & refresh ─────────────────────────────────────────── */
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_boot) return;
    _boot = true;

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

  /* ── helpers ─────────────────────────────────────────────────────── */
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

  Widget _simpleCard(
      {required IconData icon,
        required String title,
        required String subtitle}) =>
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon,
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

  /* ── build ────────────────────────────────────────────────────────── */
  @override
  Widget build(BuildContext context) {
    final wr = context.watch<WorkoutRoutineProvider>();
    final ca = context.watch<CalendarProvider>();
    final cp = context.watch<ChildProfileProvider>();

    /* filter events for selected day */
    final todayEvents = ca.calendarEvents.where((e) {
      final start = DateTime.parse(e.startDatetime);
      return start.year == _selectedDay.year &&
          start.month == _selectedDay.month &&
          start.day == _selectedDay.day;
    }).toList();

    /* sections ------------------------------------------------------- */
    Widget workoutsSection() => wr.isLoading
        ? const Center(child: CircularProgressIndicator())
        : (wr.workoutRoutines.isEmpty
        ? _empty('assets/images/empty_workout.svg',
        'No workout routines today.')
        : Column(
      children: wr.workoutRoutines
          .map((w) => _simpleCard(
        icon: Icons.fitness_center,
        title: w.title,
        subtitle: w.description,
      ))
          .toList(growable: false),
    ));

    Widget eventsSection() => ca.isLoading
        ? const Center(child: CircularProgressIndicator())
        : (todayEvents.isEmpty
        ? _empty('assets/images/empty_calendar.svg',
        'No events for today.')
        : Column(
      children: todayEvents
          .map((e) => _simpleCard(
        icon: Icons.event,
        title: e.title,
        subtitle:
        '${_dateFmt.format(DateTime.parse(e.startDatetime))} · ${_timeFmt.format(DateTime.parse(e.startDatetime))}',
      ))
          .toList(growable: false),
    ));

    Widget childrenSection() => cp.isLoading
        ? const Center(child: CircularProgressIndicator())
        : (cp.childProfiles.isEmpty
        ? _empty('assets/images/empty_family.svg',
        'No child profiles.\nTap ＋ to add one.')
        : Column(
      children: cp.childProfiles.map((c) {
        String subtitle = 'Date of birth not provided';
        if (c.dateOfBirth != null && c.dateOfBirth!.isNotEmpty) {
          final dob = DateTime.parse(c.dateOfBirth!);
          final age =
              DateTime.now().difference(dob).inDays ~/ 365;
          subtitle = 'Age $age';
        }
        return _simpleCard(
            icon: Icons.child_care,
            title: c.name,
            subtitle: subtitle);
      }).toList(growable: false),
    ));

    /* responsive grid ------------------------------------------------ */
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          wr.loadWorkoutRoutines(),
          ca.loadCalendarEvents(),
          cp.loadChildProfiles(),
        ]);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final cols = width >= 1200
              ? 4
              : width >= 900
              ? 3
              : width >= 600
              ? 2
              : 1;

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Material(
                    elevation: 1,
                    borderRadius: BorderRadius.circular(20),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(.4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: PersonalWeekCalendar(
                        onDaySelected: (sel, _) =>
                            setState(() => _selectedDay = sel),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverGrid(
                  delegate: SliverChildListDelegate.fixed([
                    _GridSection(
                        header: 'Workout routines',
                        icon: Icons.fitness_center,
                        content: workoutsSection()),
                    _GridSection(
                        header: 'Events • ${DateFormat('MMM d').format(_selectedDay)}',
                        icon: Icons.calendar_today,
                        content: eventsSection()),
                    _GridSection(
                        header: 'Child profiles',
                        icon: Icons.family_restroom,
                        content: childrenSection()),
                  ]),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/* ── section shell ─────────────────────────────────────────────────── */
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