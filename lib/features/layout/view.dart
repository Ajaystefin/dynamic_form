import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/layout/widgets/side_menu.dart";
import "package:wcas_frontend/features/layout/widgets/top_menu.dart";

/// Main application layout widget that wraps pages with top menu and side menu.
class Layout extends StatelessWidget {
  /// Creates a [Layout].
  const Layout({
    required this.child,
    super.key,
    this.backgroundColor,
    this.hideSideMenu = false,
  });

  /// Page content displayed inside the layout.
  final Widget child;

  /// Optional background color for the scaffold.
  final Color? backgroundColor;

  /// Whether the side menu should be hidden.
  final bool hideSideMenu;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LayoutViewModel>(
      create: (context) => LayoutViewModel()
        ..init(
          context,
          hideSideMenu: hideSideMenu,
        ),
      child: Builder(
        builder: (context) {
          final LayoutViewModel state = context.watch<LayoutViewModel>();
          return Scaffold(
            key: state.scaffoldKey,
            backgroundColor: backgroundColor,
            //  ?? AppColors.scaffoldBorder,
            drawer: const SideMenu(),
            body: Row(
              children: [
                if (_shouldShowSideMenu(context)) const SideMenu(),
                Expanded(
                  child: Column(
                    children: [
                      const TopMenuSection(),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _shouldShowSideMenu(BuildContext context) {
    if (!context.isDesktop || hideSideMenu) {
      return false;
    }

    final routeName = router.state.name;

    return routeName != Routes.editContract &&
        routeName != Routes.editViewProject &&
        routeName != Routes.createProject &&
        routeName != Routes.closedRequest &&
        routeName != Routes.searchProject &&
        routeName != Routes.home &&
        routeName != Routes.linkContract;
  }
}
