import 'model_kind_enum.dart';

class DetailTarget {
  final ModelKind kind;
  final int id;                              // primary key on the server
  final Map<String, dynamic>? preview;       // optional cheap fields (title, amount…)
  const DetailTarget({required this.kind, required this.id, this.preview});
}