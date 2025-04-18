import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/homelife/household_invite_provider.dart';
import '../../nav/providers/navigation_store.dart';

enum SendHouseholdInviteState { initial, sending, sent }

class SendHouseholdInviteBottomSheet extends StatefulWidget {
  const SendHouseholdInviteBottomSheet({Key? key}) : super(key: key);

  @override
  State<SendHouseholdInviteBottomSheet> createState() =>
      _SendHouseholdInviteBottomSheetState();
}

class _SendHouseholdInviteBottomSheetState
    extends State<SendHouseholdInviteBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _inviteCodeController = TextEditingController();

  SendHouseholdInviteState _state = SendHouseholdInviteState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _sendInvite() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = SendHouseholdInviteState.sending;
      _errorFeedback = "";
    });
    final householdInviteProvider = context.read<HouseholdInviteProvider>();
    final success = await householdInviteProvider.createHouseholdInvite(
      code: _inviteCodeController.text.trim()
    );

    if (success) {
      setState(() {
        _state = SendHouseholdInviteState.sent;
      });
    } else {
      setState(() {
        _errorFeedback = 'Failed to send invite.';
        _state = SendHouseholdInviteState.initial;
      });
    }
  }


  Widget _buildContent() {
    if (_state == SendHouseholdInviteState.sending) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Sending invite...'),
            ],
          ),
        ),
      );
    }
    if (_state == SendHouseholdInviteState.sent) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Invite sent successfully.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      );
    }
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Invite Code Field.
            TextFormField(
              controller: _inviteCodeController,
              decoration: const InputDecoration(labelText: 'Invite Code'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter invite code' : null,
            ),
            if (_errorFeedback.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorFeedback,
                  style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    if (_state == SendHouseholdInviteState.sent) {
      return [
        TextButton(
          onPressed: ()
          => context.read<NavigationStore>().setSendHouseholdInviteActive(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == SendHouseholdInviteState.initial) {
      return [
        TextButton(
          onPressed: ()
          => context.read<NavigationStore>().setSendHouseholdInviteActive(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _sendInvite,
          child: const Text('Send Invite'),
        ),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Send Household Invite',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _buildContent(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildActions(),
            )
          ],
        ),
      ),
    );
  }
}