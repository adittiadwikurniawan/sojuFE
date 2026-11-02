import 'package:flutter/material.dart';

/// Helper untuk menanamkan callback ke tombol di page tanpa mengubah tiap file.
/// Kita tambahkan property via InheritedWidget sederhana.
class OnNav extends InheritedWidget {
  const OnNav({
    super.key,
    required this.onNext,
    required this.onPrev,
    required super.child,
  });

  final VoidCallback onNext;
  final VoidCallback onPrev;

  static OnNav of(BuildContext context) {
    final nav = context.dependOnInheritedWidgetOfExactType<OnNav>();
    assert(nav != null, 'OnNav not found in context');
    return nav!;
  }

  @override
  bool updateShouldNotify(covariant OnNav oldWidget) =>
      onNext != oldWidget.onNext || onPrev != oldWidget.onPrev;
}