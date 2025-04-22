import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../providers/homelife/calendar_provider.dart';
import '../../../../widgets/calendar/homelife_full_calendar.dart';

class HomelifeHouseholdTab extends StatefulWidget {
  const HomelifeHouseholdTab({super.key});

  @override
  State<HomelifeHouseholdTab> createState() => _HomelifeHouseholdTabState();
}

class _HomelifeHouseholdTabState extends State<HomelifeHouseholdTab> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
  // bool _boot = false;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (_boot) return;
  //   _boot = true;
  //
  //   final provider = context.read<CalendarProvider>();
  //   final now = DateTime.now();
  //   provider.loadCalendarEventsRange(
  //     DateTime(now.year, now.month, 1),
  //     DateTime(now.year, now.month + 1, 0, 23, 59, 59),
  //   );
  // }

//   @override
//   Widget build(BuildContext context) =>
//       // const Padding(padding: EdgeInsets.all(8), child: HomelifeFullCalendar());
// }}
