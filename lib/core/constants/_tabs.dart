part of "constants.dart";

enum BusinessVolumeAccountStatsTabs { businessVolume, accountStats }

enum ApplicationFilterType {
  applicationOverdue,
  dueForReview,
  recentApplication,
  applicationSegment,
  closedRequest,
  ccsys
}

enum RevenueCrossSellTabs {
  relationshipUtilization,
  relationshipProfitabilitySummary,
  relationshipProfitabilityDetailed,
  incomeSummary,
  strategiesAndComments
}

enum RecommendationTabs {
  proposedFacilities,
  groupPosition,
  limitCaps,
  guarantorsExposure,
  queriesAndResponses,
  previousCreditApproval,
  recommendationCurrentApproval,
  comments,
}

enum GroupSummaryTabs {
  ownershipCorporateStructure,
  groupManagementTeam,
  successsionkeyManRisk,
  relationshipFutureStrategy
}

enum CountrySummaryTabs {
  request,
  rational,
  summaryOfLatestDev,
  bankingSector,
  fiRecommend
}

enum RemarksTabs {
  requestSummary,
  relationshipHistory,
  businessRisk,
  industryRisk,
  financialRatiosAndAnalysis,
  security,
  ownershipStructure,
  managementRisk,
  facilityJustification,
  covenants,
  conditions,
  guarantorFinancials,
  keyRisksAndMitigants,
  otherFacilityRelatedAnalysis,
  existingAndProposedCollateral,
  settlementLimits,
  cashflowProjectionAnalysis,
  feeStructure,
  businessExperience,
  background,
  ownership,
  analysisCapital,
  analysisAssets,
  analysisManagement,
  analysisEarnings,
  analysisLiquidity,
  analysisOtherComments,
  otherComments,
  bankOverview,
  financialHighlights,
}

class TabConstants {
  //Profitabilit and Account Conduct

  static const Map<BusinessVolumeAccountStatsTabs, String>
      businessVolumeAccountStatsRoutes = {
    BusinessVolumeAccountStatsTabs.businessVolume: Routes.businessVolume,
    BusinessVolumeAccountStatsTabs.accountStats: Routes.accountStats,
  };

  static const Map<BusinessVolumeAccountStatsTabs, String>
      businessVolumeAccountStatsTitles = {
    BusinessVolumeAccountStatsTabs.businessVolume:
        "profitabilityAccountConduct.businessVolume.tabTitle",
    BusinessVolumeAccountStatsTabs.accountStats:
        "profitabilityAccountConduct.accountStats.tabTitle",
  };

  static const Map<RevenueCrossSellTabs, String> revenueCrossSellRoutes = {
    RevenueCrossSellTabs.relationshipUtilization:
        Routes.relationshipUtilization,
    RevenueCrossSellTabs.relationshipProfitabilitySummary:
        Routes.relationshipProfitabilitySummary,
    RevenueCrossSellTabs.relationshipProfitabilityDetailed:
        Routes.relationshipProfitabilityDetailed,
    RevenueCrossSellTabs.incomeSummary: Routes.incomeSummary,
    RevenueCrossSellTabs.strategiesAndComments: Routes.strategiesAndComments,
  };

  static const Map<RevenueCrossSellTabs, String> revenueCrossSellTitles = {
    RevenueCrossSellTabs.relationshipUtilization:
        "profitabilityAccountConduct.relationshipUtilisation.tabTitle",
    RevenueCrossSellTabs.relationshipProfitabilitySummary:
        "profitabilityAccountConduct.relationshipProfitabilitySummary.tabTitle",
    RevenueCrossSellTabs.relationshipProfitabilityDetailed:
        "profitabilityAccountConduct."
            "relationshipProfitabilityDetailed.tabTitle",
    RevenueCrossSellTabs.incomeSummary:
        "profitabilityAccountConduct.incomeSummary.tabTitle",
    RevenueCrossSellTabs.strategiesAndComments:
        "profitabilityAccountConduct.strategiesComments.tabTitle",
  };

  static const Map<RecommendationTabs, String> recommendationRoutes = {
    RecommendationTabs.proposedFacilities: Routes.proposedFacilities,
    RecommendationTabs.groupPosition: Routes.groupPosition,
    RecommendationTabs.limitCaps: Routes.limitCaps,
    RecommendationTabs.guarantorsExposure: Routes.guarantorsExposure,
    RecommendationTabs.queriesAndResponses: Routes.queriesAndResponses,
    RecommendationTabs.previousCreditApproval: Routes.previousCreditApproval,
    RecommendationTabs.recommendationCurrentApproval:
        Routes.recommendationCurrentApproval,
    RecommendationTabs.comments: Routes.comments,
  };

  static const Map<RecommendationTabs, String> recommendationTitles = {
    RecommendationTabs.proposedFacilities:
        "approval.proposedFacilities.tabTitle",
    RecommendationTabs.groupPosition: "approval.groupPosition.tabTitle",
    RecommendationTabs.limitCaps: "approval.limitCaps.tabTitle",
    RecommendationTabs.guarantorsExposure:
        "approval.guarantorsExposure.tabTitle",
    RecommendationTabs.queriesAndResponses:
        "approval.queriesResponses.tabTitle",
    RecommendationTabs.comments: "approval.comments.tabTitle",
    RecommendationTabs.recommendationCurrentApproval:
        "approval.recommendationCurrentApproval.tabTitle",
    RecommendationTabs.previousCreditApproval:
        "approval.previousCreditApproval.tabTitle",
  };

  //country summary
  static const Map<CountrySummaryTabs, String> countrySumaryRoutes = {
    CountrySummaryTabs.request: Routes.request,
    CountrySummaryTabs.rational: Routes.rational,
    CountrySummaryTabs.summaryOfLatestDev: Routes.summaryOfLatestDevelopment,
    CountrySummaryTabs.bankingSector: Routes.bankingSector,
    CountrySummaryTabs.fiRecommend: Routes.fiRecommendation,
  };

  static const Map<CountrySummaryTabs, String> countrySummaryTitles = {
    CountrySummaryTabs.request: "approval.countrySummary.request",
    CountrySummaryTabs.rational: "approval.countrySummary.rational",
    CountrySummaryTabs.summaryOfLatestDev:
        "approval.countrySummary.summaryOfLatestDev",
    CountrySummaryTabs.bankingSector: "approval.countrySummary.bankingSector",
    CountrySummaryTabs.fiRecommend: "approval.countrySummary.fiRecommend",
  };

  //grpup summary
  static const Map<GroupSummaryTabs, String> groupSumaryRoutes = {
    GroupSummaryTabs.ownershipCorporateStructure:
        Routes.ownershipCorporateStructure,
    GroupSummaryTabs.groupManagementTeam: Routes.groupManagementTeam,
    GroupSummaryTabs.successsionkeyManRisk: Routes.successsionkeyManRisk,
    GroupSummaryTabs.relationshipFutureStrategy:
        Routes.relationshipFutureStrategy,
  };

  static const Map<GroupSummaryTabs, String> groupSummaryTitles = {
    GroupSummaryTabs.ownershipCorporateStructure:
        "approval.groupSummary.ownershipCorporateStructure",
    GroupSummaryTabs.groupManagementTeam:
        "approval.groupSummary.groupManagementTeam",
    GroupSummaryTabs.successsionkeyManRisk:
        "approval.groupSummary.successsionkeyManRisk",
    GroupSummaryTabs.relationshipFutureStrategy:
        "approval.groupSummary.relationshipFutureStrategy",
  };

  static const Map<RemarksTabs, String> remarksRoutes = {
    RemarksTabs.requestSummary: Routes.remarksCommonTabs,
    RemarksTabs.relationshipHistory: Routes.remarksCommonTabs,
    RemarksTabs.businessRisk: Routes.remarksCommonTabs,
    RemarksTabs.industryRisk: Routes.remarksCommonTabs,
    RemarksTabs.financialRatiosAndAnalysis: Routes.financialRatiosAnalysis,
    RemarksTabs.security: Routes.remarksCommonTabs,
    RemarksTabs.ownershipStructure: Routes.remarksCommonTabs,
    RemarksTabs.managementRisk: Routes.remarksCommonTabs,
    RemarksTabs.facilityJustification: Routes.remarksCommonTabs,
    RemarksTabs.covenants: Routes.remarksCommonTabs,
    RemarksTabs.conditions: Routes.remarksCommonTabs,
    RemarksTabs.guarantorFinancials: Routes.guarantorFinancials,
    RemarksTabs.keyRisksAndMitigants: Routes.remarksCommonTabs,
    RemarksTabs.otherFacilityRelatedAnalysis: Routes.remarksCommonTabs,
    RemarksTabs.existingAndProposedCollateral: Routes.remarksCommonTabs,
    RemarksTabs.settlementLimits: Routes.remarksCommonTabs,
    RemarksTabs.cashflowProjectionAnalysis: Routes.remarksCommonTabs,
    RemarksTabs.feeStructure: Routes.feeStructure,
    RemarksTabs.businessExperience: Routes.remarksCommonTabs,
    RemarksTabs.background: Routes.remarksCommonTabs,
    RemarksTabs.ownership: Routes.remarksCommonTabs,
    RemarksTabs.analysisCapital: Routes.remarksCommonTabs,
    RemarksTabs.analysisAssets: Routes.remarksCommonTabs,
    RemarksTabs.analysisManagement: Routes.remarksCommonTabs,
    RemarksTabs.analysisEarnings: Routes.remarksCommonTabs,
    RemarksTabs.analysisLiquidity: Routes.remarksCommonTabs,
    RemarksTabs.analysisOtherComments: Routes.remarksCommonTabs,
    RemarksTabs.otherComments: Routes.remarksCommonTabs,
    RemarksTabs.bankOverview: Routes.remarksCommonTabs,
    RemarksTabs.financialHighlights: Routes.remarksCommonTabs,
  };

  static const Map<RemarksTabs, String> remarksTitles = {
    RemarksTabs.businessRisk: "remarks.businessRisk.tabTitle",
    RemarksTabs.industryRisk: "remarks.industryRisk.tabTitle",
    RemarksTabs.managementRisk: "remarks.managementRisk.tabTitle",
    RemarksTabs.ownershipStructure: "remarks.ownershipStructure.tabTitle",
    RemarksTabs.relationshipHistory: "remarks.relationshipHistory.tabTitle",
    RemarksTabs.conditions: "remarks.conditions.tabTitle",
    RemarksTabs.keyRisksAndMitigants: "remarks.keyRisksAndMitigants.tabTitle",
    RemarksTabs.otherFacilityRelatedAnalysis:
        "remarks.otherFacilityRelatedAnalysis.tabTitle",
    RemarksTabs.guarantorFinancials: "remarks.guarantorFinancials.tabTitle",
    RemarksTabs.feeStructure: "remarks.feeStructure.tabTitle",
    RemarksTabs.existingAndProposedCollateral:
        "remarks.existingAndProposedCollateral.tabTitle",
    RemarksTabs.settlementLimits: "remarks.settlementLimits.tabTitle",
    RemarksTabs.cashflowProjectionAnalysis:
        "remarks.cashflowProjectionAnalysis.tabTitle",
    RemarksTabs.businessExperience: "remarks.businessExperience.tabTitle",
    RemarksTabs.background: "remarks.background.tabTitle",
    RemarksTabs.ownership: "remarks.ownership.tabTitle",
    RemarksTabs.analysisCapital: "remarks.analysisCapital.tabTitle",
    RemarksTabs.analysisAssets: "remarks.analysisAssets.tabTitle",
    RemarksTabs.analysisManagement: "remarks.analysisManagement.tabTitle",
    RemarksTabs.covenants: "remarks.covenants.tabTitle",
    RemarksTabs.facilityJustification: "remarks.facilityJustification.tabTitle",
    RemarksTabs.financialRatiosAndAnalysis:
        "remarks.financialRatiosAndAnalysis.tabTitle",
    RemarksTabs.requestSummary: "remarks.requestSummary.tabTitle",
    RemarksTabs.financialHighlights: "remarks.financialHighlights.tabTitle",
    RemarksTabs.bankOverview: "remarks.bankOverview.tabTitle",
    RemarksTabs.otherComments: "remarks.otherComments.tabTitle",
    RemarksTabs.analysisOtherComments: "remarks.analysisOtherComments.tabTitle",
    RemarksTabs.analysisLiquidity: "remarks.analysisLiquidity.tabTitle",
    RemarksTabs.analysisEarnings: "remarks.analysisEarnings.tabTitle",
    RemarksTabs.security: "remarks.security.tabTitle",
  };
  static const Map<RemarksTabs, String> remarksTooltipContent = {
    RemarksTabs.businessRisk: "remarks.businessRisk.tooltipContent",
    RemarksTabs.industryRisk: "remarks.industryRisk.tooltipContent",
    RemarksTabs.managementRisk: "remarks.managementRisk.tooltipContent",
    RemarksTabs.ownershipStructure: "remarks.ownershipStructure.tooltipContent",
    RemarksTabs.relationshipHistory:
        "remarks.relationshipHistory.tooltipContent",
    RemarksTabs.conditions: "remarks.covenants.tooltipContent",
    RemarksTabs.keyRisksAndMitigants:
        "remarks.keyRisksAndMitigants.tooltipContent",
    RemarksTabs.otherFacilityRelatedAnalysis:
        "remarks.otherFacilityRelatedAnalysis.tooltipContent",
    RemarksTabs.guarantorFinancials:
        "remarks.guarantorFinancials.tooltipContent",
    RemarksTabs.feeStructure: "remarks.feeStructure.tooltipContent",
    RemarksTabs.existingAndProposedCollateral:
        "remarks.existingAndProposedCollateral.tooltipContent",
    RemarksTabs.settlementLimits: "remarks.settlementLimits.tooltipContent",
    RemarksTabs.cashflowProjectionAnalysis:
        "remarks.cashflowProjectionAnalysis.tooltipContent",
    RemarksTabs.businessExperience: "remarks.businessExperience.tooltipContent",
    RemarksTabs.background: "remarks.background.tooltipContent",
    RemarksTabs.ownership: "remarks.ownership.tooltipContent",
    RemarksTabs.analysisCapital: "remarks.analysisCapital.tooltipContent",
    RemarksTabs.analysisAssets: "remarks.analysisAssets.tooltipContent",
    RemarksTabs.analysisManagement: "remarks.analysisManagement.tooltipContent",
    RemarksTabs.covenants: "remarks.covenants.tooltipContent",
    RemarksTabs.facilityJustification:
        "remarks.facilityJustification.tooltipContent",
    RemarksTabs.financialRatiosAndAnalysis:
        "remarks.financialRatiosAndAnalysis.tooltipContent",
    RemarksTabs.requestSummary: "remarks.requestSummary.tooltipContent",
    RemarksTabs.financialHighlights:
        "remarks.financialHighlights.tooltipContent",
    RemarksTabs.bankOverview: "remarks.bankOverview.tooltipContent",
    RemarksTabs.otherComments: "remarks.otherComments.tooltipContent",
    RemarksTabs.analysisOtherComments:
        "remarks.analysisOtherComments.tooltipContent",
    RemarksTabs.analysisLiquidity: "remarks.analysisLiquidity.tooltipContent",
    RemarksTabs.analysisEarnings: "remarks.analysisEarnings.tooltipContent",
    RemarksTabs.security: "remarks.security.tooltipContent",
  };

// The exact FI chips you want to keep visible when "View less"
  static const Set<RemarksTabs> fiCollapsedTabs = {
    RemarksTabs.businessExperience,
    RemarksTabs.background,
    RemarksTabs.ownership,
    RemarksTabs.analysisOtherComments,
    RemarksTabs.analysisCapital,
    RemarksTabs.analysisAssets,
    RemarksTabs.analysisManagement,
    RemarksTabs.analysisEarnings,
    RemarksTabs.analysisLiquidity,
    RemarksTabs.otherComments,
    RemarksTabs.bankOverview,
    RemarksTabs.financialHighlights,
  };

  static Map<RemarksTabs, bool Function()> getRemarksRoutes(Customer customer) {
    bool isFI() =>
        customer.type == CustomerType.belowInvestmentGradeBanks ||
        customer.type == CustomerType.investmentGradeBanks;

    return {
      RemarksTabs.businessExperience: isFI,
      RemarksTabs.background: isFI,
      RemarksTabs.ownership: isFI,
      RemarksTabs.analysisOtherComments: isFI,
      RemarksTabs.analysisCapital: isFI,
      RemarksTabs.analysisAssets: isFI,
      RemarksTabs.analysisManagement: isFI,
      RemarksTabs.analysisEarnings: isFI,
      RemarksTabs.analysisLiquidity: isFI,
      RemarksTabs.otherComments: isFI,
      RemarksTabs.bankOverview: isFI,
      RemarksTabs.financialHighlights: isFI,
    };
  }

  static Map<RecommendationTabs, bool Function()> getRecommendationRoutes() {
    return {
      RecommendationTabs.proposedFacilities: () =>
          AuthRepository.hasRight(RightConstants.proposedFacilities),
      RecommendationTabs.groupPosition: () =>
          AuthRepository.hasRight(RightConstants.groupPosition) &&
          Globals.checkGroupAccess(),
      RecommendationTabs.limitCaps: () =>
          AuthRepository.hasRight(RightConstants.limitCaps),
      RecommendationTabs.guarantorsExposure: () =>
          AuthRepository.hasRight(RightConstants.guarantorsExposure),
      RecommendationTabs.queriesAndResponses: () =>
          (AuthRepository.hasRight(RightConstants.queriesResponses) &&
              Globals.isQueriesTabVisible()),
      RecommendationTabs.previousCreditApproval: () =>
          AuthRepository.hasRight(RightConstants.previousCreditApproval),
      RecommendationTabs.recommendationCurrentApproval: () =>
          AuthRepository.hasRight(RightConstants.recommendationCurrentApproval),
      RecommendationTabs.comments: () =>
          AuthRepository.hasRight(RightConstants.comments),
    };
  }

  static Map<BusinessVolumeAccountStatsTabs, bool Function()>
      getBusinessAccountRoutes() {
    return {
      BusinessVolumeAccountStatsTabs.businessVolume: () =>
          AuthRepository.hasRight(RightConstants.businessVolume),
      BusinessVolumeAccountStatsTabs.accountStats: () =>
          AuthRepository.hasRight(RightConstants.accountStats),
    };
  }

  // static Map<GroupSummaryTabs, bool Function()> getGroupSummaryRoutes() {
  //   return {
  //     GroupSummaryTabs.groupManagementTeam: () =>
  //         AuthRepository.hasRight(RightConstants.groupBorrowers),
  //     GroupSummaryTabs.ownershipCorporateStructure: () =>
  //         AuthRepository.hasRight(RightConstants.),
  //     GroupSummaryTabs.limitCaps: () =>
  //         AuthRepository.hasRight(RightConstants.limitCaps),
  //     GroupSummaryTabs.guarantorsExposure: () =>
  //         AuthRepository.hasRight(RightConstants.guarantorsExposure),
  //   };
  // }
}
