import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tiny reusable Notifiers so the PoC stays codegen-free (Riverpod 3.x API).
class BoolNotifier extends Notifier<bool> {
  BoolNotifier(this._initial);

  final bool _initial;

  @override
  bool build() => _initial;

  void set(bool value) => state = value;
}

class StringNotifier extends Notifier<String> {
  StringNotifier(this._initial);

  final String _initial;

  @override
  String build() => _initial;

  void set(String value) => state = value;
}
