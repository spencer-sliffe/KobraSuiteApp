import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kobrasuite_app/models/homelife/assignee.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

import '../../../../../models/homelife/chore.dart';
import '../../../../../models/homelife/chore_completion.dart';
import '../../../../../providers/homelife/chore_completion_provider.dart';
import '../../../../../providers/homelife/chore_provider.dart';

/// ---------------------------------------------------------------------------
/// HomelifeChoresTab – Kanban‑style board (To Do / Done)
/// ---------------------------------------------------------------------------
/// • Hover: slight elevation + colour tint
/// • Press‑and‑drag (no long‑press delay) on desktop / web; long‑press on touch
///   devices.  Drop onto the opposite column to toggle completion for the
///   selected day.
/// ---------------------------------------------------------------------------
class HomelifeChoresTab extends StatefulWidget {
  const HomelifeChoresTab({super.key});

  @override
  State<HomelifeChoresTab> createState() => _HomelifeChoresTabState();
}

class _HomelifeChoresTabState extends State<HomelifeChoresTab> {
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final choreProv = context.read<ChoreProvider>();
    final compProv  = context.read<ChoreCompletionProvider>();

    await choreProv.loadChores();
    for (final c in choreProv.chores) {
      await compProv.loadChoreCompletions(c.id);
    }
  }

  bool _isCompletedToday(Chore chore, List<ChoreCompletion> comps) {
    final chk = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    return comps.any((cc) {
      final dt = DateTime.parse(cc.completedAt).toLocal();
      return dt.year == chk.year && dt.month == chk.month && dt.day == chk.day;
    });
  }

  @override
  Widget build(BuildContext context) {
    final choreProv = context.watch<ChoreProvider>();
    final compProv  = context.watch<ChoreCompletionProvider>();

    final toDo = <Chore>[];
    final done = <Chore>[];

    for (final ch in choreProv.chores) {
      final comps = compProv.completionsForChore(ch.id);
      if (_isCompletedToday(ch, comps)) {
        done.add(ch);
      } else {
        toDo.add(ch);
      }
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDay,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _selectedDay = picked);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Row(
          children: [
            _buildColumn(
              label: 'To Do',
              chores: toDo,
              // dropping **onto** the To‑Do bucket should mark the chore *undone*
              acceptDropped: (c) => _toggle(context, c, done: false),
            ),
            _buildColumn(
              label: 'Done',
              chores: done,
              // dropping **onto** Done marks the chore completed
              acceptDropped: (c) => _toggle(context, c, done: true),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────── columns ────────────────────────────────
  Widget _buildColumn({
    required String label,
    required List<Chore> chores,
    required Future<void> Function(Chore) acceptDropped,
  }) {
    return Expanded(
      child: DragTarget<Chore>(
        onWillAccept: (_) => true,
        // defer state‑mutating work until after frame
        onAccept: (c) => Future.microtask(() => acceptDropped(c)),

        builder: (ctx, cand, _) {
          final highlight = cand.isNotEmpty;
          return Card(
            elevation: highlight ? 6 : 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: highlight
                ? Theme.of(ctx).colorScheme.secondaryContainer
                : Theme.of(ctx).colorScheme.surface,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(12),
                  child: Text(label, style: Theme.of(ctx).textTheme.titleMedium),
                ),
                const Divider(height: 0),
                Expanded(
                  child: chores.isEmpty
                      ? _emptyState(ctx)
                      : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: chores.length,
                    itemBuilder: (_, i) => _ChoreCard(chore: chores[i]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState(BuildContext ctx) => Center(
    child: Text('Nothing here', style: Theme.of(ctx).textTheme.bodySmall),
  );

  Future<void> _toggle(BuildContext ctx, Chore chore, {required bool done}) async {
    final compProv = ctx.read<ChoreCompletionProvider>();

    final todayComp = compProv
        .completionsForChore(chore.id)
        .firstWhereOrNull((cc) => _isCompletedToday(chore, [cc]));

    if (done && todayComp == null) {
      await compProv.createChoreCompletion(chore.id);
    } else if (!done && todayComp != null) {
      await compProv.deleteChore(chore.id, todayComp.id);
    }
  }
}

// ───────────────────────────── card widget ────────────────────────────────
class _ChoreCard extends StatefulWidget {
  const _ChoreCard({required this.chore});
  final Chore chore;

  @override
  State<_ChoreCard> createState() => _ChoreCardState();
}

class _ChoreCardState extends State<_ChoreCard> {
  bool _hover = false;
  bool _dragging = false;

  bool get _useLongPress {
    // touch devices → long‑press to avoid accidental drags
    if (kIsWeb) return false; // browser supports mouse events
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final card = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        // precedence fix – wrap cascade in parens
        transform: _hover
            ? (Matrix4.identity()..scale(1.02))
            : Matrix4.identity(),
        child: Card(
          elevation: _hover || _dragging ? 6 : 2,
          color: _hover
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          child: ListTile(
            title: Text(widget.chore.title),
            subtitle: Text(widget.chore.description),
            trailing: Text(DateFormat('MMM d').format(
                DateTime.parse(widget.chore.createdAt).toLocal())),
          ),
        ),
      ),
    );

    final draggable = _useLongPress
        ? LongPressDraggable<Chore>(
      data: widget.chore,
      feedback: Material(
        elevation: 6,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
          child: card,
        ),
      ),
      onDragStarted: () => setState(() => _dragging = true),
      onDraggableCanceled: (_, __) => setState(() => _dragging = false),
      onDragEnd: (_) => setState(() => _dragging = false),
      childWhenDragging: Opacity(opacity: 0.4, child: card),
      child: card,
    )
        : Draggable<Chore>(
      data: widget.chore,
      feedback: Material(
        elevation: 6,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
          child: card,
        ),
      ),
      onDragStarted: () => setState(() => _dragging = true),
      onDraggableCanceled: (_, __) => setState(() => _dragging = false),
      onDragEnd: (_) => setState(() => _dragging = false),
      childWhenDragging: Opacity(opacity: 0.4, child: card),
      child: card,
    );

    return draggable;
  }
}