import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/model_kind_enum.dart';
import '../../../../providers/finance/bank_account_provider.dart';
import '../../../nav/providers/detail_delagate_registry.dart';
import '../../../nav/providers/navigation_store.dart';

class BankAccountDetailSheet extends StatelessWidget {
  final int id;
  const BankAccountDetailSheet({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BankAccountProvider>();
    final acct = provider.byId(id);

    if (acct == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: Text(acct.accountName),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.read<NavigationStore>().closeDetail(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(title: const Text('Institution'), subtitle: Text(acct.institutionName)),
          ListTile(title: const Text('Account #'),  subtitle: Text(acct.accountNumber)),
          ListTile(title: const Text('Balance'),     subtitle: Text('${acct.balance} ${acct.currency}')),
          if (acct.lastSynced != null)
            ListTile(title: const Text('Last synced'), subtitle: Text(acct.lastSynced!)),
        ],
      ),
    );
  }

  // **one‑time registration** (can live in a static init block)
  static void register() {
    DetailDelegateRegistry.register(
      ModelKind.bankAccount,
          (_, t) => BankAccountDetailSheet(id: t.id),
    );
  }
}