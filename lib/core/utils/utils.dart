import "dart:collection";
import "dart:math";
import "package:easy_localization/easy_localization.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/application_details.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/file_attachment/document.dart";
import "package:wcas_frontend/models/request/request.dart";

/// Loading Status
///
/// Represents the state of a loading operation.
enum LoadingStatus {
  /// Data is currently loading.
  loading,

  /// Data has loaded successfully.
  loaded,

  /// An error occurred while loading data.
  error,

  /// No data is available.
  empty,
}

/// Menu Mode
///
/// Defines the visibility and accessibility state of a menu item.
enum MenuMode {
  /// Menu item is enabled.
  enabled,

  /// Menu item is disabled.
  disabled,

  /// Menu item is hidden.
  hidden,
}

/// Page Mode
///
/// Defines the current mode of a page.
enum PageMode {
  /// Page is in view mode.
  view,

  /// Page is in edit mode.
  edit,

  /// Page mode is not applicable.
  na,
}

/// Type Mode
///
/// Defines the operation type.
enum TypeMode {
  /// Create operation mode.
  create,

  /// Edit operation mode.
  edit,
}

/// User Role
///
/// Defines the supported user roles within the application.
enum UserRole {
  /// Administrator role.
  admin,

  /// Relationship officer role.
  relationshipOfficer,

  /// Relationship manager role.
  relationshipManager,

  /// Team leader business role.
  teamLeaderBusiness,

  /// Commercial area manager role.
  commercialAreaManager,

  /// Relationship manager business role.
  relationshipManagerBussiness,

  /// Segment head business role.
  segmentHeadBusiness,

  /// Credit coordinator role.
  creditCordinator,

  /// Credit analyst role.
  creditAnalyst,

  /// Credit committee proxy role.
  creditCommitteeProxy,

  /// Board director proxy role.
  boardDirectorProxy,

  /// Team leader credit level D1 role.
  teamLeaderCreditLevelD1,

  /// Segment head credit level D role.
  segmentHeadCreditLevelD,

  /// Segment head level C role.
  segmentHeadLevelC,

  /// Segment head level B1 role.
  segmentHeadLevelB1,

  /// Segment head level B role.
  segmentHeadLevelB,

  /// Credit committee proxy approver role.
  creditCommitteeProxyApprover,

  /// Board director proxy approval role.
  boardDirectorProxyApproval,

  /// Documentation checker role.
  documentationChecker,

  /// Documentation maker role.
  documentationMaker,

  /// CCU maker role.
  ccuMaker,

  /// CCU checker role.
  ccuChecker,

  /// Business administrator role.
  businessAdmin,

  /// ICS administrator role.
  icsAdmin,

  /// Inquiry user role.
  inquiryUser,

  /// Financial pool coordinator role.
  financialPoolCoordinator,

  /// Financial pool maker role.
  financialPoolMaker,

  /// Financial pool checker role.
  financialPoolChecker,

  /// Credit committee role.
  creditCommittee,

  /// Board of directors role.
  boardOfDirectors,

  /// Limit input team role.
  limitInputTeam,

  /// Legal team role.
  legalTeam,

  /// Legal team coordinator role.
  legalTeamCoordinator,

  /// Business unit head role.
  businessUnitHead,

  /// Not applicable role.
  na,
}

/// Business Segment
///
/// Defines the supported business segments.
enum BusinessSegment {
  /// Corporate segment.
  corporate,

  /// Financial institution segment.
  financialInstitution,

  /// Financial institution CF segment.
  financialInstitutionCF,

  /// Business segment.
  business,

  /// BAF segment.
  baf,

  /// Personal segment.
  personal,

  /// Not applicable segment.
  na,
}

/// Request Type
///
/// Defines the supported request types.
enum RequestType {
  /// Full credit assessment request.
  fullCA,

  /// Isolated request.
  isolated,
}

/// Application Type
///
/// Defines the supported application types.
enum ApplicationType {
  /// New-to-bank application.
  newToBank,

  /// Annual review application.
  annualReview,

  /// Interim amendment application.
  interimAmendment,

  /// Reconsideration application.
  reconsideration,

  /// Mark-forward application.
  markForward,

  /// Risk rating change application.
  riskRatingChange,

  /// Documentation deferral application.
  documentationDeferral,

  /// Cancellation application.
  cancellation,

  /// One-off limit application.
  oneOffLimit,

  /// Isolated excess application.
  isolatedExcessType,

  /// Isolated project allocation application.
  isolatedProjectAllocation,

  /// Isolated other application.
  isolatedOther,

  /// Isolated allocation application.
  isolatedAllocation,
}

/// Customer Type
///
/// Defines the supported customer types.
enum CustomerType {
  /// Corporate customer.
  corporate,

  /// Country customer.
  country,

  /// Below investment grade bank customer.
  belowInvestmentGradeBanks,

  /// Investment grade bank customer.
  investmentGradeBanks,

  /// Request for FOL customer.
  requestForFOL,

  /// Bank for Legacy Data customer.
  bank,
}

/// Comments Type
///
/// Defines the supported comment types used throughout the application.
enum CommentsType {
  /// Request application detailed comments.
  requestApplicationDetailed,

  /// Security comments.
  security,

  /// Approval comments.
  approval,

  /// Covenants summary comments.
  covenantsSummary,

  /// Conditions summary comments.
  conditionsSummary,

  /// Request for FOL comments.
  requestForFOL,

  /// Request for closure comments.
  requestForClosure,

  /// Request for limit release comments.
  requestForLimitRelease,

  /// Queries and responses comments.
  queriesResponses,

  /// Present request comments.
  presentRequest,

  /// Security perfection comments.
  securityPerfection,

  /// Facilities with CBD comments.
  facilitiesWithCbd,

  /// Facilities with other bank comments.
  facilitiesWithOtherBank,

  /// Central Bank Risk Bureau data comments.
  centralBankRiskBureauData,

  /// Account statistics comments.
  accountStats,

  /// Business volume comments.
  bussinessVolume,

  /// Income summary comments.
  incomeSummary,

  /// Share wallet comments.
  shareWallet,

  /// Remarks comments.
  remarks,

  /// SIC code review comments.
  sicCodeReview,

  /// Strategy comments.
  strategyComments,

  /// Terminate withdrawal comments.
  terminateWithdraw,

  /// Risk rating comments.
  riskRating,

  /// Internal risk rating FI comments.
  internalRiskRatingFi,

  /// External risk rating FI comments.
  externalRiskRatingFi,

  /// Contract comments.
  contract,

  /// Relationship profitability detailed comments.
  relationshipProfitabilityDetailed,

  /// RAROC common comments.
  rarocCommonComments,

  /// Group corporate structure comments.
  groupCorpoarteStruture,

  /// CCSYS comments.
  ccsys,

  /// Credit appraisal comments.
  creditAppraisal,

  /// Credit brief comments.
  creditBrief,

  /// Group summary comments.
  groupSummary,

  /// Group overview comments.
  groupOverview,

  /// Group management comments.
  groupManagement,

  /// Succession risk comments.
  successionRisk,

  /// Relationship strategy comments.
  relationshipStrategy,

  /// Management comments.
  managementComment,

  /// Appendix comments.
  appendix,

  /// Country summary comments.
  countrySummary,

  /// Recommendation for current approval comments.
  recommendCurrentApproval,

  /// FOL additional comments.
  folAdditionalComment,

  /// Previous credit approval comments.
  previousCreditApproval,
}

/// Comments Category
///
/// Defines the supported comment categories.
enum CommentsCategory {
  /// Request application detailed category.
  requestApplicationDetailed,

  /// Security category.
  security,

  /// Approval category.
  approval,

  /// Covenants summary category.
  covenantsSummary,

  /// Conditions summary category.
  conditionsSummary,

  /// Request for FOL category.
  requestForFOL,

  /// Request for closure category.
  requestForClosure,

  /// Request for limit release category.
  requestForLimitRelease,

  /// Queries and responses category.
  queriesResponses,

  /// Present request category.
  presentRequest,

  /// Security perfection category.
  securityPerfection,

  /// Facilities with CBD category.
  facilitiesWithCbd,

  /// Facilities with other bank category.
  facilitiesWithOtherBank,

  /// Central Bank Risk Bureau data category.
  centralBankRiskBureauData,

  /// Account statistics category.
  accountStats,

  /// Business volume category.
  bussinessVolume,

  /// Income summary category.
  incomeSummary,

  /// Share wallet category.
  shareWallet,

  /// Remarks category.
  remarks,

  /// SIC code review category.
  sicCodeReview,

  /// Strategy comments category.
  strategyComments,

  /// Terminate withdrawal category.
  terminateWithdraw,

  /// Risk rating category.
  riskRating,

  /// Contract category.
  contract,

  /// Relationship profitability detailed category.
  relationshipProfitabilityDetailed,

  /// RAROC common comments category.
  rarocCommonComments,

  /// Group corporate structure category.
  groupCorpoarteStruture,

  /// CCSYS category.
  ccsys,

  /// Credit appraisal category.
  creditAppraisal,

  /// Credit brief category.
  creditBrief,

  /// Group summary category.
  groupSummary,

  /// Group overview category.
  groupOverview,

  /// Group management category.
  groupManagement,

  /// Succession risk category.
  successionRisk,

  /// Relationship strategy category.
  relationshipStrategy,

  /// Management comment category.
  managementComment,

  /// Appendix category.
  appendix,
}

/// Entity Identifier
///
/// Defines entity identifiers used for comments and related operations.
enum EntityIdentifier {
  /// Request application detailed entity.
  requestApplicationDetailed,

  /// Security entity.
  security,

  /// Approval entity.
  approval,

  /// Covenants summary entity.
  covenantsSummary,

  /// Conditions summary entity.
  conditionsSummary,

  /// Request for FOL entity.
  requestForFOL,

  /// Request for closure entity.
  requestForClosure,

  /// Request for limit release entity.
  requestForLimitRelease,

  /// Queries and responses entity.
  queriesResponses,

  /// Present request entity.
  presentRequest,

  /// Security perfection entity.
  securityPerfection,

  /// Facilities with CBD entity.
  facilitiesWithCbd,

  /// Facilities with other bank entity.
  facilitiesWithOtherBank,

  /// Central Bank Risk Bureau data entity.
  centralBankRiskBureauData,

  /// Account statistics entity.
  accountStats,

  /// Business volume entity.
  bussinessVolume,

  /// Income summary entity.
  incomeSummary,

  /// Share wallet entity.
  shareWallet,

  /// Remarks entity.
  remarks,

  /// SIC code review entity.
  sicCodeReview,

  /// Strategy comments entity.
  strategyComments,

  /// Terminate withdrawal entity.
  terminateWithdraw,

  /// Contract entity.
  contract,

  /// Relationship profitability detailed entity.
  relationshipProfitabilityDetailed,

  /// RAROC common comments entity.
  rarocCommonComments,

  /// Group corporate structure entity.
  groupCorpoarteStruture,

  /// CCSYS entity.
  ccsys,

  /// Credit assessment entity.
  creditAssesment,

  /// Group summary entity.
  groupSummary,

  /// Management comment entity.
  managementComment,

  /// Appendix entity.
  appendix,

  /// Recommendation for current approval entity.
  recommendCurrentApproval,

  /// Country summary entity.
  countrySummary,

  /// Previous credit approval entity.
  previousCreditApproval,
}

/// Certification Type
///
/// Defines certification types.
enum CertificationType {
  /// RM certification.
  rm,

  /// Documentation certification.
  documentation,

  /// Limit input certification.
  limitInput,
}

/// Covenant Type
///
/// Defines covenant categories.
enum CovenantType {
  /// Information covenant.
  information,

  /// Non-financial covenant.
  nonFinancial,

  /// Financial covenant.
  financial,

  /// No covenant type.
  none,
}

/// Covenant Subtype
///
/// Defines covenant subcategories.
enum CovenantSubType {
  /// Financial statements covenant.
  financialStatements,

  /// Project progress report covenant.
  projectProgressReport,

  /// Debtors and stock ageing covenant.
  debtorsAndStockAgeing,

  /// Personal net worth income statement covenant.
  personalNetWorthIncomeStatement,

  /// Operating budget covenant.
  operatingBudget,

  /// Other covenant subtype.
  other,

  /// No covenant subtype.
  none,
}

/// Approval Fields
///
/// Defines approval action fields available in workflows.
enum ApprovalFields {
  /// Amend RAROC action.
  amendRAROC,

  /// Amend facilities action.
  amendFacilities,

  /// Amend securities action.
  amendSecurities,

  /// Amend conditions action.
  amendConditions,

  /// Amend risk rating action.
  amendRiskRating,

  /// Approve action.
  approve,

  /// Approval delegation action.
  approvalDelegation,

  /// Decline action.
  decline,

  /// Reason for decline field.
  reasonForDecline,

  /// Generate pack action.
  generatePack,

  /// Close application action.
  closeApplication,

  /// No return action.
  noReturn,

  /// Recommend action.
  recommend,

  /// Returns action.
  returns,

  /// Preview application action.
  previewApplication,

  /// Save action.
  save,

  /// Save and continue action.
  saveAndContinue,

  /// Amend covenants action.
  amendCovenants,

  /// Amend facility security linkage action.
  amendFacilitySecurityLinkage,

  /// Approve on behalf action.
  approveonbehalf,

  /// Initiate final FOL action.
  initiateFinalFOL,

  /// Documentation submitted action.
  documentationSubmitted,

  /// Send to documentation action.
  sendToDocumentation,

  /// Return to documentation maker action.
  returnToDocumentationMaker,

  /// Initiate fit-to-lend action.
  initiateFitToLend,

  /// Stage field.
  stage,

  /// Send to CCU action.
  sendToCCU,

  /// Send to RORM action.
  sendToRORM,

  /// Draft FOL generated action.
  draftFolGenerated,

  /// Final FOL generated action.
  finalFOLGenerated,

  /// Documentation completed action.
  documentationCompleted,

  /// Send to documentation checker action.
  sendToDocumentationChecker,

  /// Send to documentation maker action.
  sendToDocumentationMaker,

  /// Right first time action.
  rightFirstTime,

  /// Send to CCU maker action.
  sendtoCCUMaker,

  /// Send to CCU checker action.
  sendtoCCUChecker,

  /// Return to CCU maker action.
  returntoCCUMaker,

  /// Accept close application action.
  acceptCloseApplication,
}

/// Approval Category
///
/// Defines approval comment categories.
enum ApprovalCategory {
  /// Credit appraisal category.
  creditAppraisal,

  /// Credit brief category.
  creditBreif,

  /// Group overview category.
  groupOverview,

  /// Group management category.
  groupManagement,

  /// Group risk category.
  groupRisk,

  /// Group strategy category.
  groupStrategy,

  /// Credit committee category.
  creditCommittee,

  /// CCO comment category.
  ccoComment,

  /// CEO comment category.
  ceoComment,

  /// BCIC comment category.
  bcicComment,

  /// Recommendation comment category.
  recommendComment,

  /// Request category.
  request,

  /// Rationale category.
  rational,

  /// Summary of latest development category.
  summaryOfLastDev,

  /// Banking sector category.
  bankingSector,

  /// FI recommendation category.
  fiRecommendation,

  /// Recommendation for current approval category.
  recommendCurrentApproval,

  /// Previous credit approval category.
  previousCreditApproval,
}

/// Request Status
///
/// Defines the lifecycle status of a request.
enum RequestStatus {
  /// Request has been initiated.
  initiated,

  /// Request is pending approval.
  pendingForApproval,

  /// Request has been approved.
  approved,

  /// Request has been declined.
  declined,

  /// Request has been withdrawn or cancelled.
  requestWithdrawnCancelled,

  /// Request is pending FOL issuance.
  pendingFolIssuance,

  /// Request has been terminated.
  terminated,

  /// Request has been completed.
  completed,

  /// FOL issued and pending sign-off.
  folIssuedPendingSignOff,

  /// FOL sign-off completed and pending fit-to-lend.
  folSignOffCompletedPendingFitToLend,

  /// Fit-to-lend completed and pending limit release.
  fitToLendCompletedPendingLimitRelease,

  /// Pending limit release.
  pendingLimitRelease,

  /// FOL is not required.
  folNotRequired,

  /// Not applicable status.
  na,
}

/// User Action
///
/// Defines workflow actions performed by users.
enum UserAction {
  /// Task completed.
  completed,

  /// Save and move to next step.
  saveNext,

  /// Draft saved.
  draftSave,

  /// Approve on behalf of another user.
  approveOnBehalfOf,

  /// Assign to credit approval team.
  assignToCreditApprovalTeam,

  /// Returned to previous stage.
  returned,

  /// Approved.
  approved,

  /// Declined.
  declined,

  /// Recommended.
  recommended,

  /// Accept close application.
  acceptCloseApplication,

  /// Self-assigned by credit analyst.
  selfAssignedCA,

  /// Returned to pool.
  returnToPool,

  /// Assigned to administrator.
  assignToAdmin,

  /// Assigned from business administrator.
  assignFromBusinessAdmin,
}

/// FOL Type Action
///
/// Defines workflow actions related to FOL processing.
enum FOLTypeAction {
  /// Documentation submitted.
  documentationSubmitted,

  /// Documentation completed.
  documentationCompleted,

  /// Assigned to documentation checker or maker.
  assignedToDcDm,

  /// Initiate final FOL.
  initiateFinalFOL,

  /// Automatically assigned to documentation pool.
  autoAssignedToDocPool,

  /// Draft FOL generated.
  draftFolGenerated,

  /// Final FOL generated.
  finalFolGenerated,

  /// Self-assigned to CCU maker.
  selfAssignedCcuMaker,

  /// Sent to CCU checker.
  sendToCCUChecker,

  /// Sent to CCU maker.
  sendToCCUMaker,

  /// Automatically assigned to CCU pool.
  autoAssigndToCcuPool,

  /// Sent to documentation.
  sendToDocumentation,

  /// Sent to documentation maker.
  sendToDocumentationMaker,

  /// Sent to RORM.
  sendToRoRm,

  /// Sent to documentation checker.
  sendToDocumentationChecker,

  /// Sent to CCU.
  sendToCCU,

  /// Initiate fit-to-lend.
  initiateFitToLend,

  /// Returned from documentation or CCU.
  returnFromDocCCU,

  /// Draft FOL initiated.
  initiatedDraftFOL,

  /// Returned for amendment.
  returnForAmendment,

  /// Returned for amendment by CMO.
  returnForAmendmentCMO,

  /// Initiate limit loading.
  initiateLimitLoading,

  /// Returned to user.
  returnToUser,

  /// Sent to limit loading.
  sentToLimitLoading,

  /// Executed documents under review.
  executedDocsUnderReview,

  /// Returned to documentation maker.
  returnToDM,

  /// FOL not required.
  folNotRequired,
}

/// Application Subtype
///
/// Defines application subtypes.
enum ApplicationSubType {
  /// Risk rating subtype.
  riskRating,

  /// Cash margin subtype.
  cashMargin,
}

/// Document Type
///
/// Defines supported document categories.
enum DocumentType {
  /// Constitutional documents.
  constitutionalDocument,

  /// Credit Lens documents.
  creditLensDocument,

  /// Financial statements.
  financialStatements,

  /// Credit application documents.
  creditApplication,

  /// External opinion documents.
  externalOpinions,

  /// Facility documents.
  facilityDocuments,

  /// Valuation reports.
  valuationReports,

  /// Other document types.
  other,

  /// Legacy Uncategorized types.
  legacy,
}

/// Digital E-Filing Fields
///
/// Defines available actions in digital filing screens.
enum DigitaleFileFields {
  /// Upload document action.
  uploadDocument,

  /// Show approval decision action.
  showApprovalDecision,
}

/// File Attachment Fields
///
/// Defines available actions in file attachment screens.
enum FileAttachmentFields {
  /// Download documents action.
  downloadDocuments,

  /// Show approval decision action.
  showApprovalDecision,
}

/// Visible Graph Type
///
/// Defines available dashboard graph types.
enum VisibleGraphType {
  /// Pie chart.
  pie,

  /// Bar chart.
  bar,
}

/// Dashboard Ageing Type
///
/// Defines dashboard ageing ranges.
enum DashboardAgeingType {
  /// 0 to 7 days.
  zeroToSevenDays,

  /// 8 to 15 days.
  eightToFifteenDays,

  /// 16 to 30 days.
  sixteenToThirtyDays,

  /// Above 30 days.
  aboveThirtyDays,
}

/// Maps dashboard ageing types to API filter values.
Map<DashboardAgeingType, String> dashboardFilterMap = {
  DashboardAgeingType.zeroToSevenDays: "0_7_days",
  DashboardAgeingType.eightToFifteenDays: "8_15_days",
  DashboardAgeingType.sixteenToThirtyDays: "16_30_days",
  DashboardAgeingType.aboveThirtyDays: "above_30_days",
};

/// Maps dashboard ageing types to UI display labels.
Map<DashboardAgeingType, String> dashboardFilterMapToUI = {
  DashboardAgeingType.zeroToSevenDays: "0-7 Days",
  DashboardAgeingType.eightToFifteenDays: "8-15 Days",
  DashboardAgeingType.sixteenToThirtyDays: "16-30 Days",
  DashboardAgeingType.aboveThirtyDays: "above-30 Days",
};

/// Maps summary types to localized dashboard labels.
final Map<SummaryType, String> summaryTypeMap = {
  SummaryType.me: "dashboard.home.summary.pendingWithMe".tr(),
  SummaryType.business: "dashboard.home.summary.pendingWithBusiness".tr(),
  SummaryType.credit: "dashboard.home.summary.pendingWithCredit".tr(),
  SummaryType.documentation:
      "dashboard.home.summary.pendingWithDocumentation".tr(),
  SummaryType.team: "dashboard.home.summary.pendingWithTeam".tr(),
  SummaryType.pool: "dashboard.home.summary.pendingWithPool".tr(),
  SummaryType.approvingauthority:
      "dashboard.home.summary.pendingWithApprovingAuthority".tr(),
  SummaryType.creditcontrol:
      "dashboard.home.summary.pendingWithCreditControl".tr(),
  SummaryType.creditcontrolCCSYS:
      "dashboard.home.summary.pendingWithCreditControl-CCSYS".tr(),
  SummaryType.requests:
      "dashboard.home.summary.recommendedRequestRequests".tr(),
  SummaryType.documentationrequest:
      "dashboard.home.summary.returnedRequestDocumentation".tr(),
  SummaryType.ro: "dashboard.home.summary.returnedRequestRO".tr(),
  SummaryType.rm: "dashboard.home.summary.returnedRequestRM".tr(),
  SummaryType.dc: "dashboard.home.summary.returnedToDocumentationChecker".tr(),
  SummaryType.dm: "dashboard.home.summary.returnedRequestDM".tr(),
  SummaryType.cam: "dashboard.home.summary.returnedRequestCAM".tr(),
  SummaryType.tlb: "dashboard.home.summary.returnedRequestTLB".tr(),
  SummaryType.shb: "dashboard.home.summary.returnedRequestSHB".tr(),
  SummaryType.rmb: "dashboard.home.summary.returnedRequestRMB".tr(),
  SummaryType.unitHead: "dashboard.home.summary.returnedRequestUnitHead".tr(),
  SummaryType.creditCordinator:
      "dashboard.home.summary.returnedRequestreditCordinator".tr(),
  SummaryType.ccood:
      "dashboard.home.summary.returnedRequestreditCordinator".tr(),
  SummaryType.ccuMaker: "dashboard.home.summary.returnedRequestCcuMaker".tr(),
  SummaryType.tld1: "dashboard.home.summary.returnedRequestTL-D1".tr(),
  SummaryType.shld: "dashboard.home.summary.returnedRequestSH-D".tr(),
  SummaryType.shlc: "dashboard.home.summary.returnedRequestSH-c".tr(),
  SummaryType.shlb1: "dashboard.home.summary.returnedRequestSH-B1".tr(),
  SummaryType.shlb: "dashboard.home.summary.returnedRequestSH-B".tr(),
  SummaryType.ccProxy: "dashboard.home.summary.returnedRequestCCProxy".tr(),
  SummaryType.ccProxyApprover:
      "dashboard.home.summary.returnedRequestCCProxyApprover".tr(),
  SummaryType.bdProxy: "dashboard.home.summary.returnedRequestBDProxy".tr(),
  SummaryType.ca: "dashboard.home.summary.returnedRequestCreditAnalyst".tr(),
  SummaryType.pendingWithRelationShipTeam: "Pending With Relationship Team",
  SummaryType.pendingWithBusinessTeam: "Pending With Business Team",
};

/// Maps summary types to request filter values used by the dashboard APIs.
final Map<SummaryType, String> summaryTypeRequestMap = {
  SummaryType.me: "pendingWithMe",
  SummaryType.na: "pendingWithMe",
  SummaryType.business: "pendingWithBusiness",
  SummaryType.credit: "pendingWithCredit",
  SummaryType.documentation: "pendingWithDocumentation",
  SummaryType.team: "pendingWithTeam",
  SummaryType.pool: "pendingWithPool",
  SummaryType.approvingauthority: "pendingWithApprovingAuthority",
  SummaryType.creditcontrol: "pendingWithCreditControl",
  SummaryType.creditcontrolCCSYS: "pendingWithCreditControl-CCSYS",
  SummaryType.requests: "requestToRecommend",
  SummaryType.documentationrequest: "returnedToDocumentation",
  SummaryType.ro: "returnedToRO",
  SummaryType.rm: "returnedToRM",
  SummaryType.dc: "returnedToDC",
  SummaryType.dm: "returnedToDM",
  SummaryType.unitHead:
      "returnedToCAM, returnedToTLB, returnedToSHB, returnedToRMB",
  SummaryType.creditCordinator: "returnedToCCOD",
  SummaryType.ccood: "returnedToCCOOD",
  SummaryType.ccuMaker: "returnedToCCUM",
  SummaryType.tld1: "returnedToTL-D1",
  SummaryType.shld: "returnedToSH-D",
  SummaryType.shlc: "returnedToSH-C",
  // SummaryType.rmb: "returnedToRMB",
  // SummaryType.cam: "returnedToCAM",
  // SummaryType.tlb: "returnedToTLB",
  // SummaryType.shb: "returnedToSHB",
  SummaryType.shlb1: "returnedToSH-B1",
  SummaryType.shlb: "returnedToSH-B",
  SummaryType.ccProxy: "returnedToCCP",
  SummaryType.ccProxyApprover: "returnedToCCPA",
  SummaryType.bdProxy: "returnedToBDP",
  SummaryType.ca: "returnedToCA",
  SummaryType.pendingWithRelationShipTeam: "pendingWithRelationShipTeam",
  SummaryType.pendingWithBusinessTeam: "pendingWithBusinessTeam",
};

/// Bar Graph Helper
///
/// Defines bar graph categories used in dashboard visualizations.
enum BarGraphHelper {
  /// New-to-bank category.
  newToBank,

  /// Annual review with same level.
  annualReviewSameLevel,

  /// Annual review with increased level.
  annualReviewIncrease,

  /// Annual review with decreased level.
  annualReviewDecrease,

  /// Interim review with same level.
  interimReviewSameLevel,

  /// Interim review with increased level.
  interimReviewIncrease,

  /// Interim review with decreased level.
  interimReviewDecrease,

  /// Reconsideration with same level.
  reconsiderationSameLevel,

  /// Reconsideration with increased level.
  reconsiderationIncrease,

  /// Reconsideration with decreased level.
  reconsiderationDecrease,

  /// Facility cancellation category.
  facilityCancellation,

  /// Isolated memo category.
  isolatedMemo,

  /// Not applicable category.
  na,
}

/// Summary Type
///
/// Defines dashboard summary categories.
enum SummaryType {
  /// Pending with me.
  me,

  /// Pending with business.
  business,

  /// Pending with credit.
  credit,

  /// Pending with documentation.
  documentation,

  /// Pending with team.
  team,

  /// Pending with approving authority.
  approvingauthority,

  /// Pending with credit control.
  creditcontrol,

  /// Pending with credit control CCSYS.
  creditcontrolCCSYS,

  /// Recommended requests.
  requests,

  /// Pending with pool.
  pool,

  /// Returned to documentation.
  documentationrequest,

  /// Returned to documentation checker.
  dc,

  /// Returned to documentation maker.
  dm,

  /// Returned to relationship officer.
  ro,

  /// Returned to relationship manager.
  rm,

  /// Returned to credit analyst.
  ca,

  /// Returned to commercial area manager.
  cam,

  /// Returned to team leader business.
  tlb,

  /// Returned to segment head business.
  shb,

  /// Returned to regional manager business.
  rmb,

  /// Not applicable.
  na,

  /// Returned to unit head.
  unitHead,

  /// Returned to credit coordinator.
  creditCordinator,

  /// Returned to CCU maker.
  ccuMaker,

  /// Returned to team leader D1.
  tld1,

  /// Returned to segment head D.
  shld,

  /// Returned to segment head C.
  shlc,

  /// Returned to segment head B1.
  shlb1,

  /// Returned to segment head B.
  shlb,

  /// Returned to CC proxy.
  ccProxy,

  /// Returned to CC proxy approver.
  ccProxyApprover,

  /// Returned to BD proxy.
  bdProxy,

  /// Pending with relationship team.
  pendingWithRelationShipTeam,

  /// Pending with business team.
  pendingWithBusinessTeam,

  /// Returned to CCOOD.
  ccood,
}

/// Security Type
///
/// Defines supported security types.
enum SecurityType {
  /// Assignment of insurances.
  assignmentOfInsurancess,

  /// Notarised commercial mortgage.
  notarisedCommercialMortgage,

  /// Assignment of leasehold musataha.
  assignmentOfLeaseholdMusataha,

  /// Personal guarantee.
  personalGuarantee,

  /// Assignment of receivables.
  assignmentOfReceivables,

  /// Pledge of account.
  pledgeOfAccount,

  /// Bank guarantee.
  bankGuarantee,

  /// Charge over CBDFS portfolio.
  chargeOverCbdfsPortfolio,

  /// Pledge of bonds.
  pledgeOfBonds,

  /// Conditional assignment of SPA.
  conditionalAssignmentOfSpa,

  /// Pledge of commodities.
  pledgeOfCommodities,

  /// Corporate guarantee.
  corporateGuarantee,

  /// Pledge of investment products.
  pledgeOfInvestmentProducts,

  /// Hold on title deeds.
  holdOnTitleDeeds,

  /// Pledge of shares or bonds of a joint stock company.
  pledgeOfSharesBondsOfJointStockCompany,

  /// Mortgage of properties.
  mortgageOfProperties,

  /// Pledge of shares of a limited liability company.
  pledgeOfSharesOfALimitedLiabilityCompany,

  /// Mortgage of aircraft.
  mortgageOfAircraft,

  /// Mortgage of movable assets registered with EIRC.
  pledgeOfMoveableAssetsRegisteredWithEircViaUaeMovablesAgreement,

  /// Mortgage of leasehold musataha.
  mortgageOfLeaseholdMusataha,

  /// Pledge of precious metals.
  pledgeOfPreciousMetals,

  /// Mortgage of vehicles.
  mortgageOfVehicles,

  /// Pledge of term deposit.
  pledgeOfTd,

  /// Mortgage of vessel.
  mortgageOfVessel,

  /// Security cheque.
  securityCheque,

  /// Mortgage with free zone authorities.
  mortgageWithFreeZoneAuthorities,

  /// Pledge of plant and machinery fixed assets.
  pledgeOfPlantAndMachineryFixedAssets,

  /// Promissory note.
  promissoryNote,

  /// Other financial guarantee or borrower credit insurance.
  otherFinancialGuaranteeBorrowersCreditInsurance,

  /// Lien over shares held by CBD Financial Services.
  lienOverSharesHeldByCbdFinancialServices,

  /// Pledge of shares.
  pledgeOfShares,

  /// Authority to debit account.
  authorityToDebitAccount,

  /// Subordination letter.
  subordinationLetter,

  /// Third-party post-dated cheques considered good.
  thirdPartyPostDatedChequesConsideredGood,

  /// Post-dated cheque.
  postDatedCheque,
}

/// Facility Type
///
/// Defines the supported facility types available in the application.
enum FacilityType {
  /// Overdraft Real Estate/Project.
  overdraftRealEstateProject,

  /// Overdraft against Shares/Bonds.
  overdraftAgainstSharesBonds,

  /// Flexi Overdraft.
  flexiOverdraft,

  /// Overdraft against Progress Payment Certificate.
  overdraftAgainstProgressPaymentCertificate,

  /// Overdraft on CBD FS Portfolio.
  overdraftOnCbdFsPortfolio,

  /// Overdraft against investment products.
  overdraftAgainstInvestmentProducts,

  /// Loan against Tasdeer.
  loanAgainstTasdeer,

  /// Cheque Discounting.
  chequeDiscounting,

  /// Loan against collection documents / Inventory Finance.
  loanAgainstCollectionDocumentsInventoryFinance,

  /// Export Bill Discounting.
  exportBillDiscounting,

  /// Loan against invoice sales.
  loanAgainstInvoiceSales,

  /// Loan against Progress Payment Certificate.
  loanAgainstProgressPaymentCertificate,

  /// Loan Against Trust Receipt.
  loanAgainstTrustReceipt,

  /// Loan against acceptance document.
  loanAgainstAcceptanceDocument,

  /// Loan against invoice purchase.
  loanAgainstInvoicePurchase,

  /// Term Loan - Commercial.
  termLoanCommercial,

  /// Real Estate Loan.
  realEstateLoan,

  /// Syndication Loans.
  syndicationLoans,

  /// Rental Loan.
  rentalLoan,

  /// Vehicle Loan.
  vehicleLoan,

  /// Loan for Purchase of Listed Bonds.
  loanForPurchaseOfListedBonds,

  /// Letter of Credit - Overseas Time.
  letterOfCreditOverseasTime,

  /// Letter of Credit - Overseas Sight.
  letterOfCreditOverseasSight,

  /// Letter of Credit - Local Sight.
  letterOfCreditLocalSight,

  /// Letter of Credit - Local Time.
  letterOfCreditLocalTime,

  /// Standby Letter of Credit.
  standbyLetterOfCredit,

  /// Avalisation.
  avalisation,

  /// Letter of Guarantee - Bid/Tender.
  letterOfGuaranteeBidTender,

  /// Letter of Guarantee - Performance.
  letterOfGuaranteePerformance,

  /// Letter of Guarantee - Advance Payment.
  letterOfGuaranteeAdvancePayment,

  /// Letter of Guarantee - Financial.
  letterOfGuaranteeFinancial,

  /// Letter of Guarantee - Retention and Maintenance.
  letterOfGuaranteeRetentionAndMaintenance,

  /// Letter of Guarantee - Labour Guarantee.
  letterOfGuaranteeLabourGuarantee,

  /// Murabaha.
  murabaha,

  /// Tawarruq.
  tawarruq,

  /// Ijarah.
  ijarah,

  /// Forward Ijarah.
  forwardIjarah,

  /// Overdraft Islamic.
  overdraftIslamic,

  /// Letter of Credit - Overseas Sight (Islamic).
  letterOfCreditOverseasSightIslamic,

  /// Letter of Credit - Local Sight (Islamic).
  letterOfCreditLocalSightIslamic,

  /// Letter of Credit - Overseas Time (Islamic).
  letterOfCreditOverseasTimeIslamic,

  /// Letter of Credit - Local Time (Islamic).
  letterOfCreditLocalTimeIslamic,

  /// Standby Letter of Credit (Islamic).
  standbyLetterOfCreditIslamic,

  /// Letter of Guarantee Bid (Islamic).
  letterOfGuaranteeBidIslamic,

  /// Letter of Guarantee Financial (Islamic).
  letterOfGuaranteeFinancialIslamic,

  /// Letter of Guarantee Labour (Islamic).
  letterOfGuaranteeLabourIslamic,

  /// Letter of Guarantee Performance (Islamic).
  letterOfGuaranteePerformanceIslamic,

  /// Letter of Guarantee - Advance Payment (Islamic).
  letterOfGuaranteeAdvancePaymentIslamic,

  /// Letter of Guarantee - Retention and Maintenance (Islamic).
  letterOfGuaranteeRetentionAndMaintenanceIslamic,

  /// Limit Caps.
  limitCaps,

  /// Overall PFE Limit.
  overallPfeLimit,

  /// Taharuq Against Invoice.
  taharuqAgainstInvoice,

  /// Vehicle Loan up to Proposed Amount.
  vehicleLoanUptoProposedAmount,

  /// Tawarruk against PPC.
  tawarrukAgainstPpc,

  /// PRS (Profit Rate Swaps).
  prsProfitRateSwaps,

  /// Letter of Guarantee - All Types.
  letterOfGuaranteeAllTypes,

  /// Letter of Credit - All Types.
  letterOfCreditAllTypes,

  /// Letter of Credit - All Types (Islamic).
  letterOfCreditAllTypesIslamic,

  /// Letter of Guarantee - All Types (Islamic).
  letterOfGuaranteeAllTypesIslamic,

  /// Short Term Loan.
  shortTermLoan,

  /// Open Account TR - Advance Payment against Pro-forma Invoices.
  openAccountTrAdvancePaymentAgainstProFormaInvoices,

  /// Open Account TR - Advance Payment against Copies of Shipping Documents.
  openAccountTrAdvancePaymentAgainstCopiesOfShippingDocuments,

  /// Open Account TR - Post Shipment / Post Delivery.
  openAccountTrPostShipmentPostDelivery,

  /// Open Account TR - Post Delivery Post Supplier Credit Period.
  openAccountTrPostDeliveryPostSupplierCreditPeriod,

  /// Moveable Assets.
  moveableAssets,

  /// Immoveable Assets.
  immoveableAssets,

  /// Factoring without Recourse (Revolving).
  factoringWithoutRecoursesRevolving,

  /// Corporate Credit Card.
  corporateCreditCard,

  /// Buyer Led Supply Chain Financing.
  buyerLedSupplyChainFinancing,

  /// Seller Led Supply Chain Financing.
  sellerLedSupplyChainFinancing,

  /// Financing Export Collection Documents.
  financingExportCollectionDocuments,

  /// Tasdeer (LTP) (Pre).
  tasdeerLtpPre,

  /// Tasdeer (LTP) (Post).
  tasdeerLtpPost,

  /// Open Account TR - Advance Payment against Pro-forma Invoices (Islamic).
  openAccountTrAdvancePaymentAgainstProFormaInvoicesIslamic,

  /// Open Account TR - Advance Payment against Copies of Shipping Documents
  /// (Islamic).
  openAccountTrAdvancePaymentAgainstCopiesOfShippingDocumentsIslamic,

  /// Open Account TR - Post Shipment / Post Delivery (Islamic).
  openAccountTrPostShipmentPostDeliveryIslamic,

  /// Open Account TR - Post Delivery Post Supplier Credit Period (Islamic).
  openAccountTrPostDeliveryPostSupplierCreditPeriodIslamic,

  /// Not Disclosure.
  notDisclosure,
}

/// Covenant Type Helper
///
/// Provides helper methods for converting between covenant
/// types and their server identifiers.
extension CovenantTypeHelper on CovenantType {
  /// Returns a [CovenantType] for the specified identifier.
  static CovenantType fromId(int? id) {
    return ServerConstants.covenantTypeId.entries
        .firstWhere(
          (e) => e.value == id,
          orElse: () => const MapEntry(CovenantType.none, 0),
        )
        .key;
  }

  /// Returns the server identifier for the covenant type.
  int get id => ServerConstants.covenantTypeId[this]!;
}

/// Covenant Subtype Helper
///
/// Provides helper methods for converting between covenant
/// subtypes and their server identifiers.
extension CovenantSubTypeHelper on CovenantSubType {
  /// Returns a [CovenantSubType] for the specified identifier.
  static CovenantSubType fromId(int? id) {
    return ServerConstants.covenantSubTypeId.entries
        .firstWhere(
          (e) => e.value == id,
          orElse: () => const MapEntry(CovenantSubType.none, 0),
        )
        .key;
  }

  /// Returns the server identifier for the covenant subtype.
  int get id => ServerConstants.covenantSubTypeId[this]!;
}

/// Exclusion Status
///
/// Represents the exclusion state of an item.
enum ExclusionStatus {
  /// Item is excluded.
  excluded,

  /// Item is included.
  included,

  /// Exclusion status is unknown.
  unknown,
}

/// Exclusion Status Extension
///
/// Provides conversion helpers for exclusion status values.
extension ExclusionStatusX on ExclusionStatus {
  /// Returns the API value for the exclusion status.
  String get apiValue {
    switch (this) {
      case ExclusionStatus.excluded:
        return "YES";
      case ExclusionStatus.included:
        return "NO";
      case ExclusionStatus.unknown:
        return "NA";
    }
  }

  /// Creates an [ExclusionStatus] from an API value.
  static ExclusionStatus fromApi(String? s) {
    switch (s?.toUpperCase()) {
      case "YES":
        return ExclusionStatus.excluded;
      case "NO":
        return ExclusionStatus.included;
      default:
        return ExclusionStatus.unknown;
    }
  }

  /// Returns the exclusion status as a boolean value.
  ///
  /// Returns:
  /// * `true` for excluded
  /// * `false` for included
  /// * `null` for unknown
  bool? get toBool {
    switch (this) {
      case ExclusionStatus.excluded:
        return true;
      case ExclusionStatus.included:
        return false;
      case ExclusionStatus.unknown:
        return null;
    }
  }
}

/// Filter Type
///
/// Defines the supported filter criteria used in search and filtering.
enum FilterType {
  /// Filter by reference number.
  referenceNumber,

  /// Filter by reference type.
  referenceType,

  /// Filter by applicant RIM.
  applicantRim,

  /// Filter by applicant name.
  applicantName,

  /// Filter by application type.
  applicationType,

  /// Filter by security type.
  securityType,

  /// Filter by security number.
  securityNumber,

  /// Filter by account number.
  accountNumber,

  /// Filter by document type.
  documentType,

  /// Filter by request initiator.
  requestBy,

  /// Filter by request type.
  requestType,

  /// Filter by request status.
  requestStatus,

  /// Filter by business segment.
  businessSegment,

  /// Filter by received-from value.
  receivedFrom,
}

/// Utility helpers used across the application.
class Utils {
  /// Checks whether the current user has the specified role.
  static bool checkRole(UserRole role) {
    return Globals.user?.currentRole?.code ==
        ServerConstants.userRoleCode[role]; // Need to compare by id instead
  }

  /// Checks whether the current user has any of the specified roles.
  static bool checkRoles(List<UserRole> roles) {
    return roles.contains(Globals.user?.currentRole?.userRole);
  }

  /// Checks whether the current request belongs to the specified business segment.
  static bool checkBusinessSegment(BusinessSegment segment) {
    return Globals.request?.businessSegment?.id ==
        ServerConstants.businessSegmentId[segment];
  }

  /// Checks the application business segment.
  static bool checkApplicationBusinessSegment(BusinessSegment segment) {
    return Globals.request?.appBusinessSegment ==
        ServerConstants.businessSegmentType[segment];
  }

  /// Checks whether the current request matches the specified request type.
  static bool checkRequestType(RequestType type) {
    return Globals.request?.requestType?.id ==
        ServerConstants.requestTypeId[type];
  }

  /// Checks whether the current request matches the specified application type.
  static bool checkApplicationType(ApplicationType type) {
    //For appTypeReferenceId is applicationType ID if data use custom
    //application type
    return (Globals.request?.appTypeReferenceId != null)
        ? Globals.request?.applicationType?.id ==
            ServerConstants.applicationTypeIdCustom[type]
        : Globals.request?.applicationType?.id ==
            ServerConstants.applicationTypeIdCustom[type];
  }

  /// Checks whether the current request status matches the specified status.
  static bool checkRequestStatus(RequestStatus status) {
    //return true;
    final int? currentId = Globals.applicationDetails?.status;
    return currentId == ServerConstants.requestStatusId[status];
  }

  /// Checks whether the current request status matches any of the given statuses.
  static bool checkRequestStatuses(Iterable<RequestStatus> statuses) {
    final int? currentId = Globals.applicationDetails?.status;
    if (currentId == null) {
      return false;
    }
    return statuses.any(
      (status) => ServerConstants.requestStatusId[status] == currentId,
    );
  }

  /// Returns whether the current application is a group application.
  static bool isGroupApplication() {
    return (Globals.request?.isRequestCreated ?? false)
        ? ((Globals.request?.borrowers ?? []).isNotEmpty)
            ? (Globals.request?.borrowers?.length ?? 0) > 1
            : Globals.request?.groupId != null && Globals.request?.groupId != 0
        : Globals.request?.groupId != null && Globals.request?.groupId != 0;
  }

  /// Returns whether the current application is a group owner application.
  static bool isGroupOwnerApplication() {
    return Globals.request?.groupOwner != null &&
        Globals.request?.groupOwner != 0;
  }

  /// Returns the current request.
  static Request get request => Globals.request!;

//closed and dashboard app reference click
  static set request(Request request) {
    Globals.request = request;
  }

  /// Sets the global [ApplicationDetails] and computes the access control flags
  /// exactly once, caching them for the entire application session.
  /// Used to avoid expensive logic re-evaluations on every screen build.
  static void setApplicationDetails(ApplicationDetails appDetails) {
    Globals.applicationDetails = appDetails;
    Globals.isAllReadOnly = checkIfAppReadOnly();
    Globals.isInitiated = Globals.checkIsInitiated();
    Globals.request?.applicationSubType = appDetails.applicationSubType == "ME"
        ? ServerConstants.manualEntry
        : "";
  }

  /// Returns true if the currently loaded application is editable by the active
  /// user.
  /// Safely relies on the cached [Globals.isAllReadOnly] boolean.
  static bool canEditApplication() {
    return !Globals.isAllReadOnly;
  }

  /// Determines if the current application record should be strictly Read-Only.
  /// Returns [`true`] if the record is locked for the current user,
  /// and [`false`] if the current user has permission to edit it.
  static bool checkIfAppReadOnly() {
    if (Globals.applicationDetails == null) {
      return false;
    }
    // Safety check: Cannot edit if lifecycle details are missing.
    if (Globals.applicationDetails?.applicationLifeCycle == null) {
      return true;
    }

    final int? applicationStatus = Globals.applicationDetails!.status;
    final bool? enabledForView = Globals.applicationDetails!.enabledForView;
    final ApplicationLifeCycle lifeCycles =
        Globals.applicationDetails!.applicationLifeCycle!;

    // Rule: Terminal Statuses (e.g., Approved, Rejected, Cancelled)
    // If the application has reached a final state, it is permanently locked
    // for everyone.
    if (applicationStatus != null &&
        ServerConstants.lifeCycleReadOnlyStatuses.contains(applicationStatus)) {
      return true; // Read-only
    }

    // Rule: Task Assignment & Ownership
    // At this point, enabledForView is exactly true.
    // We verify if the current user is the rightful owner of the application
    // and is allowed to take action.
    final String assignedToUserId = (lifeCycles.assignedTo ?? "").trim();
    final int assignedToRole = lifeCycles.assignedToRole ?? 0;
    final String currentTaskStatus =
        (lifeCycles.status ?? "").trim().toLowerCase();

    final String currentUserBpmRole =
        (Globals.user?.currentRole?.bpmRole ?? "").trim();
    final String currentUserId = Globals.user?.id ?? "0";

    // Step a: Resolve the current user's  roleId from  bpmRole string.
    int currentUserRoleId = 0;
    for (final Map<String, int> roleMap in Globals.superBpmRolesId) {
      if (roleMap.containsKey(currentUserBpmRole) &&
          roleMap[currentUserBpmRole] != 0) {
        currentUserRoleId = roleMap[currentUserBpmRole]!;
        break;
      }
    }

    // Step b: Validate if the task is specifically assigned to the current
    // user's ID and Role.
    final bool isAssignedToCurrentUser =
        (assignedToRole == currentUserRoleId) &&
            (assignedToUserId == currentUserId);

    // If the application is not assigned to the user and userRole return Read-Only
    if (!isAssignedToCurrentUser) {
      return true; // Read-only
    }

    // Rule: Backend Edit Override
    // When enabledForView is explicitly false, it signals an editable state
    // (e.g., when a status update is pending from the backend).
    if (enabledForView == false) {
      return false; // Editable
    }

    // Rule: Graceful fallback for missing config
    // If enabledForView is neither true nor false (null), default to Read-Only
    // security.
    if (enabledForView == null) {
      return true; // Read-only
    }

    // Step c: Validate if the task status means it is actively awaiting user
    // action.
    final bool isTaskActive =
        currentTaskStatus == ServerConstants.lifeCycleStatusWaiting ||
            currentTaskStatus == ServerConstants.lifeCycleStatusAssigned;

    // If the task is active AND assigned to the current user, they are allowed
    // to edit (return false).
    // Otherwise, they are locked out and can only view it (return true).
    final bool canEdit = isAssignedToCurrentUser && isTaskActive;
    return !canEdit;
  }

  /// Returns a document type for the specified identifier.
  static DocumentType? getDocumentTypeById(int id) {
    return ServerConstants.documentTypeId.entries
        .firstWhere(
          (entry) => entry.value == id,
          orElse: () => const MapEntry(DocumentType.other, -1),
        )
        .key;
  }

  /// Returns which tabs should display asterisks based on business segment and
  /// customer type
  static List<RemarksTabs> getMandatoryRemarksTabs(Customer? customer) {
    // Safety: if customer is null-ish, nothing is mandatory
    if (customer == null) {
      return const [];
    }

    final bool isFI =
        Utils.checkBusinessSegment(BusinessSegment.financialInstitution);
    final bool isCorporate =
        Utils.checkBusinessSegment(BusinessSegment.corporate);
    final type = customer.type;

    // --- FI: Below Investment Grade (mandatory as per matrix) ---
    if (isFI && type == CustomerType.belowInvestmentGradeBanks) {
      return const [
        RemarksTabs.businessExperience,
        RemarksTabs.background,
        RemarksTabs.ownership,
        RemarksTabs.analysisCapital,
        RemarksTabs.analysisAssets,
        RemarksTabs.analysisManagement,
        RemarksTabs.analysisEarnings,
        RemarksTabs.analysisLiquidity,
        RemarksTabs.analysisOtherComments,
        RemarksTabs.otherComments,
        // Note: Bank Overview & Financial Highlights are visible for FI,
        // but NOT mandatory for Below IG.
      ];
    }

    // --- FI: Investment Grade (mandatory as per matrix) ---
    if (isFI && type == CustomerType.investmentGradeBanks) {
      return const [
        RemarksTabs.businessExperience,
        RemarksTabs.bankOverview,
        RemarksTabs.financialHighlights,
        // Note: Background / Ownership / Analysis-* visible for FI,
        // but NOT mandatory for IG.
      ];
    }

    // --- Corporate (restore your original mandatory set) ---
    // IMPORTANT: If Country uses the same segment classification as Corporate,
    // exclude Country explicitly using customer.type != country
    if (isCorporate &&
        type == CustomerType.corporate &&
        type != CustomerType.country &&
        type != CustomerType.belowInvestmentGradeBanks &&
        type != CustomerType.investmentGradeBanks) {
      return const [
        // RemarksTabs.requestSummary,
        // RemarksTabs.relationshipHistory,
        // RemarksTabs.businessRisk,
        // RemarksTabs.industryRisk,
        // RemarksTabs.financialRatiosAndAnalysis,
        // RemarksTabs.security,
        // RemarksTabs.ownershipStructure,
        // RemarksTabs.managementRisk,
        // RemarksTabs.facilityJustification,
        // RemarksTabs.covenants,
        // RemarksTabs.conditions,
        // If you decide to make Guarantor Financials mandatory in Corporate
        // later, uncomment this:
        // RemarksTabs.guarantorFinancials,
        // RemarksTabs.keyRisksAndMitigants,
        // RemarksTabs.otherFacilityRelatedAnalysis,
        // RemarksTabs.existingAndProposedCollateral,
        // RemarksTabs.settlementLimits,
        //RemarksTabs.feeStructure,
      ];
    }

    // --- Country (and any others not covered) ---
    // As per your matrix, Country has NO mandatory FI tabs. Keep empty.
    return const [];
  }

  /// Formats a number using the configured locale pattern.
  static String numberFormat(int? amount) {
    final formatter = NumberFormat.decimalPattern("en_IN");
    final String formatted = formatter.format(amount);
    return formatted;
  }

  /// Input: List<> with fields `groupId` and `rimId` (or `rimNo`)
  /// Output pattern:
  /// - Different groups:   groupA_rimX-groupB_rimY-groupC_rimZ  (joined by `_`)
  /// - Same group merged:  groupA_rim1-rim2   (still groups joined by `_`)
  /// Final: <>.zip
  ///
  /// Notes:
  /// - Skips items where groupId or rim is null/empty.
  /// - Trims whitespace.
  /// - If your rim field is named `rimNo`, set [rimFieldIsNo] = true.

  static String buildGroupedZipName(
    List<dynamic> selectedDocs, {
    bool rimFieldIsNo = false,
    bool removeSpacesInRim = true,
  }) {
    if (selectedDocs.isEmpty) {
      return "docs.zip";
    }

    // Map: groupId -> ordered set of rimIds (deduped, insertion order
    // preserved)
    final Map<String, LinkedHashSet<String>> grouped = {};

    for (final doc in selectedDocs) {
      final String groupId = (doc.groupId?.toString() ?? "").trim();
      var rim = (rimFieldIsNo ? doc.rimNo : doc.rimId)?.toString() ?? "";
      rim = rim.trim();

      if (removeSpacesInRim) {
        rim = rim.replaceAll(" ", "");
      }

      // Skip only if rim is empty; allow blank groupId
      if (rim.isEmpty) {
        continue;
      }

      grouped.putIfAbsent(groupId, LinkedHashSet<String>.new).add(rim);
    }

    if (grouped.isEmpty) {
      return "docs.zip";
    }

    // Build blocks: "groupId-rim1_rim2" if groupId present, otherwise
    // "rim1_rim2"
    final blocks = <String>[];
    grouped.forEach((groupId, rimsSet) {
      final List<String> rims =
          rimsSet.toList(); // preserves insertion order, removes duplicates
      if (groupId.isNotEmpty && groupId != "null" && groupId != "0") {
        blocks.add('${groupId}_${rims.join('-')}');
      } else {
        // Blank groupId -> return only rim numbers
        blocks.add(rims.join("-"));
      }
    });

    // Join blocks with '-', then append .zip; sanitize commas
    final name = '${blocks.join('_')}.zip'.replaceAll(",", "-");

    return name.isNotEmpty ? name : "docs.zip";
  }

  /// Groups by (documentType, fileName) and merges companyRim values into
  /// a comma-separated unique string. Keeps the first record per group for
  /// non-key fields.
  ///
  /// NOTE: This version mutates the first Document of each group by setting
  /// companyRim.
  static List<Document> mergeDocuments(List<Document> docs) {
    if (docs.isEmpty) {
      return <Document>[];
    }

    final Map<String, List<Document>> groups = {};

    // Group by normalized (documentType + fileName)
    for (final d in docs) {
      final int? type = d.documentType?.id;
      final String file = (d.files?.first.name ?? "").trim();
      final key = "$type|$file";
      groups.putIfAbsent(key, () => <Document>[]).add(d);
    }

    final List<Document> result = [];

    for (final entry in groups.entries) {
      final items = entry.value;

      // Unique companyRim values (trimmed, non-empty)
      final rims = items
          .map((d) => d.companyRim?.trim())
          .where((s) => s != null && s.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList()
        ..sort(); // simple alphabetical; switch to numeric if needed

      final merged = rims.join(",");

      // Use first document and set merged rims
      final base = items.first
        ..companyRim = merged // requires a mutable field
        ..documentType = items.first.documentType
        ..fileName = (items.first.fileName ?? "").trim();

      result.add(base);
    }

    return result;
  }

  /// Finds a reference by identifier.
  static Reference? findReferenceById(List<Reference> list, Object? jsonField) {
    // Accept: null, {"id": x}, x (int), "x" (string)
    if (jsonField == null) {
      return null;
    }

    int? id;
    if (jsonField is Map) {
      final rawId = jsonField["id"];
      if (rawId == null) {
        return null;
      }
      id = (rawId is num) ? rawId.toInt() : int.tryParse(rawId.toString());
    } else {
      // jsonField is a primitive (int, String, etc.)
      id = (jsonField is num)
          ? jsonField.toInt()
          : int.tryParse(jsonField.toString());
    }

    if (id == null) {
      return null;
    }

    // Use firstWhere with orElse returning null (manual since standard
    // firstWhere needs non-null)
    for (final e in list) {
      if (e.id == id) {
        return e;
      }
    }
    return null;
  }

  /// Returns `true` when a credit decision has been made on the application
  /// or the application has entered the post-approval lifecycle.
  ///
  /// Covers all statuses from the point of credit decision onwards:
  ///
  ///   Credit decision:
  ///   • Approved
  ///   • Declined
  ///   • Cancelled / Withdrawn
  ///   • Terminated
  ///
  ///   Post-approval lifecycle (FOL → CCU):
  ///   • Pending FOL Issuance
  ///   • FOL Issued, Pending Sign-Off
  ///   • FOL Sign-Off Completed, Pending Fit-to-Lend
  ///   • Fit-to-Lend Completed, Pending Limit Release
  ///   • Pending Limit Release
  ///   • FOL Not Required
  ///   • Completed
  ///
  /// Use this to gate any screen that should be read-only once a credit
  /// decision has been made.
  static bool isApprovedApplication() {
    return Utils.checkRequestStatuses([
      // Credit decision statuses
      RequestStatus.approved,
      RequestStatus.declined,
      RequestStatus.requestWithdrawnCancelled,
      RequestStatus.terminated,
      // Post-approval FOL / CCU lifecycle
      RequestStatus.pendingFolIssuance,
      RequestStatus.folIssuedPendingSignOff,
      RequestStatus.folSignOffCompletedPendingFitToLend,
      RequestStatus.fitToLendCompletedPendingLimitRelease,
      RequestStatus.pendingLimitRelease,
      RequestStatus.folNotRequired,
      RequestStatus.completed,
    ]);
  }

  /// Returns `true` when the application is visible to the Documentation team,
  /// i.e., within the documentation queue lifecycle phase.
  ///
  /// Statuses:
  ///   • Pending FOL Issuance
  ///   • FOL Issued, Pending Sign-Off
  ///   • FOL Sign-Off Completed, Pending Fit-to-Lend
  ///   • Fit-to-Lend Completed, Pending Limit Release
  ///   • Pending Limit Release
  ///   • FOL Not Required
  ///   • Completed
  ///
  /// Use this as the **visibility guard** for documentation screens.
  static bool inDocumentationQueue() {
    return Utils.checkRequestStatuses([
      RequestStatus.pendingFolIssuance,
      RequestStatus.folIssuedPendingSignOff,
      RequestStatus.folSignOffCompletedPendingFitToLend,
      RequestStatus.fitToLendCompletedPendingLimitRelease,
      RequestStatus.pendingLimitRelease,
      RequestStatus.folNotRequired,
      RequestStatus.completed,
    ]);
  }

  /// Returns `true` when the application is visible to the Credit Control team,
  /// i.e., within the credit control queue lifecycle phase.
  ///
  /// Statuses:
  ///   • Fit-to-Lend Completed, Pending Limit Release
  ///   • Pending Limit Release
  ///   • FOL Not Required
  ///   • Completed
  ///
  /// Use this as the **visibility guard** for CCU screens.
  static bool inCreditControlQueue() {
    return Utils.checkRequestStatuses([
      RequestStatus.fitToLendCompletedPendingLimitRelease,
      RequestStatus.completed,
      RequestStatus.pendingLimitRelease,
      RequestStatus.folNotRequired,
    ]);
  }

  /// Generates a random integer with a configurable digit length.
  static int randomDigits({int minDigits = 3, int maxDigits = 6}) {
    final rand = Random();
    final length = minDigits + rand.nextInt(maxDigits - minDigits + 1);

    final min = pow(10, length - 1).toInt();
    final max = pow(10, length).toInt() - 1;

    return min + rand.nextInt(max - min + 1);
  }

  /// Shortens a file name while preserving the ending characters.
  static String shortenFileName(String fileName) {
    if (fileName.length <= 13) {
      return fileName; // 3 + 10 = 13, no need to shorten
    }
    // Truncate: "XYZ...last10chars"
    final String tail = fileName.substring(fileName.length - 10);
    return "${fileName.substring(0, 3)}...$tail";
  }

  /// Returns a record of (userId, roleName) for the person the current
  /// application is assigned to, only when that person is NOT the currently
  /// logged-in user.
  ///
  /// Returns `null` if:
  ///   - Application details or lifecycle are unavailable.
  ///   - `enabledForView` is not explicitly `true`.
  ///   - The task IS assigned to the current user.
  ///   - The `assignedTo` user ID is empty.
  static ({String userId, String roleName})? getAssignedUserIfNotCurrentUser() {
    // Guard: details or lifecycle unavailable.
    final ApplicationDetails? appDetails = Globals.applicationDetails;
    if (appDetails == null) {
      return null;
    }

    final ApplicationLifeCycle? lifeCycle = appDetails.applicationLifeCycle;
    if (lifeCycle == null) {
      return null;
    }

    // Resolve identifiers.
    final String assignedToUserId = (lifeCycle.assignedTo ?? "").trim();
    final int assignedToRole = lifeCycle.assignedToRole ?? 0;

    final String currentUserBpmRole =
        (Globals.user?.currentRole?.bpmRole ?? "").trim();
    final String currentUserId = Globals.user?.id ?? "0";

    // Step a: Resolve the current user's roleId from the bpmRole string.
    int currentUserRoleId = 0;
    for (final Map<String, int> roleMap in Globals.superBpmRolesId) {
      if (roleMap.containsKey(currentUserBpmRole) &&
          roleMap[currentUserBpmRole] != 0) {
        currentUserRoleId = roleMap[currentUserBpmRole]!;
        break;
      }
    }

    // Step b: Check ownership — task assigned to current user?
    final bool isAssignedToCurrentUser =
        (assignedToRole == currentUserRoleId) &&
            (assignedToUserId == currentUserId);

    if (isAssignedToCurrentUser || assignedToUserId.isEmpty) {
      return null;
    }

    // Step c: Reverse-lookup the role name (bpmRole string) for assignedToRole.
    // Globals.superBpmRolesId is List<Map<String, int>>; key = bpmRole, value =
    // roleId.
    String assignedRoleName = "";
    for (final Map<String, int> roleMap in Globals.superBpmRolesId) {
      for (final MapEntry<String, int> entry in roleMap.entries) {
        if (entry.value == assignedToRole && entry.value != 0) {
          assignedRoleName = entry.key;
          break;
        }
      }
      if (assignedRoleName.isNotEmpty) {
        break;
      }
    }

    return (userId: assignedToUserId, roleName: assignedRoleName);
  }

  /// Returns a valid RIM number string or an empty string.
  static String getValidRimNo(int? rimNo) {
    if (rimNo != null && rimNo != 0 && rimNo != -1) {
      return rimNo.toString();
    }
    return "";
  }
}
