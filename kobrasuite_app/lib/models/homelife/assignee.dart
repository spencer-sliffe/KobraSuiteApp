enum AssigneeType { adult, child }

// lib/models/homelife/assignee.dart  (or wherever Assignee lives)
class Assignee {
  final int id;
  final String name;
  final AssigneeType type;
  const Assignee({required this.id, required this.name, required this.type});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Assignee && other.id == id && other.type == type;

  @override
  int get hashCode => Object.hash(id, type);
}

extension AssigneeKey on Assignee {
  String get key => '${type.name}_$id';
}

extension FirstWhereOrNull<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}