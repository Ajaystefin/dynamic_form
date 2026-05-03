import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
// import 'package:flutter_html/flutter_html.dart';
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/safe_cubit.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/auth/select_role/model.dart";
import "package:wcas_frontend/features/layout/state.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";

Map<String, MenuMode> sideMenuVisibility = {};

class LayoutViewModel extends SafeCubit<LayoutState> {
  LayoutViewModel()
      : super(LayoutState(currentRoute: "/", hideSideMenu: false));
  final ScrollController scrollController = ScrollController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  MenuMode menuMode = MenuMode.hidden;

  bool get shouldShowDashboardButton =>
      AuthRepository.hasRight(RightConstants.dashboard);

  void init(context, bool hideSideMenu) {
    GoRouter.of(context).location;
    emit(
      state.copyWith(
        currentRoute: GoRouter.of(context).location,
        hideSideMenu: hideSideMenu,
      ),
    );
    // createPageAccessibility();
  }

  /// Handles route changes within the application, ensuring the correct menu
  /// visibility and navigation.
  ///
  /// This method updates the menu mode and determines the appropriate route to
  /// navigate to.
  /// If `rightConstant` is provided and the corresponding menu is hidden (based
  /// on API data),
  /// it searches for the next available (non-hidden) menu item starting from
  /// `rightConstant`.
  /// Once found, it updates the route and enables the corresponding menu item.
  // void goToNextRoute({Object? extra}) {
  //   String nextRoute = findNextRoute(router.state.fullPath ?? "");
  //   router.go(nextRoute, extra: extra);
  // }

  void goToNextRoute({Object? extra}) {
    unawaited(
      Globals.onAutoSave?.call(),
    ); // fire-and-forget: save draft before navigating
    String nextRoute = findNextRoute(router.state.fullPath ?? "");
    if (nextRoute == Routes.queriesAndResponses &&
        !Globals.isQueriesTabVisible()) {
      nextRoute = findNextRoute(nextRoute);
    }
    if (nextRoute == Routes.createSecurity) {
      //Subroute, just here to navigate to covenants after create security
      nextRoute = findNextRoute(nextRoute);
    }

    router.go(nextRoute, extra: extra);
  }

  final Map<String, List<int?>> routeRoleMap = {
    Routes.creditAssessmentFI: [
      ServerConstants.userRoleId[UserRole.creditAnalyst],
      ServerConstants.userRoleId[UserRole.segmentHeadCreditLevelD],
      ServerConstants.userRoleId[UserRole.segmentHeadLevelC],
    ],
    Routes.countrySummary: [
      ServerConstants.userRoleId[UserRole.relationshipOfficer],
      ServerConstants.userRoleId[UserRole.relationshipManager],
      ServerConstants.userRoleId[UserRole.businessUnitHead],
      ServerConstants.userRoleId[UserRole.relationshipManagerBussiness],
      ServerConstants.userRoleId[UserRole.segmentHeadBusiness],
      ServerConstants.userRoleId[UserRole.creditAnalyst],
      ServerConstants.userRoleId[UserRole.creditCordinator],
      ServerConstants.userRoleId[UserRole.teamLeaderBusiness],
    ],
    Routes.creditAssessment: [
      ServerConstants.userRoleId[UserRole.creditAnalyst],
      ServerConstants.userRoleId[UserRole.segmentHeadCreditLevelD],
      ServerConstants.userRoleId[UserRole.segmentHeadLevelC],
    ],
    Routes.groupSummary: [
      ServerConstants.userRoleId[UserRole.relationshipOfficer],
      ServerConstants.userRoleId[UserRole.relationshipManager],
      ServerConstants.userRoleId[UserRole.businessUnitHead],
      ServerConstants.userRoleId[UserRole.relationshipManagerBussiness],
      ServerConstants.userRoleId[UserRole.segmentHeadBusiness],
      ServerConstants.userRoleId[UserRole.creditAnalyst],
      ServerConstants.userRoleId[UserRole.creditCordinator],
      ServerConstants.userRoleId[UserRole.teamLeaderBusiness],
    ],
    Routes.managementComments: [
      ServerConstants.userRoleId[UserRole.creditAnalyst],
      ServerConstants.userRoleId[UserRole.segmentHeadCreditLevelD],
      ServerConstants.userRoleId[UserRole.segmentHeadLevelC],
      ServerConstants.userRoleId[UserRole.teamLeaderCreditLevelD1],
      ServerConstants.userRoleId[UserRole.segmentHeadLevelB],
      ServerConstants.userRoleId[UserRole.segmentHeadLevelB1],
      ServerConstants.userRoleId[UserRole.creditCommitteeProxy],
      ServerConstants.userRoleId[UserRole.creditCommitteeProxyApprover],
      ServerConstants.userRoleId[UserRole.boardDirectorProxy],
      ServerConstants.userRoleId[UserRole.boardDirectorProxyApproval],
    ],
    Routes.proposedFacilities: [
      ServerConstants.userRoleId[UserRole.relationshipOfficer],
      ServerConstants.userRoleId[UserRole.relationshipManager],
      ServerConstants.userRoleId[UserRole.businessUnitHead],
      ServerConstants.userRoleId[UserRole.relationshipManagerBussiness],
      ServerConstants.userRoleId[UserRole.segmentHeadBusiness],
      ServerConstants.userRoleId[UserRole.creditAnalyst],
      ServerConstants.userRoleId[UserRole.creditCordinator],
      ServerConstants.userRoleId[UserRole.teamLeaderBusiness],
      ServerConstants.userRoleId[UserRole.teamLeaderCreditLevelD1],
      ServerConstants.userRoleId[UserRole.segmentHeadLevelB],
      ServerConstants.userRoleId[UserRole.segmentHeadLevelB1],
      ServerConstants.userRoleId[UserRole.creditCommitteeProxy],
      ServerConstants.userRoleId[UserRole.creditCommitteeProxyApprover],
      ServerConstants.userRoleId[UserRole.boardDirectorProxy],
      ServerConstants.userRoleId[UserRole.boardDirectorProxyApproval],
    ],
  };

  final List<String> routes = [
    Routes.creditAssessment,
    Routes.groupSummary,
    Routes.managementComments,
    Routes.proposedFacilities,
    Routes.countrySummary,
    Routes.creditAssessmentFI,
    Routes.managementComments,
    Routes.proposedFacilities,
    Routes.countrySummary,
  ];

  void goToNextRouteAccess(BuildContext context, {Object? extra}) {
    unawaited(Globals.onAutoSave?.call());
    String nextRoute = router.state.fullPath ?? "";
    if (nextRoute == Routes.queriesAndResponses &&
        !Globals.isQueriesTabVisible()) {
      nextRoute = findNextRoute(nextRoute);
    }

    debugPrint("current Route : $nextRoute");

    final currentIndex = routes.indexOf(nextRoute);
    for (int i = currentIndex + 1; i < routes.length; i++) {
      final route = routes[i];
      if (route == Routes.groupSummary && !Globals.checkGroupAccess()) {
        debugPrint("groupSummary route :");
        continue;
      }
      debugPrint("next Route : $route");
      final allowedRoles = routeRoleMap[route];
      if (allowedRoles != null &&
          allowedRoles.contains(Globals.user?.currentRole?.roleId)) {
        debugPrint("final Route : ${route.toString()}");
        router.go(route, extra: extra);
        return;
      }
    }
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
    final String updatedCurrentRoute = currentRoute.replaceFirst("/", "");
    bool isCurrentRouteFound = false;
    String nextRoute = "";
    for (final MapEntry<String, MenuMode> entry
        in Globals.user?.currentRole?.routesAccessibility?.entries ?? {}) {
      if (isCurrentRouteFound && entry.value != MenuMode.hidden) {
        return "/${entry.key}";
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

  bool isCurrentRouteCCSYS() {
    switch (state.currentRoute) {
      case Routes.ccsysCustomerInformation ||
            Routes.ccsysCustomerInformation ||
            Routes.ccsysRequestInformation ||
            Routes.ccsysTerminateWithdraw ||
            Routes.ccsysApproval:
        return true;
      default:
        return false;
    }
  }

  String getRevenueCrossSellRoute(LayoutViewModel viewModel) {
    final route = viewModel.state.currentRoute;
    debugPrint(route);

    if (route == Routes.relationshipUtilization) {
      return Routes.relationshipUtilization;
    } else if (route == Routes.relationshipProfitabilitySummary) {
      return Routes.relationshipProfitabilitySummary;
    } else if (route == Routes.relationshipProfitabilityDetailed) {
      return Routes.relationshipProfitabilityDetailed;
    } else if (route == Routes.incomeSummary) {
      return Routes.incomeSummary;
    } else if (route == Routes.strategiesAndComments) {
      return Routes.strategiesAndComments;
    } else {
      return Routes.relationshipUtilization;
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
    } else if (route == Routes.previousCreditApproval) {
      return Routes.previousCreditApproval;
    } else if (route == Routes.recommendationCurrentApproval) {
      return Routes.recommendationCurrentApproval;
    } else if (route == Routes.comments) {
      return Routes.comments;
    } else {
      return Routes.proposedFacilities;
    }
  }

  Future<bool> showConfirmDialog(BuildContext context, Role role) async {
    const bool returnValue = false;
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: "layout.topmenu.confirmRoleChangeContentEnd".tr()),
          ],
        ),
      ),
      width: context.isDesktop ? 300.w : null,
      actions: [
        CustomButton(
          label: "layout.topmenu.cancelText".tr(),
          onPressed: () => onCancelRoleChange(context, returnValue),
        ),
        const Gap(
          direction: Axis.horizontal,
        ),
        CustomButton(
          label: "layout.topmenu.confirmText".tr(),
          onPressed: () => onConfirmRoleChange(context, role, returnValue),
        ),
      ],
    );
    return returnValue;
  }

  Future<bool> showWarningDialog(
    BuildContext context,
    List<String> description,
  ) async {
    const bool returnValue = false;
    await DialogHelper.showCustomDialog(
      context: context,
      title: "layout.topmenu.error".tr(),
      content: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              "layout.topmenu.incompletePendingActivity".tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Gap(),
          ListView.builder(
            shrinkWrap: true,
            itemCount: description.length,
            itemBuilder: (context, index) {
              return (description[index].trim().isNotEmpty)
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(description[index]),
                    )
                  : const SizedBox();
            },
          ),
          const Gap(),
          Text("layout.topmenu.noteForIncompletePendingActivity".tr()),
        ],
      ),
      width: context.isDesktop ? 500.w : null,
      actions: [
        CustomButton(
          label: "layout.topmenu.ok".tr(),
          onPressed: () => onCancelRoleChange(context, returnValue),
        ),
      ],
    );
    return returnValue;
  }

  Future<bool> showConfirmationDialog(
    BuildContext context,
    String description,
  ) async {
    const bool returnValue = false;
    await DialogHelper.showCustomDialog(
      context: context,
      title: "layout.topmenu.comfirmation".tr(),
      content: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(description),
          ),
        ],
      ),
      width: context.isDesktop ? 400.w : null,
      actions: [
        CustomButton(
          label: "layout.topmenu.ok".tr(),
          onPressed: () async {
            Navigator.pop(context);
            router.go(Routes.loadingPage);
            await Future.delayed(const Duration(milliseconds: 100), () {
              router.go(Routes.home); // Navigate back to home
            });
          },
        ),
      ],
    );
    return returnValue;
  }

  Future<bool> showCommentDialog(
    BuildContext context,
    String description,
  ) async {
    const bool returnValue = false;
    final UnifiedEditorController controller = UnifiedEditorController();
    await DialogHelper.showCustomDialog(
      barrierDismissible: false,
      context: context,
      title: "layout.topmenu.comment".tr(),
      content: SizedBox(
        // height: context.isDesktop ? 200.w : 400.w,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                // child: Html(data: description))
                child: UnifiedTextEditor(
                  disable: true,
                  semanticLabel: "approval.comments.tabTitle".tr(),
                  characterLimit: 5000,
                  controller: controller,
                  initialText: description,
                  editorId: "approval.comments",
                ),
              ),
            ],
          ),
        ),
      ),
      width: context.isDesktop ? 500.w : null,
      actions: [
        CustomButton(
          label: "layout.topmenu.ok".tr(),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
      ],
    );
    return returnValue;
  }

  Future<bool> showCommentCorporateDialog(
    BuildContext context,
    String description,
  ) async {
    const bool returnValue = false;
    await DialogHelper.showCustomDialog(
      barrierDismissible: false,
      context: context,
      title: "layout.topmenu.comment".tr(),
      content: SizedBox(
        height: context.isDesktop ? 100.w : 400.w,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: CustomTextArea(
                  maxLines: 8,
                  minLines: 8,
                  readOnly: true,
                  initialValue: description,
                  semanticLabel: "approval.comments.tabTitle".tr(),
                  maxLength: 5000,
                ),
              ),
            ],
          ),
        ),
      ),
      width: context.isDesktop ? 500.w : null,
      actions: [
        CustomButton(
          label: "layout.topmenu.ok".tr(),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
      ],
    );
    return returnValue;
  }

  Future<void> showLogoutDialog(BuildContext context) async {
    return DialogHelper.showCustomDialog(
      context: context,
      title: "auth.logout.title".tr(),
      width: Scale.scaleHorizontally(350),
      content: Row(
        spacing: 6,
        children: [
          const Icon(
            Icons.warning_amber_outlined,
            color: AppColors.primary,
          ),
          Text(
            "auth.logout.message".tr(),
          ),
        ],
      ),
      actions: [
        CustomButton(
          label: "auth.logout.logout".tr(),
          onPressed: onLogoutConfirm,
        ),
        const Gap(
          direction: Axis.horizontal,
        ),
        CustomButton(
          label: "auth.logout.cancel".tr(),
          onPressed: onLogoutCancel,
        ),
      ],
    );
  }

  @visibleForTesting
  Future<void> onCancelRoleChange(
    BuildContext context,
    bool returnValue,
  ) async {
    returnValue = false;
    Navigator.pop(context);
  }

  @visibleForTesting
  Future<void> onConfirmRoleChange(
    BuildContext context,
    Role role,
    bool returnValue,
  ) async {
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
      //Autosave function - This is to ensure that any unsaved changes are saved
      //as draft before leaving the current page.
      unawaited(Globals.onAutoSave?.call());
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

  // @override
  // Future<void> close() {
  //   Globals.request = null;
  //   Globals.applicationDetails = null;

  //   return super.close();
  // }
}
