/// lib/widgets/tabs/homelife_household_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kobrasuite_app/providers/homelife/calendar_provider.dart';
import '../../../../widgets/calendar/homelife_full_calendar.dart';

class HomelifeHouseholdTab extends StatefulWidget {
  const HomelifeHouseholdTab({Key? key}) : super(key: key);

  @override
  State<HomelifeHouseholdTab> createState() => _HomelifeHouseholdTabState();
}

class _HomelifeHouseholdTabState extends State<HomelifeHouseholdTab> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final calendarProv = Provider.of<CalendarProvider>(context);
    if (!_initialized && calendarProv.householdPk != null) {
      _initialized = true;
      final now = DateTime.now();
      calendarProv.loadCalendarEventsRange(
        DateTime(now.year, now.month, 1),
        DateTime(now.year, now.month + 1, 0, 23, 59, 59),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: HomelifeFullCalendar(),
    );
  }
}