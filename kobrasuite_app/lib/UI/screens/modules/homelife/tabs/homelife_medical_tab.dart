import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../models/homelife/medical_appointment.dart';
import '../../../../../providers/homelife/medical_appointment_provider.dart';
import '../../../../../providers/homelife/medication_provider.dart';
import '../../../../nav/providers/navigation_store.dart';

class HomelifeMedicalTab extends StatefulWidget {
  const HomelifeMedicalTab({Key? key}) : super(key: key);

  @override
  State<HomelifeMedicalTab> createState() => _HomelifeMedicalTabState();
}

class _HomelifeMedicalTabState extends State<HomelifeMedicalTab> {
  bool _bootstrapped = false;

  // ───────────────────────────────────────────────────────── bootstrap
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_bootstrapped) {
      _bootstrapped = true;
      // initial fetch
      final meds = context.read<MedicationProvider>();
      final appts = context.read<MedicalAppointmentProvider>();
      meds.loadMedications();
      appts.loadMedicalAppointments();

      // connect global refresh button
      // connect global “Refresh” button
      context.read<NavigationStore>().setRefreshCallback(() async {
        await Future.wait([
          meds.loadMedications(),
          appts.loadMedicalAppointments(),
        ]);
      });
    }
  }

  // ───────────────────────────────────────────────────────── helpers
  Widget _buildSectionHeader(String text, IconData icon) => Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.headlineSmall),
        ],
      );

  // pretty date‑formatters
  final _dateFmt = DateFormat('MMM d, yyyy');
  final _timeFmt = DateFormat('h:mm a');
  final _monthFmt = DateFormat('MMMM yyyy');

  // ───────────────────────────────────────────────────────── medication
  Widget _medications(MedicationProvider p) {
    if (p.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p.medications.isEmpty) {
      return _emptyState(
        asset: 'assets/images/empty_pills.svg',
        msg: 'No medications yet.\nTap ＋ to add one.',
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: p.medications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final m = p.medications[i];
        final next = m.nextDose != null ? DateTime.parse(m.nextDose!) : null;
        final theme = Theme.of(context);
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: const Icon(Icons.medication, size: 32),
            title: Text(m.name, style: theme.textTheme.titleMedium),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${m.dosage} • ${m.frequency}'),
                if (next != null)
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
                // TODO: hit “log‑dose” endpoint when backend available
              },
              shape: const CircleBorder(),
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────── appointments
  Widget _appointments(MedicalAppointmentProvider p) {
    if (p.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p.medicalAppointments.isEmpty) {
      return _emptyState(
        asset: 'assets/images/empty_calendar.svg',
        msg: 'No upcoming appointments.\nTap ＋ to schedule one.',
      );
    }

    // group by month
    final Map<String, List<MedicalAppointment>> byMonth = {};
    for (final ap in p.medicalAppointments) {
      final dt = DateTime.parse(ap.appointmentDatetime);
      final key = _monthFmt.format(dt);
      byMonth.putIfAbsent(key, () => []).add(ap);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: byMonth.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: entry.value.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final ap = entry.value[i];
                  final dt = DateTime.parse(ap.appointmentDatetime);
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: const Icon(Icons.local_hospital, size: 30),
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
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ───────────────────────────────────────────────────────── empty‑state
  Widget _emptyState({required String asset, required String msg}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            SvgPicture.asset(asset, height: 120),
            const SizedBox(height: 16),
            Text(msg,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );

  // ───────────────────────────────────────────────────────── build
  @override
  Widget build(BuildContext context) {
    final medsProv = context.watch<MedicationProvider>();
    final apptProv = context.watch<MedicalAppointmentProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          medsProv.loadMedications(),
          apptProv.loadMedicalAppointments(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Medication schedule', Icons.medication_liquid),
            const SizedBox(height: 12),
            _medications(medsProv),
            const SizedBox(height: 32),
            _buildSectionHeader('Upcoming appointments', Icons.event),
            const SizedBox(height: 12),
            _appointments(apptProv),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
