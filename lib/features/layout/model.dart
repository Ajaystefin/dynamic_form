import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/auth/select_role/model.dart';
import 'package:wcas_frontend/features/layout/state.dart';
import 'package:wcas_frontend/models/login/role.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';

Map<String, MenuMode> sideMenuVisibility = {};

class LayoutViewModel extends Cubit<LayoutState> {
  LayoutViewModel()
      : super(LayoutState(currentRoute: '/', hideSideMenu: false));
  final ScrollController scrollController = ScrollController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  MenuMode menuMode = MenuMode.hidden;

  bool get shouldShowDashboardButton =>
      AuthRepository.hasRight(RightConstants.dashboard);

  void init(context, bool hideSideMenu) async {
    GoRouter.of(context).location;
    emit(state.copyWith(
        currentRoute: GoRouter.of(context).location,
        hideSideMenu: hideSideMenu));
    // createPageAccessibility();
  }

  /// Handles route changes within the application, ensuring the correct menu visibility and navigation.
  ///
  /// This method updates the menu mode and determines the appropriate route to navigate to.
  /// If `rightConstant` is provided and the corresponding menu is hidden (based on API data),
  /// it searches for the next available (non-hidden) menu item starting from `rightConstant`.
  /// Once found, it updates the route and enables the corresponding menu item.
  void goToNextRoute({Object? extra}) {
    String nextRoute = findNextRoute(router.state.fullPath ?? "");
    router.go(nextRoute, extra: extra);
  }

  void openSideMenu() {
    if (!scaffoldKey.currentState!.isDrawerOpen) {
      scaffoldKey.currentState!.openDrawer();
    }
  }

  /// Checks if the current route is [route].
  bool isCurrentRoute(BuildContext context, String route) {
    return GoRouter.of(context).state.name == route;
  }

  String findNextRoute(String currentRoute) {
    String updatedCurrentRoute = currentRoute.replaceFirst("/", "");
    bool isCurrentRouteFound = false;
    String nextRoute = "";
    for (MapEntry<String, MenuMode> entry
        in Globals.user?.currentRole?.routesAccessibility?.entries ?? {}) {
      if (isCurrentRouteFound && entry.value != MenuMode.hidden) {
        return '/${entry.key}';
      }
      if (entry.key == updatedCurrentRoute) {
        nextRoute = updatedCurrentRoute;
        isCurrentRouteFound = true;
      }
    }
    Globals.user?.currentRole?.routesAccessibility?[updatedCurrentRoute] =
        MenuMode.enabled;
    //Already in last route
    return "/$nextRoute";
  }

  bool isCurrentRouteCCSYS(){
    switch (state.currentRoute) {
      case Routes.ccsysCustomerInformation || Routes.ccsysCustomerInformation || Routes.ccsysRequestInformation || Routes.ccsysApproval:
        return true;
      default:
      return false;
    }
  }

  String getRevenueCrossSellRoute(LayoutViewModel viewModel) {
    final route = viewModel.state.currentRoute;

    if (route == Routes.relationshipUtilization) {
      return Routes.relationshipUtilization;
    } else if (route == Routes.relationshipProfitabilitySummary) {
      return Routes.relationshipProfitabilitySummary;
    } else if (route == Routes.relationshipProfitabilityDetailed) {
      return Routes.relationshipProfitabilityDetailed;
    } else if (route == Routes.incomeSummary) {
      return Routes.incomeSummary;
    } else {
      return Routes.strategiesAndComments;
    }
  }

  String getApprovalRoute(LayoutViewModel viewModel) {
    final route = viewModel.state.currentRoute;

    if (route == Routes.proposedFacilities) {
      return Routes.proposedFacilities;
    } else if (route == Routes.groupPosition) {
      return Routes.groupPosition;
    } else if (route == Routes.limitCaps) {
      return Routes.limitCaps;
    } else if (route == Routes.guarantorsExposure) {
      return Routes.guarantorsExposure;
    } else if (route == Routes.queriesAndResponses) {
      return Routes.queriesAndResponses;
    } else if (route == Routes.comments) {
      return Routes.comments;
    } else {
      return Routes.proposedFacilities;
    }
  }

  Future<bool> showConfirmDialog(BuildContext context, Role role) async {
    bool returnValue = false;
    await DialogHelper.showCustomDialog(
      context: context,
      title: "layout.topmenu.confirmRoleChange".tr(),
      content: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: "layout.topmenu.confirmRoleChangeContentStart".tr(),
          children: <TextSpan>[
            TextSpan(
                text: role.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: "layout.topmenu.confirmRoleChangeContentEnd".tr()),
          ],
        ),
      ),
      width: context.isDesktop ? 300.w : null,
      actions: [
        CustomButton(
            label: "layout.topmenu.cancelText".tr(),
            onPressed: () => onCancelRoleChange(context, returnValue)),
        const Gap(
          direction: Axis.horizontal,
        ),
        CustomButton(
            label: "layout.topmenu.confirmText".tr(),
            onPressed: () => onConfirmRoleChange(context, role, returnValue))
      ],
    );
    return returnValue;
  }

  Future<void> showLogoutDialog(BuildContext context) async {
    return await DialogHelper.showCustomDialog(
      context: context,
      title: 'auth.logout.title'.tr(),
      width: Scale.scaleHorizontally(350),
      content: Row(
        spacing: 6,
        children: [
          const Icon(
            Icons.warning_amber_outlined,
            color: AppColors.primary,
          ),
          Text(
            'auth.logout.message'.tr(),
          ),
        ],
      ),
      actions: [
        CustomButton(
          label: 'auth.logout.logout'.tr(),
          onPressed: () => onLogoutConfirm(),
        ),
        const Gap(
          direction: Axis.horizontal,
        ),
        CustomButton(
            label: 'auth.logout.cancel'.tr(),
            onPressed: () => onLogoutCancel()),
      ],
    );
  }

  @visibleForTesting
  Future<void> onCancelRoleChange(
      BuildContext context, bool returnValue) async {
    returnValue = false;
    Navigator.pop(context);
  }

  @visibleForTesting
  Future<void> onConfirmRoleChange(
      BuildContext context, Role role, bool returnValue) async {
    returnValue = true;
    await AuthRepository.instance.changeRole(role);
    //Closes the Dialogue
    if (context.mounted) {
      Navigator.pop(context);
    }
    if (router.state.name == Routes.home &&
        role.userRole != UserRole.icsAdmin &&
        role.userRole != UserRole.admin) {
      router.go(Routes.loadingPage);
      await Future.delayed(const Duration(milliseconds: 100), () {
        router.go(Routes.home); // Navigate back to home
      });
    } else {
      SelectRoleViewModel().routeAfterRoleChange(role.userRole);
    }
  }

  @visibleForTesting
  Future<void> onLogoutConfirm() async {
    await AuthRepository.instance.logout();
  }

  @visibleForTesting
  void onLogoutCancel() {
    router.pop();
  }
}
