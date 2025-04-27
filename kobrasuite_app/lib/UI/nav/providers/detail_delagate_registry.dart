import 'package:flutter/material.dart';
import '../../../models/detail_target.dart';
import '../../../models/model_kind_enum.dart';

typedef DetailDelegateBuilder = Widget Function(
    BuildContext context,
    DetailTarget target,
    );

class DetailDelegateRegistry {
  static final Map<ModelKind, DetailDelegateBuilder> _map = {};

  static void register(
      ModelKind kind,
      DetailDelegateBuilder builder,
      ) {
    _map[kind] = builder;
  }

  static DetailDelegateBuilder? builderFor(ModelKind kind) => _map[kind];
}