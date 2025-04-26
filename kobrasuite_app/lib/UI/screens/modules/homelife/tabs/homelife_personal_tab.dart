import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/* ── providers & models ───────────────────────────────────────────── */
import '../../../../../providers/general/homelife_profile_provider.dart';
import '../../../../../providers/homelife/workout_routine_provider.dart';
import '../../../../../providers/homelife/calendar_provider.dart';
import '../../../../../providers/homelife/child_profile_provider.dart';
import '../../../../../providers/homelife/medication_provider.dart';
import '../../../../../providers/homelife/medical_appointment_provider.dart';
import '../../../../../models/homelife/medical_appointment.dart';
import '../../../../nav/providers/navigation_store.dart';
import '../../../../widgets/calendar/personal_week_calendar.dart';

/// Personal tab – shows workouts, meds, appointments & children,
/// filtered to the day the user selects in the header calendar.
class HomelifePersonalTab extends StatefulWidget {
  const HomelifePersonalTab({super.key});

  @override
  State<HomelifePersonalTab> createState() => _HomelifePersonalTabState();
}

class _HomelifePersonalTabState extends State<HomelifePersonalTab> {
  bool _boot = false;
  DateTime _selectedDay = DateTime.now();

  /* ── bootstrap & refresh ─────────────────────────────────────────── */
  @override
  Future<void> didChangeDependencies() async {
    await Future.delayed(const Duration(milliseconds: 400)); // avoid double-loads
    super.didChangeDependencies();
    if (_boot) return;

    final profile = context.read<HomeLifeProfileProvider>();
    if (profile.householdPk == null) {
      profile.addListener(_retryWhenReady);
      return;
    }
    _startLoads();
  }

  void _retryWhenReady() {
    final profile = context.read<HomeLifeProfileProvider>();
    if (profile.householdPk != null) {
      profile.removeListener(_retryWhenReady);
      _startLoads();
    }
  }

  void _startLoads() {
    _boot = true;
    final wr   = context.read<WorkoutRoutineProvider>();
    final ca   = context.read<CalendarProvider>();
    final cp   = context.read<ChildProfileProvider>();
    final meds = context.read<MedicationProvider>();
    final appt = context.read<MedicalAppointmentProvider>();

    Future.wait([
      wr.loadWorkoutRoutines(),
      ca.loadCalendarEvents(),
      cp.loadChildProfiles(),
      meds.loadMedications(),
      appt.loadMedicalAppointments(),
    ]);

    context.read<NavigationStore>().setRefreshCallback(() async {
      await Future.wait([
        wr.loadWorkoutRoutines(),
        ca.loadCalendarEvents(),
        cp.loadChildProfiles(),
        meds.loadMedications(),
        appt.loadMedicalAppointments(),
      ]);
    });
  }

  /* ── helpers ─────────────────────────────────────────────────────── */
  final _dateFmt  = DateFormat('MMM d, yyyy');
  final _timeFmt  = DateFormat('h:mm a');
  final _monthFmt = DateFormat('MMMM yyyy');

  Widget _empty(String asset, String msg) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(asset, height: 100),
        const SizedBox(height: 12),
        Text(msg,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge),
      ],
    ),
  );

  Widget _simpleCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) =>
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
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis),
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
    final wr   = context.watch<WorkoutRoutineProvider>();
    final cp   = context.watch<ChildProfileProvider>();
    final meds = context.watch<MedicationProvider>();
    final appt = context.watch<MedicalAppointmentProvider>();

    /* filters for the chosen calendar day */
    bool _sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    /* workout routines – filter by weekday name ---------------------- */
    final String _weekdayName =
    DateFormat('EEEE').format(_selectedDay).toUpperCase(); // e.g. MONDAY

    final workoutsToday = wr.workoutRoutines.where((r) {
      // r.schedule is a List<String> of weekday names
      return r.schedule.map((d) => d.toUpperCase()).contains(_weekdayName);
    }).toList();

    /* sections ------------------------------------------------------- */

    // workouts
    Widget workoutsSection() => wr.isLoading
        ? const Center(child: CircularProgressIndicator())
        : workoutsToday.isEmpty
        ? _empty('assets/images/empty_workout.svg',
        'No workout routines for the selected day.')
        : ListView(
      padding: EdgeInsets.zero,
      children: workoutsToday
          .map((w) => _simpleCard(
        icon: Icons.fitness_center,
        title: w.title,
        subtitle: w.description,
      ))
          .toList(growable: false),
    );

    // medications (filtered to doses today)
    final medsToday = meds.medications.where((m) {
      if (m.nextDose == null) return false;
      final next = DateTime.parse(m.nextDose!);
      return _sameDay(next, _selectedDay);
    }).toList();

    Widget medicationsSection() => meds.isLoading
        ? const Center(child: CircularProgressIndicator())
        : medsToday.isEmpty
        ? _empty('assets/images/empty_pills.svg',
        'No medications for the selected day.')
        : ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: medsToday.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final m = medsToday[i];
        final next = DateTime.parse(m.nextDose!);
        return Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: const Icon(Icons.medication, size: 32),
            title: Text(m.name,
                style: Theme.of(context).textTheme.titleMedium),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${m.dosage} • ${m.frequency}'),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, size: 14),
                      const SizedBox(width: 4),
                      Text(
                          '${_dateFmt.format(next)} • ${_timeFmt.format(next)}'),
                    ],
                  ),
                ),
              ],
            ),
            trailing: Checkbox(
              value: false,
              onChanged: (_) {
                // TODO: hit “log-dose” endpoint when backend available
              },
              shape: const CircleBorder(),
            ),
          ),
        );
      },
    );

    // appointments (filtered to today)
    final apptsToday = appt.medicalAppointments.where((ap) {
      final dt = DateTime.parse(ap.appointmentDatetime);
      return _sameDay(dt, _selectedDay);
    }).toList();

    Widget appointmentsSection() => appt.isLoading
        ? const Center(child: CircularProgressIndicator())
        : apptsToday.isEmpty
        ? _empty('assets/images/empty_calendar.svg',
        'No appointments for the selected day.')
        : ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: apptsToday.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final ap = apptsToday[i];
        final dt = DateTime.parse(ap.appointmentDatetime);
        return Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading:
            const Icon(Icons.local_hospital, size: 30),
            title: Text(ap.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${_dateFmt.format(dt)} • ${_timeFmt.format(dt)}'),
                if (ap.location.isNotEmpty) Text(ap.location),
                if (ap.doctorName.isNotEmpty)
                  Text('Dr. ${ap.doctorName}'),
              ],
            ),
          ),
        );
      },
    );

    // children
    Widget childrenSection() => cp.isLoading
        ? const Center(child: CircularProgressIndicator())
        : cp.childProfiles.isEmpty
        ? _empty('assets/images/empty_family.svg',
        'No child profiles.\nTap ＋ to add one.')
        : ListView(
      padding: EdgeInsets.zero,
      children: cp.childProfiles.map((c) {
        String subtitle = 'Date of birth not provided';
        if (c.dateOfBirth != null && c.dateOfBirth!.isNotEmpty) {
          final dob = DateTime.parse(c.dateOfBirth!);
          final age =
              DateTime.now().difference(dob).inDays ~/ 365;
          subtitle = 'Age $age';
        }
        return _simpleCard(
            icon: Icons.child_care,
            title: c.name,
            subtitle: subtitle);
      }).toList(growable: false),
    );

    /* responsive grid ------------------------------------------------ */
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          wr.loadWorkoutRoutines(),
          context.read<CalendarProvider>().loadCalendarEvents(),
          cp.loadChildProfiles(),
          meds.loadMedications(),
          appt.loadMedicalAppointments(),
        ]);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width  = constraints.maxWidth;
          final height = constraints.maxHeight;
          final cols = width >= 1200
              ? 4
              : width >= 900
              ? 3
              : width >= 600
              ? 2
              : 1;

          final aspectRatio = (width / cols) / height; // row = full height

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              /* week-calendar header */
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
              /* grid of sections */
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverGrid(
                  delegate: SliverChildListDelegate.fixed([
                    _GridSection(
                        header:
                        'Workout routines • ${DateFormat('MMM d').format(_selectedDay)}',
                        icon: Icons.fitness_center,
                        content: workoutsSection()),
                    _GridSection(
                        header:
                        'Medications • ${DateFormat('MMM d').format(_selectedDay)}',
                        icon: Icons.medication_liquid,
                        content: medicationsSection()),
                    _GridSection(
                        header:
                        'Appointments • ${DateFormat('MMM d').format(_selectedDay)}',
                        icon: Icons.event,
                        content: appointmentsSection()),
                    _GridSection(
                        header: 'Child profiles',
                        icon: Icons.family_restroom,
                        content: childrenSection()),
                  ]),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: aspectRatio,
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
      color:
      Theme.of(context).colorScheme.surfaceVariant.withOpacity(.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 22),
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