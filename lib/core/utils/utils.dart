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

enum LoadingStatus { loading, loaded, error, empty }

enum MenuMode { enabled, disabled, hidden }

enum PageMode { view, edit, na }

enum TypeMode { create, edit }

enum UserRole {
  admin,
  relationshipOfficer,
  relationshipManager,
  teamLeaderBusiness,
  commercialAreaManager,
  relationshipManagerBussiness,
  segmentHeadBusiness,
  creditCordinator,
  creditAnalyst,
  creditCommitteeProxy,
  boardDirectorProxy,
  teamLeaderCreditLevelD1,
  segmentHeadCreditLevelD,
  segmentHeadLevelC,
  segmentHeadLevelB1,
  segmentHeadLevelB,
  creditCommitteeProxyApprover,
  boardDirectorProxyApproval,
  documentationChecker,
  documentationMaker,
  ccuMaker,
  ccuChecker,
  businessAdmin,
  icsAdmin,
  inquiryUser,
  financialPoolCoordinator,
  financialPoolMaker,
  financialPoolChecker,
  creditCommittee,
  boardOfDirectors,
  limitInputTeam,
  legalTeam,
  legalTeamCoordinator,
  businessUnitHead,
  na,
}

enum BusinessSegment {
  corporate,
  financialInstitution,
  financialInstitutionCF,
  business,
  baf,
  personal,
  na
}

enum RequestType { fullCA, isolated }

enum ApplicationType {
  newToBank,
  annualReview,
  interimAmendment,
  reconsideration,
  markForward,
  riskRatingChange,
  documentationDeferral,
  cancellation,
  oneOffLimit,
  isolatedExcessType,
  isolatedProjectAllocation,
  isolatedOther,
  isolatedAllocation
}

enum CustomerType {
  corporate, // For default corporate flow its used.
  country,
  belowInvestmentGradeBanks,
  investmentGradeBanks,
  requestForFOL
}

enum CommentsType {
  requestApplicationDetailed,
  security,
  approval,
  covenantsSummary,
  conditionsSummary,
  requestForFOL,
  requestForClosure,
  requestForLimitRelease,
  queriesResponses,
  presentRequest,
  securityPerfection,
  facilitiesWithCbd,
  facilitiesWithOtherBank,
  centralBankRiskBureauData,
  accountStats,
  bussinessVolume,
  incomeSummary,
  shareWallet,
  remarks,
  sicCodeReview,
  strategyComments,
  terminateWithdraw,
  riskRating,
  internalRiskRatingFi,
  externalRiskRatingFi,
  contract,
  relationshipProfitabilityDetailed,
  rarocCommonComments,
  groupCorpoarteStruture,
  ccsys,
  creditAppraisal,
  creditBrief,
  groupSummary,
  groupOverview,
  groupManagement,
  successionRisk,
  relationshipStrategy,
  managementComment,
  appendix,
  countrySummary,
  recommendCurrentApproval,
  folAdditionalComment,
  previousCreditApproval
}

enum CommentsCategory {
  requestApplicationDetailed,
  security,
  approval,
  covenantsSummary,
  conditionsSummary,
  requestForFOL,
  requestForClosure,
  requestForLimitRelease,
  queriesResponses,
  presentRequest,
  securityPerfection,
  facilitiesWithCbd,
  facilitiesWithOtherBank,
  centralBankRiskBureauData,
  accountStats,
  bussinessVolume,
  incomeSummary,
  shareWallet,
  remarks,
  sicCodeReview,
  strategyComments,
  terminateWithdraw,
  riskRating,
  contract,
  relationshipProfitabilityDetailed,
  rarocCommonComments,
  groupCorpoarteStruture,
  ccsys,
  creditAppraisal,
  creditBrief,
  groupSummary,
  groupOverview,
  groupManagement,
  successionRisk,
  relationshipStrategy,
  managementComment,
  appendix
}

enum EntityIdentifier {
  requestApplicationDetailed,
  security,
  approval,
  covenantsSummary,
  conditionsSummary,
  requestForFOL,
  requestForClosure,
  requestForLimitRelease,
  queriesResponses,
  presentRequest,
  securityPerfection,
  facilitiesWithCbd,
  facilitiesWithOtherBank,
  centralBankRiskBureauData,
  accountStats,
  bussinessVolume,
  incomeSummary,
  shareWallet,
  remarks,
  sicCodeReview,
  strategyComments,
  terminateWithdraw,
  contract,
  relationshipProfitabilityDetailed,
  rarocCommonComments,
  groupCorpoarteStruture,
  ccsys,
  creditAssesment,
  groupSummary,
  managementComment,
  appendix,
  recommendCurrentApproval,
  countrySummary,
  previousCreditApproval
}

enum CertificationType { rm, documentation, limitInput }

enum CovenantType { information, nonFinancial, financial, none }

enum CovenantSubType {
  financialStatements,
  projectProgressReport,
  debtorsAndStockAgeing,
  personalNetWorthIncomeStatement,
  operatingBudget,
  other,
  none
}

enum ApprovalFields {
  amendRAROC,
  amendFacilities,
  amendSecurities,
  amendConditions,
  amendRiskRating,
  approve,
  approvalDelegation,
  decline,
  reasonForDecline,
  generatePack,
  closeApplication,
  noReturn,
  recommend,
  returns,
  previewApplication,
  save,
  saveAndContinue,
  amendCovenants,
  amendFacilitySecurityLinkage,
  approveonbehalf,
  initiateFinalFOL,
  documentationSubmitted,
  sendToDocumentation,
  returnToDocumentationMaker,
  initiateFitToLend,
  stage,
  sendToCCU,
  sendToRORM,
  draftFolGenerated,
  finalFOLGenerated,
  documentationCompleted,
  sendToDocumentationChecker,
  sendToDocumentationMaker,
  rightFirstTime,
  sendtoCCUMaker,
  sendtoCCUChecker,
  returntoCCUMaker,
  acceptCloseApplication,
}

enum ApprovalCategory {
  creditAppraisal,
  creditBreif,
  groupOverview,
  groupManagement,
  groupRisk,
  groupStrategy,
  creditCommittee,
  ccoComment,
  ceoComment,
  bcicComment,
  recommendComment,
  request,
  rational,
  summaryOfLastDev,
  bankingSector,
  fiRecommendation,
  recommendCurrentApproval,
  previousCreditApproval
}

enum RequestStatus {
  initiated,
  pendingForApproval,
  approved,
  declined,
  requestWithdrawnCancelled,
  pendingFolIssuance,
  terminated,
  completed,
  folIssuedPendingSignOff,
  folSignOffCompletedPendingFitToLend,
  fitToLendCompletedPendingLimitRelease,
  pendingLimitRelease,
  folNotRequired,
  na
}

enum UserAction {
  completed,
  saveNext,
  draftSave,
  approveOnBehalfOf,
  assignToCreditApprovalTeam,
  returned,
  approved,
  declined,
  recommended,
  acceptCloseApplication,
  selfAssignedCA,
  returnToPool,
  assignToAdmin,
  assignFromBusinessAdmin,
}

enum FOLTypeAction {
  documentationSubmitted,
  documentationCompleted,
  assignedToDcDm,
  initiateFinalFOL,
  autoAssignedToDocPool,
  draftFolGenerated,
  finalFolGenerated,
  selfAssignedCcuMaker,
  sendToCCUChecker,
  sendToCCUMaker,
  autoAssigndToCcuPool,
  sendToDocumentation,
  sendToDocumentationMaker,
  sendToRoRm,
  sendToDocumentationChecker,
  sendToCCU,
  initiateFitToLend,
  returnFromDocCCU,
  initiatedDraftFOL,
  returnForAmendment,
  returnForAmendmentCMO,
  initiateLimitLoading,
  returnToUser,
  sentToLimitLoading,
  executedDocsUnderReview,
  returnToDM,
  folNotRequired,
}

enum ApplicationSubType { riskRating, cashMargin }

enum DocumentType {
  constitutionalDocument,
  creditLensDocument,
  financialStatements,
  creditApplication,
  externalOpinions,
  facilityDocuments,
  valuationReports,
  other,
}

enum DigitaleFileFields { uploadDocument, showApprovalDecision }

enum FileAttachmentFields { downloadDocuments, showApprovalDecision }
//dashboard

enum VisibleGraphType { pie, bar }

enum DashboardAgeingType {
  zeroToSevenDays,
  eightToFifteenDays,
  sixteenToThirtyDays,
  aboveThirtyDays
}

Map<DashboardAgeingType, String> dashboardFilterMap = {
  DashboardAgeingType.zeroToSevenDays: "0_7_days",
  DashboardAgeingType.eightToFifteenDays: "8_15_days",
  DashboardAgeingType.sixteenToThirtyDays: "16_30_days",
  DashboardAgeingType.aboveThirtyDays: "above_30_days",
};

Map<DashboardAgeingType, String> dashboardFilterMapToUI = {
  DashboardAgeingType.zeroToSevenDays: "0-7 Days",
  DashboardAgeingType.eightToFifteenDays: "8-15 Days",
  DashboardAgeingType.sixteenToThirtyDays: "16-30 Days",
  DashboardAgeingType.aboveThirtyDays: "above-30 Days",
};

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
  SummaryType.requests:
      "dashboard.home.summary.recommendedRequestRequests".tr(),
  SummaryType.documentationrequest:
      "dashboard.home.summary.returnedRequestDocumentation".tr(),
  SummaryType.ro: "dashboard.home.summary.returnedRequestRO".tr(),
  SummaryType.rm: "dashboard.home.summary.returnedRequestRM".tr(),
  SummaryType.cam: "dashboard.home.summary.returnedRequestCAM".tr(),
  SummaryType.tlb: "dashboard.home.summary.returnedRequestTLB".tr(),
  SummaryType.shb: "dashboard.home.summary.returnedRequestSHB".tr(),
  SummaryType.rmb: "dashboard.home.summary.returnedRequestRMB".tr(),
  SummaryType.unitHead: "dashboard.home.summary.returnedRequestUnitHead".tr(),
  SummaryType.creditCordinator:
      "dashboard.home.summary.returnedRequestCreditCordinator".tr(),
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
  SummaryType.requests: "requestToRecommend",
  SummaryType.documentationrequest: "returnedToDocumentation",
  SummaryType.ro: "returnedToRO",
  SummaryType.rm: "returnedToRM",
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

final Map<BarGraphHelper, String> barGraphEnumMap = {
  BarGraphHelper.newToBank: "dashboard.home.barGraph.newToBank".tr(),
  BarGraphHelper.annualReviewSameLevel:
      "dashboard.home.barGraph.annualReviewSameLevel".tr(),
  BarGraphHelper.annualReviewIncrease:
      "dashboard.home.barGraph.annualReviewIncrease".tr(),
  BarGraphHelper.annualReviewDecrease:
      "dashboard.home.barGraph.annualReviewDecrease".tr(),
  BarGraphHelper.interimReviewSameLevel:
      "dashboard.home.barGraph.interimReviewSameLevel".tr(),
  BarGraphHelper.interimReviewIncrease:
      "dashboard.home.barGraph.interimReviewIncrease".tr(),
  BarGraphHelper.interimReviewDecrease:
      "dashboard.home.barGraph.interimReviewDecrease".tr(),
  BarGraphHelper.reconsiderationSameLevel:
      "dashboard.home.barGraph.reconsiderationSameLevel".tr(),
  BarGraphHelper.reconsiderationIncrease:
      "dashboard.home.barGraph.reconsiderationIncrease".tr(),
  BarGraphHelper.reconsiderationDecrease:
      "dashboard.home.barGraph.reconsiderationDecrease".tr(),
  BarGraphHelper.facilityCancellation:
      "dashboard.home.barGraph.facilityCancelation".tr(),
  BarGraphHelper.isolatedMemo: "dashboard.home.barGraph.isolatedMemo".tr(),
};

enum BarGraphHelper {
  newToBank,
  annualReviewSameLevel,
  annualReviewIncrease,
  annualReviewDecrease,
  interimReviewSameLevel,
  interimReviewIncrease,
  interimReviewDecrease,
  reconsiderationSameLevel,
  reconsiderationIncrease,
  reconsiderationDecrease,
  facilityCancellation,
  isolatedMemo,
  na
}

enum SummaryType {
  me,
  business,
  credit,
  documentation,
  team,
  approvingauthority,
  creditcontrol,
  requests,
  pool,
  documentationrequest,
  ro,
  rm,
  ca,
  cam,
  tlb,
  shb,
  rmb,
  na,
  unitHead,
  creditCordinator,
  ccuMaker,
  tld1,
  shld,
  shlc,
  shlb1,
  shlb,
  ccProxy,
  ccProxyApprover,
  bdProxy,
  pendingWithRelationShipTeam,
  pendingWithBusinessTeam,
  ccood
}

enum SecurityType {
  assignmentOfInsurancess,
  notarisedCommercialMortgage,
  assignmentOfLeaseholdMusataha,
  personalGuarantee,
  assignmentOfReceivables,
  pledgeOfAccount,
  bankGuarantee,
  chargeOverCbdfsPortfolio,
  pledgeOfBonds,
  conditionalAssignmentOfSpa,
  pledgeOfCommodities,
  corporateGuarantee,
  pledgeOfInvestmentProducts,
  holdOnTitleDeeds,
  pledgeOfSharesBondsOfJointStockCompany,
  mortgageOfProperties,
  pledgeOfSharesOfALimitedLiabilityCompany,
  mortgageOfAircraft,
  pledgeOfMoveableAssetsRegisteredWithEircViaUaeMovablesAgreement,
  mortgageOfLeaseholdMusataha,
  pledgeOfPreciousMetals,
  mortgageOfVehicles,
  pledgeOfTd,
  mortgageOfVessel,
  securityCheque,
  mortgageWithFreeZoneAuthorities,
  pledgeOfPlantAndMachineryFixedAssets,
  promissoryNote,
  otherFinancialGuaranteeBorrowersCreditInsurance,
  lienOverSharesHeldByCbdFinancialServices,
  pledgeOfShares,
  authorityToDebitAccount,
  subordinationLetter,
  thirdPartyPostDatedChequesConsideredGood,
  postDatedCheque,
}

enum FacilityType {
  overdraftRealEstateProject, // Overdraft Real Estate/Project
  overdraftAgainstSharesBonds, // Overdraft against Shares/Bonds
  flexiOverdraft, // Flexi Overdraft
  // Overdraft against Progress Payment Certificate
  overdraftAgainstProgressPaymentCertificate,
  overdraftOnCbdFsPortfolio, // Overdraft on CBD FS Portfolio
  overdraftAgainstInvestmentProducts, // Overdraft against investment products
  loanAgainstTasdeer, // Loan against Tasdeer
  chequeDiscounting, // Cheque Discounting
  loanAgainstCollectionDocumentsInventoryFinance, // Loan against collection documents / Inventory Finance
  exportBillDiscounting, // Export Bill Discounting
  // Loan against invoice sales
  loanAgainstInvoiceSales,
  // Loan against
  // Progress Payment Certificate
  loanAgainstProgressPaymentCertificate,
  loanAgainstTrustReceipt, // Loan Against Trust Receipt
  loanAgainstAcceptanceDocument, // Loan against acceptance document
  loanAgainstInvoicePurchase, // Loan against invoice purchase
  termLoanCommercial, // Term Loan - Commercial
  realEstateLoan, // Real Estate Loan
  syndicationLoans, // Syndication Loans
  rentalLoan, // Rental Loan
  vehicleLoan, // Vehicle Loan
  loanForPurchaseOfListedBonds, // Loan for Purchase of Listed Bonds
  letterOfCreditOverseasTime, // Letter of Credit - Overseas Time
  letterOfCreditOverseasSight, // Letter of Credit - Overseas Sight
  letterOfCreditLocalSight, // Letter of Credit - Local Sight
  letterOfCreditLocalTime, // Letter of Credit - Local Time
  standbyLetterOfCredit, // Standby Letter of Credit
  avalisation, // Avalisation
  letterOfGuaranteeBidTender, // Letter of Guarantee - Bid/Tender
  letterOfGuaranteePerformance, // Letter of Guarantee - Performance
  // Letter of Guarantee -Advance Payment
  letterOfGuaranteeAdvancePayment,
  letterOfGuaranteeFinancial, // Letter of Guarantee - Financial
  // Letter of Guarantee - Retention and maintenance
  letterOfGuaranteeRetentionAndMaintenance,
  letterOfGuaranteeLabourGuarantee, // Letter of Guarantee -Labour Guarantee
  murabaha, // Murabaha
  tawarruq, // Tawarruq
  // Ijarah
  ijarah,
  // Forward Ijarah
  forwardIjarah,
  overdraftIslamic, // Overdraft Islamic

  letterOfCreditOverseasSightIslamic,
  letterOfCreditLocalSightIslamic, // Letter of Credit - Local Sight (Islamic)
  // Letter of Credit - Overseas Time (Islamic)
  letterOfCreditOverseasTimeIslamic,
  // Letter of Credit - Local Time (Islamic)
  letterOfCreditLocalTimeIslamic,
  // Standby Letter of Credit (Islamic)
  standbyLetterOfCreditIslamic,
  letterOfGuaranteeBidIslamic, // Letter of Guarantee Bid (Islamic)
  letterOfGuaranteeFinancialIslamic, // Letter of Guarantee Financial (Islamic)
  letterOfGuaranteeLabourIslamic, // Letter of Guarantee Labour (Islamic)
  // Letter of Guarantee Performance (Islamic)
  letterOfGuaranteePerformanceIslamic,
  // Letter of Guarantee - Advance Payment (Islamic)
  letterOfGuaranteeAdvancePaymentIslamic,
  // Letter of Guarantee - Retention and Maintenance (Islamic)
  letterOfGuaranteeRetentionAndMaintenanceIslamic,
  limitCaps, // Limit Caps
  overallPfeLimit, // Overall PFE Limit
  taharuqAgainstInvoice, // Taharuq Against Invoice
  vehicleLoanUptoProposedAmount, // Vehicle Loan upto Proposed Amount
  // Tawarruk against PPC
  tawarrukAgainstPpc,
  prsProfitRateSwaps, // PRS (profit rate swaps)
  // Letter of Guarantee
  // - All types
  letterOfGuaranteeAllTypes,
  letterOfCreditAllTypes, // Letter of Credit - All types
  letterOfCreditAllTypesIslamic, // Letter of Credit - All types (Islamic)
  letterOfGuaranteeAllTypesIslamic, // Letter of Guarantee - All types (Islamic)
  shortTermLoan, // Short Term Loan
  // Open Account TR - Advance Payment against Pro-forma Invoices
  openAccountTrAdvancePaymentAgainstProFormaInvoices,
  // Open Account TR - Advance Payment against copies of shipping documents
  openAccountTrAdvancePaymentAgainstCopiesOfShippingDocuments,
  // Open Account TR - Post Shipment / Post Delivery
  openAccountTrPostShipmentPostDelivery,
  // Open Account TR - Post Delivery Post Supplier Credit Period
  openAccountTrPostDeliveryPostSupplierCreditPeriod,
  // Moveable Assets
  moveableAssets,
  immoveableAssets, // Immoveable Assets
  // Factoring without recourses (Revolving)
  factoringWithoutRecoursesRevolving,
  corporateCreditCard, // Corporate Credit Card
  buyerLedSupplyChainFinancing, // Buyer Led Supply Chain Financing
  sellerLedSupplyChainFinancing, // Seller Led Supply Chain Financing
  financingExportCollectionDocuments, // Financing export Collection Documents
  tasdeerLtpPre, // Tasdeer (LTP) (Pre)
  tasdeerLtpPost, // Tasdeer (LTP) (Post)
  // Open Account TR - Advance Payment against Pro-forma Invoices
  // (Islamic) -> MUR1
  openAccountTrAdvancePaymentAgainstProFormaInvoicesIslamic,
  // Open Account TR - Advance Payment against copies of shipping
  // documents (Islamic) -> MUR2
  openAccountTrAdvancePaymentAgainstCopiesOfShippingDocumentsIslamic,
  // Open Account TR - Post Shipment / Post Delivery (Islamic) -> MUR3
  openAccountTrPostShipmentPostDeliveryIslamic,
  // Open Account TR - Post Delivery Post Supplier Credit Period
  // (Islamic) -> MUR4
  openAccountTrPostDeliveryPostSupplierCreditPeriodIslamic,
  notDisclosure, // Not Disclosure
}

extension CovenantTypeHelper on CovenantType {
  static CovenantType fromId(int? id) {
    return ServerConstants.covenantTypeId.entries
        .firstWhere(
          (e) => e.value == id,
          orElse: () => const MapEntry(CovenantType.none, 0),
        )
        .key;
  }

  int get id => ServerConstants.covenantTypeId[this]!;
}

extension CovenantSubTypeHelper on CovenantSubType {
  static CovenantSubType fromId(int? id) {
    return ServerConstants.covenantSubTypeId.entries
        .firstWhere(
          (e) => e.value == id,
          orElse: () => const MapEntry(CovenantSubType.none, 0),
        )
        .key;
  }

  int get id => ServerConstants.covenantSubTypeId[this]!;
}

enum ExclusionStatus { excluded, included, unknown }

extension ExclusionStatusX on ExclusionStatus {
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

enum FilterType {
  referenceNumber,
  referenceType,
  applicantRim,
  applicantName,
  applicationType,
  securityType,
  securityNumber,
  accountNumber,
  documentType,
  requestBy,
  requestType,
  requestStatus,
  businessSegment,
  receivedFrom
}

class Utils {
  static bool checkRole(UserRole role) {
    return Globals.user?.currentRole?.code ==
        ServerConstants.userRoleCode[role]; // Need to compare by id instead
  }

  static bool checkRoles(List<UserRole> roles) {
    return roles.contains(Globals.user?.currentRole?.userRole);
  }

  static bool checkBusinessSegment(BusinessSegment segment) {
    return Globals.request?.businessSegment?.id ==
        ServerConstants.businessSegmentId[segment];
  }

  static bool checkApplicationBusinessSegment(BusinessSegment segment) {
    return Globals.request?.appBusinessSegment ==
        ServerConstants.businessSegmentType[segment];
  }

  static bool checkRequestType(RequestType type) {
    return Globals.request?.requestType?.id ==
        ServerConstants.requestTypeId[type];
  }

  static bool checkApplicationType(ApplicationType type) {
    //For appTypeReferenceId is applicationType ID if data use custom
    //application type
    //TODO for now handle with server constant ID based applicationTypeIdCustom
    return (Globals.request?.appTypeReferenceId != null)
        ? Globals.request?.applicationType?.id ==
            ServerConstants.applicationTypeIdCustom[type]
        : Globals.request?.applicationType?.id ==
            ServerConstants.applicationTypeIdCustom[type];
  }

  static bool checkRequestStatus(RequestStatus status) {
    //return true;
    final int? currentId = Globals.applicationDetails?.status;
    return currentId == ServerConstants.requestStatusId[status];
  }

  static bool checkRequestStatuses(Iterable<RequestStatus> statuses) {
    final int? currentId = Globals.applicationDetails?.status;
    if (currentId == null) return false;
    return statuses.any(
      (status) => ServerConstants.requestStatusId[status] == currentId,
    );
  }

  static bool isGroupApplication() {
    return (Globals.request?.isRequestCreated ?? false)
        ? ((Globals.request?.borrowers ?? []).isNotEmpty)
            ? (Globals.request?.borrowers?.length ?? 0) > 1
            : Globals.request?.groupId != null && Globals.request?.groupId != 0
        : Globals.request?.groupId != null && Globals.request?.groupId != 0;
  }

  static bool isGroupOwnerApplication() {
    return Globals.request?.groupOwner != null &&
        Globals.request?.groupOwner != 0;
  }

//closed and dashboard app reference click
  static void setRequest(Request request) {
    Globals.request = request;
  }

  /// Sets the global [ApplicationDetails] and computes the access control flags
  /// exactly once, caching them for the entire application session.
  /// Used to avoid expensive logic re-evaluations on every screen build.
  static void setApplicationDetails(ApplicationDetails appDetails) {
    Globals.applicationDetails = appDetails;
    Globals.isAllReadOnly = checkIfAppReadOnly();
    Globals.isInitiated = Globals.checkIsInitiated();
  }

  /// Returns true if the currently loaded application is editable by the active
  /// user.
  /// Safely relies on the cached [Globals.isAllReadOnly] boolean.
  static bool canEditApplication() {
    return !Globals.isAllReadOnly;
  }

  /// Determines if the current application record should be strictly Read-Only.
  /// Returns [true] if the record is locked for the current user,
  /// and [false] if the current user has permission to edit it.
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

    // Step c: Validate if the task status means it is actively awaiting user
    // action.
    final bool isTaskActive =
        (currentTaskStatus == ServerConstants.lifeCycleStatusWaiting ||
            currentTaskStatus == ServerConstants.lifeCycleStatusAssigned);

    // If the task is active AND assigned to the current user, they are allowed
    // to edit (return false).
    // Otherwise, they are locked out and can only view it (return true).
    final bool canEdit = isAssignedToCurrentUser && isTaskActive;
    return !canEdit;
  }

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
    if (customer == null) return const [];

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
        RemarksTabs.requestSummary,
        RemarksTabs.relationshipHistory,
        RemarksTabs.businessRisk,
        RemarksTabs.industryRisk,
        RemarksTabs.financialRatiosAndAnalysis,
        RemarksTabs.security,
        RemarksTabs.ownershipStructure,
        RemarksTabs.managementRisk,
        RemarksTabs.facilityJustification,
        RemarksTabs.covenants,
        RemarksTabs.conditions,
        // If you decide to make Guarantor Financials mandatory in Corporate
        // later, uncomment this:
        RemarksTabs.guarantorFinancials,
        RemarksTabs.keyRisksAndMitigants,
        RemarksTabs.otherFacilityRelatedAnalysis,
        RemarksTabs.existingAndProposedCollateral,
        RemarksTabs.settlementLimits,
        RemarksTabs.feeStructure,
      ];
    }

    // --- Country (and any others not covered) ---
    // As per your matrix, Country has NO mandatory FI tabs. Keep empty.
    return const [];
  }

  static String numberFormat(int? amount) {
    final formatter = NumberFormat.decimalPattern("en_IN");
    final String formatted = formatter.format(amount);
    return formatted;
  }

  /// Input: List<DocSubTypeData> with fields `groupId` and `rimId` (or `rimNo`)
  /// Output pattern:
  /// - Different groups:   groupA_rimX-groupB_rimY-groupC_rimZ  (joined by `_`)
  /// - Same group merged:  groupA_rim1-rim2   (still groups joined by `_`)
  /// Final: <computed>.zip
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
    if (selectedDocs.isEmpty) return "docs.zip";

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
      if (rim.isEmpty) continue;

      grouped.putIfAbsent(groupId, LinkedHashSet<String>.new).add(rim);
    }

    if (grouped.isEmpty) return "docs.zip";

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
    if (docs.isEmpty) return <Document>[];

    final Map<String, List<Document>> groups = {};

    // Group by normalized (documentType + fileName)
    for (final d in docs) {
      final type = d.documentType;
      final file = (d.files?.first.name ?? "").trim();
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
      final base = items.first;
      base.companyRim = merged; // requires a mutable field

      // Normalize keys (optional, ensures trimmed)
      base.documentType = base.documentType;
      base.fileName = (base.fileName ?? "").trim();

      result.add(base);
    }

    return result;
  }

  static Reference? findReferenceById(List<Reference> list, dynamic jsonField) {
    // Accept: null, {"id": x}, x (int), "x" (string)
    if (jsonField == null) return null;

    int? id;
    if (jsonField is Map) {
      final rawId = jsonField["id"];
      if (rawId == null) return null;
      id = (rawId is num) ? rawId.toInt() : int.tryParse(rawId.toString());
    } else {
      // jsonField is a primitive (int, String, etc.)
      id = (jsonField is num)
          ? jsonField.toInt()
          : int.tryParse(jsonField.toString());
    }

    if (id == null) return null;

    // Use firstWhere with orElse returning null (manual since standard
    // firstWhere needs non-null)
    for (final e in list) {
      if (e.id == id) return e;
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

  static int randomDigits({int minDigits = 3, int maxDigits = 6}) {
    final rand = Random();
    final length = minDigits + rand.nextInt(maxDigits - minDigits + 1);

    final min = pow(10, length - 1).toInt();
    final max = pow(10, length).toInt() - 1;

    return min + rand.nextInt(max - min + 1);
  }

  static String shortenFileName(String fileName) {
    if (fileName.length <= 13) {
      return fileName; // 3 + 10 = 13, no need to shorten
    }
    // Truncate: "XYZ...last10chars"
    final String tail = fileName.substring(fileName.length - 10);
    return "${fileName.substring(0, 3)}...$tail";
  }
}
