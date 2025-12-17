import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wcas_frontend/core/components/loading_page.dart';
import 'package:wcas_frontend/core/components/not_found_view.dart';
import 'package:wcas_frontend/core/components/screen_index.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/session/cubit.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/admin/file_access/view.dart';
import 'package:wcas_frontend/features/admin/manage_reference/view.dart';
import 'package:wcas_frontend/features/admin/role_right_mapping/view.dart';
import 'package:wcas_frontend/features/admin/user_detail/view.dart';
import 'package:wcas_frontend/features/admin/user_list/view.dart';
// import 'package:wcas_frontend/features/auth/login/view.dart';
import 'package:wcas_frontend/features/auth/select_role/view.dart';
import 'package:wcas_frontend/features/dashboard/advanced_search/view.dart';
import 'package:wcas_frontend/features/dashboard/closed_requests/view.dart';
import 'package:wcas_frontend/features/dashboard/home/view.dart';
import 'package:wcas_frontend/features/request/approval/country_summary/view.dart';
import 'package:wcas_frontend/features/request/approval/group_summary/view.dart';
import 'package:wcas_frontend/features/request/approval/comments/view.dart';
import 'package:wcas_frontend/features/request/approval/credit_assessment/view.dart';
import 'package:wcas_frontend/features/request/approval/group_position/view.dart';
import 'package:wcas_frontend/features/request/approval/guarantors_exposure/view.dart';
import 'package:wcas_frontend/features/request/approval/limit_caps/view.dart';
import 'package:wcas_frontend/features/request/approval/management_comments/view.dart';
import 'package:wcas_frontend/features/request/approval/proposed_facilities/view.dart';
import 'package:wcas_frontend/features/request/approval/queries_and_responses/view.dart';
import 'package:wcas_frontend/features/request/approval/request_for_closure/view.dart';
import 'package:wcas_frontend/features/request/approval/request_for_fol/view.dart';
import 'package:wcas_frontend/features/request/approval/request_for_limit_release/view.dart';
import 'package:wcas_frontend/features/request/ccsys/approval/view.dart';
import 'package:wcas_frontend/features/request/ccsys/create_request/view.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/view.dart';
import 'package:wcas_frontend/features/request/ccsys/request_information/view.dart';
import 'package:wcas_frontend/features/request/certifications/esg_certification/view.dart';
import 'package:wcas_frontend/features/request/certifications/other_certifications/view.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/conditions_summary/view.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenants_summary/view.dart';
import 'package:wcas_frontend/features/request/customer_information/sic_code_review/view.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/view.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/view.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/view.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/view.dart';

import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/view.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/view.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facility_security_linkage/view.dart';
import 'package:wcas_frontend/features/request/facilities_securities/securities_summary/view.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/view.dart';
import 'package:wcas_frontend/features/request/group_information/facilities_with_cbd/view.dart';
import 'package:wcas_frontend/features/request/group_information/facilities_with_other_banks/view.dart';
import 'package:wcas_frontend/features/request/information/create_request/view.dart';
import 'package:wcas_frontend/features/request/information/application_borrowers/view.dart';

import 'package:wcas_frontend/features/request/customer_information/customer_info/view.dart';
import 'package:wcas_frontend/features/request/information/group_borrowers/view.dart';
import 'package:wcas_frontend/features/request/information/request_info/view.dart';
import 'package:wcas_frontend/features/request/information/present_request/view.dart';
import 'package:wcas_frontend/features/request/information/security_perfection/view.dart';
import 'package:wcas_frontend/features/request/information/termination/view.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/account_conduct/view.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/account_stats/view.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/business_volume/view.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/income_summary/view.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_detailed/view.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/view.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/view.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/share_of_wallet/view.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/strategies_and_comments/view.dart';
import 'package:wcas_frontend/features/request/projects/edit_contract/view.dart';
import 'package:wcas_frontend/features/request/projects/search_project/view.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/view.dart';
import 'package:wcas_frontend/features/request/remarks/common_tabs/view.dart';
import 'package:wcas_frontend/features/request/remarks/fee_structure/view.dart';
import 'package:wcas_frontend/features/request/projects/create_project/view.dart';
import 'package:wcas_frontend/features/request/remarks/financial_ratio_analysis/view.dart';
import 'package:wcas_frontend/features/request/remarks/guarantor_financials/view.dart';
import 'package:wcas_frontend/features/request/risk_rating/view.dart';
import 'package:wcas_frontend/models/login/user.dart';
import 'package:wcas_frontend/models/request/facility_security/security.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';

GoRouter router = GoRouter(
  initialLocation: '/${Routes.login}',
  observers: [GoRouterObserver()],
  navigatorKey: Globals.navigatorKey,
  redirect: (context, state) async {
    // optional: handle dynamic checks during navigation
    bool isLoggedIn = await AuthRepository.instance.isLoggedIn();
    if (!isLoggedIn) return Routes.login;

    // if (isLoggedIn &&
    //     Globals.user?.currentRole?.userRole == UserRole.icsAdmin) {
    //   return Routes.userList;
    // }

    //TODO: Don't Remove, BugNo: 309

    // if (isLoggedIn &&
    //     state.fullPath != Routes.login &&
    //     state.fullPath != Routes.selectRole &&
    //     !AuthRepository.hasRight(routeToRightsMap[state.fullPath])) {
    //   throw Exception('Router declined redirect');
    // }
    SessionCubit.instance.startSession();
    return null;
  },
  errorBuilder: ((context, state) => const NotFoundView()),
  routes: [
    GoRoute(
      name: Routes.login,
      path: '/${Routes.login}',
      builder: (context, state) => const CreateSecurityView(),
    ),
    GoRoute(
      name: Routes.requestInformation,
      path: '/${Routes.requestInformation}',
      builder: (context, state) => const RequestInfoView(),
    ),
    GoRoute(
      name: Routes.home,
      path: '/${Routes.home}',
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      name: Routes.home2,
      path: '/${Routes.home2}',
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      name: Routes.requestCreate,
      path: '/${Routes.requestCreate}',
      builder: (context, state) => const CreateRequestView(),
    ),
    GoRoute(
      name: Routes.loadingPage,
      path: '/${Routes.loadingPage}',
      builder: (context, state) => const LoadingPage(),
    ),

    GoRoute(
      name: Routes.adminRoleRight,
      path: '/${Routes.adminRoleRight}',
      builder: (context, state) => const RoleRightMappingView(),
    ),
    GoRoute(
      name: Routes.manageReference,
      path: '/${Routes.manageReference}',
      builder: (context, state) => const ManageReferenceView(),
    ),
    GoRoute(
      name: Routes.terminateWithdraw,
      path: '/${Routes.terminateWithdraw}',
      builder: (context, state) => const TerminationView(),
    ),
    // GoRoute(
    //   name: Routes.dashBoard,
    //   path: '/dashBoard',
    //   builder: (context, state) => const DashBoardView(),
    // ),
    GoRoute(
      name: Routes.userList,
      path: '/${Routes.userList}',
      builder: (context, state) => const UserListView(),
    ),
    GoRoute(
      name: Routes.adminUserDetails,
      path: '/${Routes.adminUserDetails}',
      builder: (context, state) {
        final user = state.extra as User?;
        return UserDetailView(userListItem: user);
      },
    ),
    GoRoute(
      name: Routes.advancedSearch,
      path: '/${Routes.advancedSearch}',
      builder: (context, state) => const AdvancedSearchView(),
    ),
    GoRoute(
      name: Routes.rmCertification,
      path: '/${Routes.rmCertification}',
      builder: (context, state) =>
          const OtherCertificationsView(type: CertificationType.rm),
    ),
    GoRoute(
      name: Routes.limitInputCertification,
      path: '/${Routes.limitInputCertification}',
      builder: (context, state) =>
          const OtherCertificationsView(type: CertificationType.limitInput),
    ),
    GoRoute(
      name: Routes.documentationCertification,
      path: '/${Routes.documentationCertification}',
      builder: (context, state) =>
          const OtherCertificationsView(type: CertificationType.documentation),
    ),
    GoRoute(
      name: Routes.customerInformation,
      path: '/${Routes.customerInformation}',
      builder: (context, state) => const CustomerInfoView(),
    ),
    GoRoute(
      name: Routes.securityPerfection,
      path: '/${Routes.securityPerfection}',
      builder: (context, state) => const SecurityPerfectionView(),
    ),
    GoRoute(
      name: Routes.presentRequest,
      path: '/${Routes.presentRequest}',
      builder: (context, state) => const PresentRequestView(),
    ),
    GoRoute(
      name: Routes.fileAccess,
      path: '/${Routes.fileAccess}',
      builder: (context, state) => const FileAccessView(),
    ),
    GoRoute(
      name: Routes.esgCertification,
      path: '/${Routes.esgCertification}',
      builder: (context, state) => const EsgCertificationView(),
    ),

    GoRoute(
      name: Routes.covenantsSummary,
      path: '/${Routes.covenantsSummary}',
      builder: (context, state) => const CovenantsSummaryView(),
    ),
    GoRoute(
      name: Routes.conditionsSummary,
      path: '/${Routes.conditionsSummary}',
      builder: (context, state) => const ConditionsSummaryView(),
    ),

    GoRoute(
        name: Routes.closedRequest,
        path: '/${Routes.closedRequest}',
        builder: (context, state) {
          ApplicationFilterType filterType =
              state.extra is ApplicationFilterType
                  ? (state.extra as ApplicationFilterType)
                  : ApplicationFilterType.closedRequest;
          return ClosedRequestsView(
            applicationType: filterType,
          );
        }),
    GoRoute(
      name: Routes.businessVolume,
      path: '/${Routes.businessVolume}',
      builder: (context, state) => const BusinessVolumeView(),
    ),
    GoRoute(
      name: Routes.accountStats,
      path: '/${Routes.accountStats}',
      builder: (context, state) => const AccountStatsView(),
    ),
    GoRoute(
      name: Routes.accountConduct,
      path: '/${Routes.accountConduct}',
      builder: (context, state) => const AccountConductView(),
    ),
    GoRoute(
      name: Routes.relationshipUtilization,
      path: '/${Routes.relationshipUtilization}',
      builder: (context, state) => const RelationshipUtilizationView(),
    ),
    GoRoute(
      name: Routes.relationshipProfitabilitySummary,
      path: '/${Routes.relationshipProfitabilitySummary}',
      builder: (context, state) => const RelationshipProfitabilitySummaryView(),
    ),
    GoRoute(
      name: Routes.relationshipProfitabilityDetailed,
      path: '/${Routes.relationshipProfitabilityDetailed}',
      builder: (context, state) =>
          const RelationshipProfitabilityDetailedView(),
    ),
    GoRoute(
      name: Routes.incomeSummary,
      path: '/${Routes.incomeSummary}',
      builder: (context, state) => const IncomeSummaryView(),
    ),
    GoRoute(
      name: Routes.strategiesAndComments,
      path: '/${Routes.strategiesAndComments}',
      builder: (context, state) => const StrategiesAndCommentsView(),
    ),
    GoRoute(
      name: Routes.shareOfWalletView,
      path: '/${Routes.shareOfWalletView}',
      builder: (context, state) => const ShareOfWalletView(),
    ),
    GoRoute(
      name: Routes.sicCodeReview,
      path: '/${Routes.sicCodeReview}',
      builder: (context, state) => const SicCodeReviewView(),
    ),
    GoRoute(
      name: Routes.riskRating,
      path: '/${Routes.riskRating}',
      builder: (context, state) => const RiskRatingView(),
    ),
    GoRoute(
      name: Routes.facilitySecurityLinkage,
      path: '/${Routes.facilitySecurityLinkage}',
      builder: (context, state) => const FacilitySecurityLinkageView(),
    ),
    GoRoute(
      name: Routes.facilitiesWithCbd,
      path: '/${Routes.facilitiesWithCbd}',
      builder: (context, state) => const FacilitiesWithCbdView(),
    ),
    GoRoute(
      name: Routes.facilitiesWithOtherBanks,
      path: '/${Routes.facilitiesWithOtherBanks}',
      builder: (context, state) => const FacilitiesWithOtherBanksView(),
    ),

    GoRoute(
      name: Routes.applicationBorrowers,
      path: '/${Routes.applicationBorrowers}',
      builder: (context, state) => const ApplicationBorrowersView(),
    ),

    GoRoute(
        name: Routes.createSecurity,
        path: '/${Routes.createSecurity}',
        builder: (context, state) {
          final security = state.extra as Security?;
          return CreateSecurityView(
            security: security,
          );
        }),

    GoRoute(
      name: Routes.facilitySummaryView,
      path: '/${Routes.facilitySummaryView}',
      builder: (context, state) => const FacilitiesSummaryView(),
    ),

    GoRoute(
      name: Routes.facilitySummaryFiView,
      path: '/${Routes.facilitySummaryFiView}',
      builder: (context, state) => const FacilitiesSummaryFiView(),
    ),
    GoRoute(
        name: Routes.securitySummaryView,
        path: '/${Routes.securitySummaryView}',
        builder: (context, state) => const SecuritiesSummaryView()),

    GoRoute(
      name: Routes.createFacility,
      path: '/${Routes.createFacility}',
      builder: (context, state) => const CreateFacilityView(),
    ),
    GoRoute(
      name: Routes.selectRole,
      path: '/${Routes.selectRole}',
      builder: (context, state) => const SelectRoleView(),
    ),
    GoRoute(
        name: Routes.remarksCommonTabs,
        path: '/${Routes.remarksCommonTabs}',
        builder: (context, state) {
          final tabtoGo = state.extra as RemarksTabs?;
          return CommonTabsView(tab: tabtoGo);
        }),
    GoRoute(
      name: Routes.financialRatiosAnalysis,
      path: '/${Routes.financialRatiosAnalysis}',
      builder: (context, state) => const FinancialRatioAnalysisView(),
    ),
    GoRoute(
      name: Routes.guarantorFinancials,
      path: '/${Routes.guarantorFinancials}',
      builder: (context, state) => const GuarantorFinancialView(),
    ),

    GoRoute(
      name: Routes.feeStructure,
      path: '/${Routes.feeStructure}',
      builder: (context, state) => const FeeStructureView(),
    ),
    GoRoute(
      name: Routes.fileAttachment,
      path: '/${Routes.fileAttachment}',
      builder: (context, state) => const FileAttachmentView(),
    ),
    GoRoute(
      name: Routes.groupBorrowers,
      path: '/${Routes.groupBorrowers}',
      builder: (context, state) => const GroupBorrowersView(),
    ),
    GoRoute(
      name: Routes.creditAssessment,
      path: '/${Routes.creditAssessment}',
      builder: (context, state) => const CreditAssessmentView(),
    ),
    GoRoute(
      name: Routes.managementComments,
      path: '/${Routes.managementComments}',
      builder: (context, state) => const ManagementCommentsView(),
    ),
    GoRoute(
      name: Routes.countrySummary,
      path: '/${Routes.countrySummary}',
      builder: (context, state) => const CountrySummaryView(),
    ),
    GoRoute(
      name: Routes.groupSummary,
      path: '/${Routes.groupSummary}',
      builder: (context, state) => const GroupSummaryView(),
    ),
    GoRoute(
      name: Routes.proposedFacilities,
      path: '/${Routes.proposedFacilities}',
      builder: (context, state) => const ProposedFacilitiesView(),
    ),
    GoRoute(
      name: Routes.groupPosition,
      path: '/${Routes.groupPosition}',
      builder: (context, state) => const GroupPositionView(),
    ),
    GoRoute(
      name: Routes.limitCaps,
      path: '/${Routes.limitCaps}',
      builder: (context, state) => const LimitCapsView(),
    ),
    GoRoute(
      name: Routes.guarantorsExposure,
      path: '/${Routes.guarantorsExposure}',
      builder: (context, state) => const GuarantorsExposureView(),
    ),
    GoRoute(
      name: Routes.queriesAndResponses,
      path: '/${Routes.queriesAndResponses}',
      builder: (context, state) => const QueriesAndResponsesView(),
    ),
    GoRoute(
      name: Routes.comments,
      path: '/${Routes.comments}',
      builder: (context, state) => const CommentsView(),
    ),
    GoRoute(
      name: Routes.requestForFOL,
      path: '/${Routes.requestForFOL}',
      builder: (context, state) => const RequestForFolView(),
    ),
    GoRoute(
      name: Routes.requestForClosure,
      path: '/${Routes.requestForClosure}',
      builder: (context, state) => const RequestForClosureView(),
    ),
    GoRoute(
      name: Routes.requestForLimitRelease,
      path: '/${Routes.requestForLimitRelease}',
      builder: (context, state) => const RequestForLimitReleaseView(),
    ),

    GoRoute(
      name: Routes.ccsysCreateRequest,
      path: '/${Routes.ccsysCreateRequest}',
      builder: (context, state) => const CCSYSCreateRequestView(),
    ),
    GoRoute(
      name: Routes.ccsysApproval,
      path: '/${Routes.ccsysApproval}',
      builder: (context, state) => const CcsysApprovalView(),
    ),
    GoRoute(
      name: Routes.ccsysCustomerInformation,
      path: '/${Routes.ccsysCustomerInformation}',
      builder: (context, state) => const CCSYSCustomerInformation(),
    ),
    GoRoute(
      name: Routes.createProject,
      path: '/${Routes.createProject}',
      builder: (context, state) => const CreateProjectView(),
    ),
    GoRoute(
      name: Routes.digitalEFiling,
      path: '/${Routes.digitalEFiling}',
      builder: (context, state) => const DigitalEfilingView(),
    ),
    GoRoute(
      name: Routes.editContract,
      path: '/${Routes.editContract}',
      builder: (context, state) => const EditContractView(),
    ),
    GoRoute(
      name: Routes.searchProject,
      path: '/${Routes.searchProject}',
      builder: (context, state) => const SearchProjectView(),
    ),
    GoRoute(
      name: Routes.linkContract,
      path: '/${Routes.linkContract}',
      builder: (context, state) => const LinkContractView(),
    ),
    GoRoute(
      name: Routes.ccsysRequestInformation,
      path: '/${Routes.ccsysRequestInformation}',
      builder: (context, state) => const CCSYSRequestInformation(),
    ),

    GoRoute(
      name: Routes.editViewProject,
      path: '/${Routes.editViewProject}',
      builder: (context, state) =>
          const CreateProjectView(isCreateProject: false),
    ),
    GoRoute(
      name: Routes.screenIndex,
      path: '/${Routes.screenIndex}',
      builder: (context, state) => const ScreenIndex(),
    ),
    GoRoute(
      name: Routes.appendix,
      path: '/${Routes.appendix}',
      builder: (context, state) => const AppendixView(),
    ),
    GoRoute(
      name: Routes.createFacilityFI,
      path: '/${Routes.createFacilityFI}',
      builder: (context, state) => const CreateFacilityView(),
    ),
  ],
);

extension GoRouterLocation on GoRouter {
  String get location {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}

class GoRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    Globals.currentRoute = route.settings.name ?? '/';
    Globals.previousRoute = previousRoute?.settings.name ?? '/';
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    Globals.currentRoute = route.settings.name ?? '/';
    Globals.previousRoute = previousRoute?.settings.name ?? '/';
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    Globals.currentRoute = route.settings.name ?? '/';
    Globals.previousRoute = previousRoute?.settings.name ?? '/';
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    Globals.currentRoute = newRoute?.settings.name ?? '/';
    Globals.previousRoute = oldRoute?.settings.name ?? '/';
  }
}
