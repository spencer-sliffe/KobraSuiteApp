import 'package:flutter/material.dart';
import '../../../models/detail_target.dart';
import '../../../models/model_kind_enum.dart';
import '../providers/detail_delagate_registry.dart';
import 'universal_bottom_overlay.dart';

class UniversalDetailOverlay extends StatelessWidget {
  final DetailTarget target;

  const UniversalDetailOverlay({super.key, required this.target});

  @override
  Widget build(BuildContext context) {
    final builder = DetailDelegateRegistry.builderFor(target.kind);

    return UniversalBottomOverlay(
      child: builder != null
          ? builder(context, target)
          : _DefaultDetailWidget(kind: target.kind, id: target.id),
    );
  }
}

/// Shown only when no delegate was registered.
class _DefaultDetailWidget extends StatelessWidget {
  final ModelKind kind;
  final int id;

  const _DefaultDetailWidget({
    super.key,
    required this.kind,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$kind #$id')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No detail widget is registered for this model.\n'
                'Create one and add it with DetailDelegateRegistry.register().',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}