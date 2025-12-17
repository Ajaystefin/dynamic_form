class LayoutState {
  String currentRoute;
  bool hideSideMenu;

  LayoutState({required this.currentRoute, required this.hideSideMenu});

  LayoutState copyWith({String? currentRoute, bool? hideSideMenu}) {
    return LayoutState(
        currentRoute: currentRoute ?? this.currentRoute,
        hideSideMenu: hideSideMenu ?? this.hideSideMenu);
  }
}
