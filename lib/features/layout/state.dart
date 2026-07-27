import "package:flutter/foundation.dart";

/// Represents the layout state of the application.
///
/// Tracks the current route and whether the side menu should be hidden.
@immutable
class LayoutState {
  /// Creates an instance of [LayoutState].
  const LayoutState({
    required this.currentRoute,
    required this.hideSideMenu,
  });

  /// The current route of the application.
  final String currentRoute;

  /// Whether the side menu should be hidden.
  final bool hideSideMenu;

  /// Creates a copy of this state with updated values.
  ///
  /// Only provided values will be replaced,
  /// others will retain existing values.
  LayoutState copyWith({
    String? currentRoute,
    bool? hideSideMenu,
  }) {
    return LayoutState(
      currentRoute: currentRoute ?? this.currentRoute,
      hideSideMenu: hideSideMenu ?? this.hideSideMenu,
    );
  }

  @override
  String toString() {
    return "LayoutState("
        "currentRoute: $currentRoute, "
        "hideSideMenu: $hideSideMenu"
        ")";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LayoutState &&
          currentRoute == other.currentRoute &&
          hideSideMenu == other.hideSideMenu;

  @override
  int get hashCode => Object.hash(currentRoute, hideSideMenu);
}
