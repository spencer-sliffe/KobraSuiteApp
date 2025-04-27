// lib/UI/widgets/cards/finance/bank_account_card.dart
import 'package:flutter/material.dart';
import '../../../../models/finance/bank_account.dart';

class BankAccountCard extends StatelessWidget {
  final BankAccount account;

  /// Called when the user taps the whole card (opens the detail sheet, etc.).
  final VoidCallback? onTap;

  /// Optional delete / unlink handler.
  final VoidCallback? onDelete;

  const BankAccountCard({
    super.key,
    required this.account,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
        onTap: onTap,                                     // ← NEW
        title: Text(account.accountName),
        subtitle: Text('${account.institutionName} • ${account.accountNumber}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('\$${account.balance.toStringAsFixed(2)}'),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}