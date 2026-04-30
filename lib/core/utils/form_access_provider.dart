import "package:flutter/material.dart";

/// An [InheritedWidget] that broadcasts a read-only / disabled form state
/// down the widget tree.
///
/// This replaces the use of [IgnorePointer] inside [BoxLayout], which was
/// blocking scroll events on tables and rich-text editors in addition to
/// blocking edits.  Widgets that need to respect the access state
/// (e.g. [CustomTextField], [CustomDropdown]) call [FormAccessProvider.of]
/// inside their [build] method and combine the result with their own local
/// flag.
class FormAccessProvider extends InheritedWidget {
  const FormAccessProvider({
    required this.disabled,
    required super.child,
    super.key,
  });

  /// Whether the form is in a disabled / read-only state.
  final bool disabled;

  /// Returns `true` when the nearest ancestor [FormAccessProvider] has
  /// [disabled] set to `true`.  Returns `false` if no provider is found in
  /// the tree (i.e. the widget is not inside a [BoxLayout]).
  static bool of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<FormAccessProvider>()
            ?.disabled ??
        false;
  }

  @override
  bool updateShouldNotify(FormAccessProvider oldWidget) {
    // Only force dependent widgets to rebuild when the disabled flag changes.
    return disabled != oldWidget.disabled;
  }
}
