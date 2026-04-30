import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/layout/widgets/side_menu.dart";
import "package:wcas_frontend/features/layout/widgets/top_menu.dart";

class Layout extends StatelessWidget {
  const Layout({
    required this.child,
    super.key,
    this.backgroundColor,
    this.hideSideMenu = false,
  });
  final Widget child;
  final Color? backgroundColor;
  final bool hideSideMenu;
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LayoutViewModel>(
      create: (context) => LayoutViewModel()
        ..init(
          context,
          hideSideMenu,
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
                if (context.isDesktop &&
                    (router.state.name != Routes.editContract) &&
                    (router.state.name != Routes.editViewProject) &&
                    (router.state.name != Routes.createProject) &&
                    (router.state.name != Routes.closedRequest) &&
                    (router.state.name != Routes.searchProject) &&
                    (router.state.name != Routes.home) &&
                    (router.state.name != Routes.linkContract) &&
                    !hideSideMenu)
                  const SideMenu(),
                Expanded(
                  child: Column(
                    children: [
                      const TopMenuSection(),
                      Expanded(
                        child: child,
                      ),
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
}
