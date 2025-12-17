import 'package:easy_localization/easy_localization.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/models/request/customer.dart';
import 'package:wcas_frontend/models/request/request.dart';

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
  boardOfDirectorsProxy,
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
  riskRating
}

enum EntityIdentifier {
  requestApplicationDetailed,
  security,
  approval,
  covenantsSummary,
  conditionsSummary,
  requestForFOL,
  requestForClosure,
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
  terminateWithdraw
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
}

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

enum DigitaleFileFields { uploadDocument }
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
};

final Map<SummaryType, String> summaryTypeRequestMap = {
  SummaryType.me: "pendingWithMe",
  SummaryType.business: "pendingWithBusiness",
  SummaryType.credit: "pendingWithCredit",
  SummaryType.documentation: "pendingWithDocumentation",
  SummaryType.team: "pendingWithTeam",
  SummaryType.pool: "pendingWithPool",
  SummaryType.approvingauthority: "pendingWithApprovingAuthority",
  SummaryType.creditcontrol: "pendingWithCreditControl",
  SummaryType.requests: "requestToRecommend",
  SummaryType.documentationrequest: "returnedToDocumentation",
  SummaryType.relationshipOfficer: "returnedToRO",
  SummaryType.relationshipManager: "returnedToRM",
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
  BarGraphHelper.facilityCancelation:
      "dashboard.home.barGraph.facilityCancelation".tr(),
  BarGraphHelper.isolatedMemo: "dashboard.home.barGraph.isolatedMemo".tr(),
  BarGraphHelper.cancellation: "dashboard.home.barGraph.cancellation".tr(),
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
  facilityCancelation,
  isolatedMemo,
  cancellation,
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
  relationshipOfficer,
  relationshipManager,
  creditAnalyst,
  na,
  unitHead
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
        return 'YES';
      case ExclusionStatus.included:
        return 'NO';
      case ExclusionStatus.unknown:
        return 'NA';
    }
  }

  static ExclusionStatus fromApi(String? s) {
    switch (s?.toUpperCase()) {
      case 'YES':
        return ExclusionStatus.excluded;
      case 'NO':
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
  securityType,
  securityNumber,
  accountNumber,
  documentType
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

  static bool checkRequestType(RequestType type) {
    return Globals.request?.requestType?.id ==
        ServerConstants.requestTypeId[type];
  }

  static bool checkApplicationType(ApplicationType type) {
    return Globals.request?.applicationType?.id ==
        ServerConstants.applicationTypeId[type];
  }

  static bool checkRequestStatus(RequestStatus status) {
    return Globals.request?.requestStatus?.id ==
        ServerConstants.requestStatusId[status];
  }

  static bool isGroupApplication() {
    return Globals.request?.groupId != null && Globals.request?.groupId != 0;
  }

  static bool isGroupOwnerApplication() {
    return Globals.request?.groupOwner != null &&
        Globals.request?.groupOwner != 0;
  }

//closed and dashboard app reference click
  static void setRequest(Request request) {
    Globals.request = request;
    // Globals.request?.customers = [
    //   Customer(
    //       customerName: request.customerName,
    //       id: request.customerRimNo.toString(),
    //       customerRimNo: request.customerRimNo),
    //   Customer(customerName: "John", id: "25", customerRimNo: 1001),
    //   Customer(
    //       customerName: "Sara country",
    //       id: "50",
    //       customerRimNo: 1001,
    //       type: CustomerType.country),
    //   Customer(
    //       customerName: "Dale below ig",
    //       id: "150",
    //       customerRimNo: 1001,
    //       type: CustomerType.belowInvestmentGradeBanks),
    //   Customer(
    //       customerRimNo: 1001,
    //       id: "151",
    //       customerName: 'John Doe ig',
    //       type: CustomerType.investmentGradeBanks),
    //   Customer(customerRimNo: 25, id: "152", customerName: 'John Doe'),
    //   Customer(customerRimNo: 51, customerName: 'Jane Smith'),
    //   Customer(customerRimNo: 52, customerName: 'Alice Johnson'),
    //   Customer(customerRimNo: 53, customerName: 'Bob Williams'),
    //   Customer(customerRimNo: 54, customerName: 'Carlos Martinez'),
    //   Customer(customerRimNo: 55, customerName: 'Emily Davis'),
    //   Customer(customerRimNo: 56, customerName: 'David Lee'),
    //   Customer(customerRimNo: 57, customerName: 'Fatima Noor'),
    //   Customer(customerRimNo: 58, customerName: 'George Kim'),
    //   Customer(customerRimNo: 59, customerName: 'George '),
    // ];
  }

  static DocumentType? getDocumentTypeById(int id) {
    return ServerConstants.documentTypeId.entries
        .firstWhere(
          (entry) => entry.value == id,
          orElse: () => const MapEntry(DocumentType.other, -1),
        )
        .key;
  }

  /// Returns which tabs should display asterisks based on business segment and customer type
  static List<RemarksTabs> getMandatoryRemarksTabs(Customer customer) {
    if (Utils.checkBusinessSegment(BusinessSegment.financialInstitution) &&
        customer.type == CustomerType.belowInvestmentGradeBanks) {
      return [
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
      ];
    } else if (Utils.checkBusinessSegment(
            BusinessSegment.financialInstitution) &&
        customer.type == CustomerType.investmentGradeBanks) {
      return [
        RemarksTabs.businessExperience,
        RemarksTabs.bankOverview,
        RemarksTabs.financialHighlights,
      ];
    } else if (Utils.checkBusinessSegment(BusinessSegment.corporate)) {
      return [
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
        RemarksTabs.guarantorFinancials,
        RemarksTabs.keyRisksAndMitigants,
        RemarksTabs.otherFacilityRelatedAnalysis,
        RemarksTabs.existingAndProposedCollateral,
        RemarksTabs.settlementLimits,
        RemarksTabs.feeStructure,
      ];
    } else {
      return [];
    }
  }

  static String numberFormat(int? amount) {
    final formatter = NumberFormat.decimalPattern('en_IN');
    String formatted = formatter.format(amount);
    return formatted;
  }
}
