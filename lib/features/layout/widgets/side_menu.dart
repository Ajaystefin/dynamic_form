import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/icon.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";

class SideMenu extends StatefulWidget {
  const SideMenu({
    super.key,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

double _offsetCache = 0;
late ScrollController _controller;

class _SideMenuState extends State<SideMenu> {
  @override
  void initState() {
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.jumpTo(_offsetCache);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final LayoutViewModel viewModel = context.watch<LayoutViewModel>();
    return ExcludeFocus(
      child: ExcludeSemantics(
        child: Drawer(
          backgroundColor: AppColors.darkGreen,
          shape: const BeveledRectangleBorder(),
          child: ListView(
            key: GlobalKey(),
            controller: _controller,
            children: [
              InkWell(
                onTap: () {
                  router.go(Routes.home);
                },
                child: SizedBox(
                  child: Image.asset(
                    AppAssets.logoDark,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ListTile(
                  dense: true,
                  title: Row(
                    children: [
                      const CustomIcon(
                        icon: FontAwesomeIcons.folderOpen,
                        size: 18,
                        iconColor: AppColors.white,
                      ),
                      const Gap(direction: Axis.horizontal),
                      Text(
                        Globals.user?.currentRole?.userRole == UserRole.icsAdmin
                            ? "layout.sidemenu.settings".tr()
                            : viewModel.isCurrentRouteCCSYS()
                                ? "layout.sidemenu.ccsysCustomerDetails".tr()
                                : "layout.sidemenu.creditApplicationInput".tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (context.isMobile) ...[
                if (AuthRepository.hasRight(RightConstants.roleRightMapping))
                  DrawerListTile(
                    title: "layout.topmenu.dashboardButton".tr(),
                    route: Routes.home,
                  ),
                DrawerListTile(
                  title: "layout.topmenu.closedRequest".tr(),
                  route: Routes.home,
                ),
              ],
              if (viewModel.isCurrentRouteCCSYS()) ...[
                // if (AuthRepository.hasRight(
                //     RightConstants.ccsysRequestInformation))
                DrawerExpansionTile(
                  title: "layout.sidemenu.ccsysRequestInformation".tr(),
                  children: [
                    DrawerListTile(
                      title: "layout.sidemenu.ccsysRequestInformation".tr(),
                      route: Routes.ccsysRequestInformation,
                    ),
                    if (Utils.checkRoles([
                      UserRole.relationshipManager,
                      UserRole.relationshipOfficer,
                    ]))
                      DrawerListTile(
                        title: "layout.sidemenu.terminateWithdrawal".tr(),
                        route: Routes
                            .ccsysTerminateWithdraw, //TODO: update the route
                      ),
                  ],
                ),
                // if (AuthRepository.hasRight(
                //     RightConstants.ccsysCustomerInformation))
                DrawerListTile(
                  title: "layout.sidemenu.ccsysCustomerInformation".tr(),
                  route: Routes.ccsysCustomerInformation,
                ),
                // if (AuthRepository.hasRight(
                //     RightConstants.ccsysRecommendationApproval))
                DrawerListTile(
                  title: "layout.sidemenu.ccsysRecommendationApproval".tr(),
                  route: Routes.ccsysApproval,
                ),
              ] else ...[
                if (AuthRepository.hasRight(
                  RightConstants.referenceDataManagement,
                ))
                  DrawerListTile(
                    title: "layout.sidemenu.referenceDataManagement".tr(),
                    route: Routes.manageReference,
                  ),
                if (AuthRepository.hasRight(RightConstants.roleRightMapping))
                  DrawerListTile(
                    title: "layout.sidemenu.roleRightMapping".tr(),
                    route: Routes.adminRoleRight,
                  ),
                if (AuthRepository.hasRight(RightConstants.fileAccess))
                  DrawerListTile(
                    title: "layout.sidemenu.fileAccess".tr(),
                    route: Routes.fileAccess,
                  ),
                if (AuthRepository.hasRight(
                  RightConstants.referenceDataManagement,
                ))
                  // RightConstants.workflowConfiguration)) //TODO: Will be implemented once the API is received. - i enable to reference data management.
                  DrawerListTile(
                    title: "layout.sidemenu.workflowConfiguration".tr(),
                    route: Routes.workflowConfiguration,
                  ),
                if (AuthRepository.hasRight(RightConstants.usersList))
                  DrawerListTile(
                    title: "layout.sidemenu.userList".tr(),
                    route: Routes.userList,
                  ),
                DrawerExpansionTile(
                  title: "layout.sidemenu.borrowerSegregation".tr(),
                  children: [
                    if (AuthRepository.hasRight(RightConstants.groupBorrowers))
                      DrawerListTile(
                        title: "layout.sidemenu.groupBorrowers".tr(),
                        route: Routes.groupBorrowers,
                      ),
                    if (AuthRepository.hasRight(
                      RightConstants.applicationBorrowers,
                    ))
                      DrawerListTile(
                        title: "layout.sidemenu.applicationBorrowers".tr(),
                        route: Routes.applicationBorrowers,
                      ),
                  ],
                ),

                DrawerExpansionTile(
                  title: "layout.sidemenu.request".tr(),
                  children: [
                    if (AuthRepository.hasRight(
                      RightConstants.requestInformation,
                    ))
                      DrawerListTile(
                        title: "layout.sidemenu.informationView".tr(),
                        route: Routes.requestInformation,
                      ),
                    if (AuthRepository.hasRight(RightConstants.presentRequest))
                      DrawerListTile(
                        title: "layout.sidemenu.presentRequest".tr(),
                        route: Routes.presentRequest,
                      ),
                    if (AuthRepository.hasRight(
                      RightConstants.securityPerfection,
                    ))
                      DrawerListTile(
                        title: "layout.sidemenu.securityPerfection".tr(),
                        route: Routes.securityPerfection,
                      ),
                    if (AuthRepository.hasRight(
                      RightConstants.terminateWithdrawal,
                    ))
                      DrawerListTile(
                        title: "layout.sidemenu.terminateWithdrawal".tr(),
                        route: Routes.terminateWithdraw,
                      ),
                  ],
                ),
                DrawerExpansionTile(
                  title: "layout.sidemenu.customerInformation".tr(),
                  children: [
                    if (AuthRepository.hasRight(
                      RightConstants.customerInformation,
                    ))
                      DrawerListTile(
                        title: "layout.sidemenu.customerInformation".tr(),
                        route: Routes.customerInformation,
                      ),
                    if (AuthRepository.hasRight(RightConstants.sicCodeReview))
                      DrawerListTile(
                        title: "layout.sidemenu.sicCodeReview".tr(),
                        route: Routes.sicCodeReview,
                      ),
                  ],
                ),

                if (AuthRepository.hasRight(RightConstants.customerRiskRating))
                  DrawerListTile(
                    title: "layout.sidemenu.customerRiskRating".tr(),
                    route: Routes.riskRating,
                  ),

                if (AuthRepository.hasRight(RightConstants.facilitySummary))
                  DrawerListTile(
                    title: "layout.sidemenu.facility".tr(),
                    route: Routes.facilitySummaryView,
                  ),
                DrawerExpansionTile(
                  title: "layout.sidemenu.securityTerms".tr(),
                  children: [
                    if (AuthRepository.hasRight(RightConstants.securitySummary))
                      DrawerListTile(
                        title: "layout.sidemenu.security".tr(),
                        route: Routes.securitySummaryView,
                      ),
                    if (AuthRepository.hasRight(
                      RightConstants.covenantsSummary,
                    ))
                      DrawerListTile(
                        title: "layout.sidemenu.covenants".tr(),
                        route: Routes.covenantsSummary,
                      ),
                    if (AuthRepository.hasRight(
                      RightConstants.conditionsSummary,
                    ))
                      DrawerListTile(
                        title: "layout.sidemenu.conditions".tr(),
                        route: Routes.conditionsSummary,
                      ),
                  ],
                ),
                if (AuthRepository.hasRight(
                  RightConstants.facilitySecurityLinkage,
                ))
                  DrawerListTile(
                    title: "layout.sidemenu.facilitySecurityLinkage".tr(),
                    route: Routes.facilitySecurityLinkage,
                  ),

                // if (AuthRepository.hasRight(RightConstants.groupInformation))
                DrawerExpansionTile(
                  title: "layout.sidemenu.groupInformation".tr(),
                  children: [
                    if (AuthRepository.hasRight(
                      RightConstants.facilitiesWithCbd,
                    ))
                      DrawerListTile(
                        title: "layout.sidemenu.facilitiesWithCBD".tr(),
                        route: Routes.facilitiesWithCbd,
                      ),
                    if (AuthRepository.hasRight(
                      RightConstants.facilitiesWithOtherBanks,
                    ))
                      DrawerListTile(
                        title: "layout.sidemenu.facilitiesWithOtherBanks".tr(),
                        route: Routes.facilitiesWithOtherBanks,
                      ),
                  ],
                ),
                DrawerExpansionTile(
                  title: "layout.sidemenu.profitabilityAccountConduct".tr(),
                  children: [
                    if (AuthRepository.hasRight(
                      RightConstants.businessVolumeAccountStats,
                    ))
                      DrawerListTile(
                        title:
                            "layout.sidemenu.businessVolumeAccountStats".tr(),
                        route:
                            viewModel.state.currentRoute == Routes.accountStats
                                ? Routes.accountStats
                                : Routes.businessVolume,
                      ),
                    if (AuthRepository.hasRight(RightConstants.accountConduct))
                      DrawerListTile(
                        title: "layout.sidemenu.accountConduct".tr(),
                        route: Routes.accountConduct,
                      ),
                    if (AuthRepository.hasRight(
                      RightConstants.revenueCrossSell,
                    ))
                      DrawerListTile(
                        title: "layout.sidemenu.revenueCrossSell".tr(),
                        route: viewModel.getRevenueCrossSellRoute(viewModel),
                      ),
                    if (AuthRepository.hasRight(RightConstants.shareOfWallet))
                      DrawerListTile(
                        title: "layout.sidemenu.shareOfWallet".tr(),
                        route: Routes.shareOfWalletView,
                      ),
                  ],
                ),
                if (AuthRepository.hasRight(RightConstants.remarksCommentary))
                  DrawerListTile(
                    title: "layout.sidemenu.remarks".tr(),
                    route: Routes.remarksCommonTabs,
                  ),
                DrawerExpansionTile(
                  title: "layout.sidemenu.certifications".tr(),
                  children: [
                    if (AuthRepository.hasRight(RightConstants.rmCertification))
                      DrawerListTile(
                        title: "layout.sidemenu.rmCertification".tr(),
                        route: Routes.rmCertification,
                      ),
                    if (AuthRepository.hasRight(
                      RightConstants.esgCertification,
                    ))
                      DrawerListTile(
                        title: "layout.sidemenu.esgCertification".tr(),
                        route: Routes.esgCertification,
                      ),
                    if (AuthRepository.hasRight(
                      RightConstants.documentationCertification,
                    ))
                      DrawerListTile(
                        title:
                            "layout.sidemenu.documentationCertification".tr(),
                        route: Routes.documentationCertification,
                      ),
                    if (AuthRepository.hasRight(
                      RightConstants.creditControlTeamCertification,
                    ))
                      DrawerListTile(
                        title: "layout.sidemenu.limitInputTitle".tr(),
                        route: Routes.limitInputCertification,
                      ),
                  ],
                ),

                DrawerExpansionTile(
                  title: "layout.sidemenu.approval".tr(),
                  children: [
                    if (Globals.checkMasterAccessibilityForRoute(
                      Routes.countrySummary,
                    ))
                      DrawerListTile(
                        title: "layout.sidemenu.countrySummary".tr(),
                        route: Routes.countrySummary,
                      ),
                    if (Globals.checkMasterAccessibilityForRoute(
                      Routes.creditAssessmentFI,
                    ))
                      DrawerListTile(
                        title: "layout.sidemenu.creditAssessment".tr(),
                        route: Routes.creditAssessmentFI,
                      ),
                    if (Globals.checkMasterAccessibilityForRoute(
                      Routes.creditAssessment,
                    ))
                      DrawerListTile(
                        title: "layout.sidemenu.creditAssessment".tr(),
                        route: Routes.creditAssessment,
                      ),
                    if (Globals.checkMasterAccessibilityForRoute(
                      Routes.groupSummary,
                    ))
                      DrawerListTile(
                        title: "layout.sidemenu.groupSummary".tr(),
                        route: Routes.groupSummary,
                      ),
                    if (Globals.checkMasterAccessibilityForRoute(
                      Routes.managementComments,
                    ))
                      DrawerListTile(
                        title: "layout.sidemenu.managementComments".tr(),
                        route: Routes.managementComments,
                      ),
                    if (Globals.checkMasterAccessibilityForRoute(
                      Routes.proposedFacilities,
                    ))
                      DrawerListTile(
                        title: "layout.sidemenu.recommendationApproval".tr(),
                        route: viewModel.getApprovalRoute(viewModel),
                      ),
                    if (Globals.checkMasterAccessibilityForRoute(
                      Routes.requestForFOL,
                    ))
                      DrawerListTile(
                        title: "layout.sidemenu.requestForFOL".tr(),
                        route: Routes.requestForFOL,
                      ),
                    if (Globals.checkMasterAccessibilityForRoute(
                      Routes.requestForLimitRelease,
                    ))
                      DrawerListTile(
                        title: "layout.sidemenu.requestForLimitRelease".tr(),
                        route: Routes.requestForLimitRelease,
                      ),
                    if (Globals.checkMasterAccessibilityForRoute(
                      Routes.requestForClosure,
                    ))
                      DrawerListTile(
                        title: "layout.sidemenu.requestForClosure".tr(),
                        route: Routes.requestForClosure,
                      ),
                  ],
                ),
                if (AuthRepository.hasRight(RightConstants.fileAttachments))
                  DrawerListTile(
                    title: "layout.sidemenu.fileAttachment".tr(),
                    route: Routes.fileAttachment,
                  ),
                if (AuthRepository.hasRight(RightConstants.appendix))
                  DrawerListTile(
                    title: "layout.sidemenu.appendix".tr(),
                    route: Routes.appendix,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  // final bool isEnabled;

  const DrawerListTile({
    required this.title,
    required this.route,
    super.key,
    // this.isEnabled = true,
  });
  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    final LayoutViewModel viewModel = context.watch<LayoutViewModel>();
    final bool isActive = viewModel.state.currentRoute == route;
    MenuMode menuMode = MenuMode.enabled;
    if (Globals.request != null && (!Globals.request!.isRequestCreated)) {
      menuMode = MenuMode.disabled;
    }
    // menuMode = Globals.user?.currentRole?.routesAccessibility?[route];
    // sideMenuVisibility[route.replaceFirst('/', '')] ?? MenuMode.hidden;
    return Padding(
      key: ValueKey(route),
      padding: const EdgeInsets.only(left: 8, right: 16),
      child: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ListTile(
          onTap: menuMode != MenuMode.enabled
              ? null
              : () {
                  _offsetCache = _controller.offset;
                  //Autosave function - This is to ensure that any unsaved
                  //changes are saved as draft before leaving the current page.
                  unawaited(Globals.onAutoSave?.call());
                  router.go(route);
                },
          dense: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          minVerticalPadding: 4,
          selected: isActive,
          selectedTileColor: Theme.of(context).primaryColor,
          title: Text(
            title,
            style: TextStyle(
              color: menuMode == MenuMode.enabled
                  ? AppColors.white
                  : AppColors.white.withValues(alpha: 0.7),
            ),
          ),
          trailing: isActive
              ? const Icon(
                  Icons.circle,
                  size: 4,
                  color: AppColors.white,
                )
              : null,
        ),
      ),
    );
  }
}

class DrawerExpansionTile extends StatefulWidget {
  const DrawerExpansionTile({
    required this.title,
    required this.children,
    super.key,
  });
  final String title;
  final List<DrawerListTile> children;

  @override
  State<DrawerExpansionTile> createState() => _DrawerExpansionTileState();
}

class _DrawerExpansionTileState extends State<DrawerExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) {
      return const SizedBox();
    }
    final LayoutViewModel viewModel = context.watch<LayoutViewModel>();

    // Check if any child is selected from the ViewModel
    _isExpanded = widget.children
        .any((child) => child.route == viewModel.state.currentRoute);
    // Check if any child route is enabled
    // bool anyChildEnabled = widget.children.any((child) {

    //   // String routeKey = child.route.replaceFirst('/', '');
    //   // MenuMode menuMode = sideMenuVisibility[routeKey] ?? MenuMode.hidden;
    //   return true; // menuMode == MenuMode.enabled;
    // });
    bool anyChildEnabled = true;
    if (Globals.request != null && (!Globals.request!.isRequestCreated)) {
      anyChildEnabled = false;
    }

    // Set text color based on menuMode
    final Color textColor =
        anyChildEnabled ? AppColors.white : AppColors.white.withAlpha(180);
    logger.i(_isExpanded);
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ExpansionTile(
        title: Text(widget.title, style: TextStyle(color: textColor)),
        trailing: Icon(
          _isExpanded ? Icons.remove : Icons.add,
          color: AppColors.white,
        ),
        initiallyExpanded: _isExpanded,
        dense: true,
        shape: LinearBorder.none,
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        children: widget.children,
      ),
    );
  }
}
