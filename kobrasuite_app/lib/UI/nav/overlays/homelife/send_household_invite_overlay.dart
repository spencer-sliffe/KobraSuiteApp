import 'package:flutter/material.dart';
import '../../../widgets/homelife/send_household_invite_bottom_sheet.dart';
import '../universal_bottom_overlay.dart';


class SendHouseholdInviteOverlay extends StatelessWidget {
  const SendHouseholdInviteOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the bottom sheet with UniversalBottomOverlay so it fills the available space.
    return UniversalBottomOverlay(child: const SendHouseholdInviteBottomSheet());
  }
}