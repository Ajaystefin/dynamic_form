class LayoutState {
  LayoutState({required this.currentRoute, required this.hideSideMenu});
  String currentRoute;
  bool hideSideMenu;

  LayoutState copyWith({String? currentRoute, bool? hideSideMenu}) {
    return LayoutState(
      currentRoute: currentRoute ?? this.currentRoute,
      hideSideMenu: hideSideMenu ?? this.hideSideMenu,
    );
  }
}
