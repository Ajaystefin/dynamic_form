import "package:flutter/material.dart";

/// A provider class for managing Semantics Debug state across the app.
/// This ensures that the Semantics Debugger can be toggled from any screen.
class SemanticsProvider extends InheritedWidget {
  /// Constructor: Requires `showSemantics`, `toggleSemantics`, and `child`
  /// widget.
  const SemanticsProvider({
    required this.showSemantics,
    required this.toggleSemantics,
    required super.child,
    super.key,
  });

  /// Whether the Semantics Debugger is enabled (`true`) or disabled (`false`).
  final bool showSemantics;

  /// Function to toggle the Semantics Debugger state.
  final VoidCallback toggleSemantics;

  /// Retrieves the nearest `SemanticsProvider` instance in the widget tree.
  static SemanticsProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SemanticsProvider>();
  }

  /// Determines whether to notify dependent widgets when this widget updates.
  /// This forces widgets that depend on `showSemantics` to rebuild.
  @override
  bool updateShouldNotify(SemanticsProvider oldWidget) {
    return showSemantics != oldWidget.showSemantics;
  }
}
