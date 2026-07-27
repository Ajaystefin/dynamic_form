part of "constants.dart";

/// Business volume and account statistics tabs.
enum BusinessVolumeAccountStatsTabs {
  /// Business volume tab.
  businessVolume,

  /// Account statistics tab.
  accountStats,
}

/// Application filter types.
enum ApplicationFilterType {
  /// Overdue applications.
  applicationOverdue,

  /// Applications due for review.
  dueForReview,

  /// Recent applications.
  recentApplication,

  /// Application segment filter.
  applicationSegment,

  /// Closed requests.
  closedRequest,

  /// CCSYS applications.
  ccsys,
}

/// Revenue cross-sell tabs.
enum RevenueCrossSellTabs {
  /// Relationship utilization tab.
  relationshipUtilization,

  /// Relationship profitability summary tab.
  relationshipProfitabilitySummary,

  /// Relationship profitability detailed tab.
  relationshipProfitabilityDetailed,

  /// Income summary tab.
  incomeSummary,

  /// Strategies and comments tab.
  strategiesAndComments,
}

/// Recommendation tabs.
enum RecommendationTabs {
  /// Proposed facilities tab.
  proposedFacilities,

  /// Group position tab.
  groupPosition,

  /// Limit caps tab.
  limitCaps,

  /// Guarantors exposure tab.
  guarantorsExposure,

  /// Queries and responses tab.
  queriesAndResponses,

  /// Previous credit approval tab.
  previousCreditApproval,

  /// Current approval recommendation tab.
  recommendationCurrentApproval,

  /// Comments tab.
  comments,
}

/// Group summary tabs.
enum GroupSummaryTabs {
  /// Ownership and corporate structure tab.
  ownershipCorporateStructure,

  /// Group management team tab.
  groupManagementTeam,

  /// Succession and key man risk tab.
  successsionkeyManRisk,

  /// Relationship future strategy tab.
  relationshipFutureStrategy,
}

/// Country summary tabs.
enum CountrySummaryTabs {
  /// Request tab.
  request,

  /// Rationale tab.
  rational,

  /// Summary of latest developments tab.
  summaryOfLatestDev,

  /// Banking sector tab.
  bankingSector,

  /// FI recommendation tab.
  fiRecommend,
}

/// Remarks tabs.
enum RemarksTabs {
  /// Request summary tab.
  requestSummary,

  /// Relationship history tab.
  relationshipHistory,

  /// Business risk tab.
  businessRisk,

  /// Industry risk tab.
  industryRisk,

  /// Financial ratios and analysis tab.
  financialRatiosAndAnalysis,

  /// Security tab.
  security,

  /// Ownership structure tab.
  ownershipStructure,

  /// Management risk tab.
  managementRisk,

  /// Facility justification tab.
  facilityJustification,

  /// Covenants tab.
  covenants,

  /// Conditions tab.
  conditions,

  /// Guarantor financials tab.
  guarantorFinancials,

  /// Key risks and mitigants tab.
  keyRisksAndMitigants,

  /// Other facility-related analysis tab.
  otherFacilityRelatedAnalysis,

  /// Existing and proposed collateral tab.
  existingAndProposedCollateral,

  /// Settlement limits tab.
  settlementLimits,

  /// Cashflow projection analysis tab.
  cashflowProjectionAnalysis,

  /// Fee structure tab.
  feeStructure,

  /// Business experience tab.
  businessExperience,

  /// Background tab.
  background,

  /// Ownership tab.
  ownership,

  /// Capital analysis tab.
  analysisCapital,

  /// Assets analysis tab.
  analysisAssets,

  /// Management analysis tab.
  analysisManagement,

  /// Earnings analysis tab.
  analysisEarnings,

  /// Liquidity analysis tab.
  analysisLiquidity,

  /// Other comments analysis tab.
  analysisOtherComments,

  /// Other comments tab.
  otherComments,

  /// Bank overview tab.
  bankOverview,

  /// Financial highlights tab.
  financialHighlights,
}

/// Constants and configuration used for application tabs and navigation.
class TabConstants {
  /// Route mappings for business volume and account statistics tabs.
  static const Map<BusinessVolumeAccountStatsTabs, String>
      businessVolumeAccountStatsRoutes = {
    BusinessVolumeAccountStatsTabs.businessVolume: Routes.businessVolume,
    BusinessVolumeAccountStatsTabs.accountStats: Routes.accountStats,
  };

  /// Title mappings for business volume and account statistics tabs.
  static const Map<BusinessVolumeAccountStatsTabs, String>
      businessVolumeAccountStatsTitles = {
    BusinessVolumeAccountStatsTabs.businessVolume:
        "profitabilityAccountConduct.businessVolume.tabTitle",
    BusinessVolumeAccountStatsTabs.accountStats:
        "profitabilityAccountConduct.accountStats.tabTitle",
  };

  /// Route mappings for revenue cross-sell tabs.
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

  /// Title mappings for revenue cross-sell tabs.
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

  /// Route mappings for recommendation tabs.
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

  /// Title mappings for recommendation tabs.
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

  /// Route mappings for country summary tabs.
  ///
  /// country summary
  static const Map<CountrySummaryTabs, String> countrySumaryRoutes = {
    CountrySummaryTabs.request: Routes.request,
    CountrySummaryTabs.rational: Routes.rational,
    CountrySummaryTabs.summaryOfLatestDev: Routes.summaryOfLatestDevelopment,
    CountrySummaryTabs.bankingSector: Routes.bankingSector,
    CountrySummaryTabs.fiRecommend: Routes.fiRecommendation,
  };

  /// Title mappings for country summary tabs.
  static const Map<CountrySummaryTabs, String> countrySummaryTitles = {
    CountrySummaryTabs.request: "approval.countrySummary.request",
    CountrySummaryTabs.rational: "approval.countrySummary.rational",
    CountrySummaryTabs.summaryOfLatestDev:
        "approval.countrySummary.summaryOfLatestDev",
    CountrySummaryTabs.bankingSector: "approval.countrySummary.bankingSector",
    CountrySummaryTabs.fiRecommend: "approval.countrySummary.fiRecommend",
  };

  /// Route mappings for group summary tabs.
  ///
  /// group summary
  static const Map<GroupSummaryTabs, String> groupSumaryRoutes = {
    GroupSummaryTabs.ownershipCorporateStructure:
        Routes.ownershipCorporateStructure,
    GroupSummaryTabs.groupManagementTeam: Routes.groupManagementTeam,
    GroupSummaryTabs.successsionkeyManRisk: Routes.successsionkeyManRisk,
    GroupSummaryTabs.relationshipFutureStrategy:
        Routes.relationshipFutureStrategy,
  };

  /// Title mappings for group summary tabs.
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

  /// Route mappings for remarks tabs.
  static const Map<RemarksTabs, String> remarksRoutes = {
    RemarksTabs.requestSummary: Routes.remarksCommonTabs,

    RemarksTabs.existingAndProposedCollateral: Routes.remarksCommonTabs,
    RemarksTabs.settlementLimits: Routes.remarksCommonTabs,

    RemarksTabs.ownershipStructure: Routes.remarksCommonTabs,
    RemarksTabs.managementRisk: Routes.remarksCommonTabs,
    RemarksTabs.businessRisk: Routes.remarksCommonTabs,

    RemarksTabs.facilityJustification: Routes.remarksCommonTabs,
    //RemarksTabs.security: Routes.remarksCommonTabs,

    RemarksTabs.otherFacilityRelatedAnalysis: Routes.remarksCommonTabs,
    RemarksTabs.feeStructure: Routes.feeStructure,

    RemarksTabs.financialRatiosAndAnalysis: Routes.financialRatiosAnalysis,
    RemarksTabs.guarantorFinancials: Routes.guarantorFinancials,

    RemarksTabs.cashflowProjectionAnalysis: Routes.remarksCommonTabs,
    RemarksTabs.keyRisksAndMitigants: Routes.remarksCommonTabs,

    RemarksTabs.covenants: Routes.remarksCommonTabs,
    RemarksTabs.conditions: Routes.remarksCommonTabs,

    // keep remaining tabs AFTER (FI / extra tabs)
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

  /// Title mappings for remarks tabs.
  static const Map<RemarksTabs, String> remarksTitles = {
    RemarksTabs.requestSummary: "remarks.requestSummary.tabTitle",

    RemarksTabs.existingAndProposedCollateral:
        "remarks.existingAndProposedCollateral.tabTitle",
    RemarksTabs.settlementLimits: "remarks.settlementLimits.tabTitle",

    RemarksTabs.ownershipStructure: "remarks.ownershipStructure.tabTitle",
    RemarksTabs.managementRisk: "remarks.managementRisk.tabTitle",
    RemarksTabs.businessRisk: "remarks.businessRisk.tabTitle",

    RemarksTabs.facilityJustification: "remarks.facilityJustification.tabTitle",
    //RemarksTabs.security: "remarks.security.tabTitle",

    RemarksTabs.otherFacilityRelatedAnalysis:
        "remarks.otherFacilityRelatedAnalysis.tabTitle",
    RemarksTabs.feeStructure: "remarks.feeStructure.tabTitle",

    RemarksTabs.financialRatiosAndAnalysis:
        "remarks.financialRatiosAndAnalysis.tabTitle",
    RemarksTabs.guarantorFinancials: "remarks.guarantorFinancials.tabTitle",

    RemarksTabs.cashflowProjectionAnalysis:
        "remarks.cashflowProjectionAnalysis.tabTitle",
    RemarksTabs.keyRisksAndMitigants: "remarks.keyRisksAndMitigants.tabTitle",

    RemarksTabs.covenants: "remarks.covenants.tabTitle",
    RemarksTabs.conditions: "remarks.conditions.tabTitle",

    //  remaining (optional / FI)
    RemarksTabs.businessExperience: "remarks.businessExperience.tabTitle",
    RemarksTabs.background: "remarks.background.tabTitle",
    RemarksTabs.ownership: "remarks.ownership.tabTitle",
    RemarksTabs.analysisCapital: "remarks.analysisCapital.tabTitle",
    RemarksTabs.analysisAssets: "remarks.analysisAssets.tabTitle",
    RemarksTabs.analysisManagement: "remarks.analysisManagement.tabTitle",
    RemarksTabs.analysisEarnings: "remarks.analysisEarnings.tabTitle",
    RemarksTabs.analysisLiquidity: "remarks.analysisLiquidity.tabTitle",
    RemarksTabs.analysisOtherComments: "remarks.analysisOtherComments.tabTitle",
    RemarksTabs.otherComments: "remarks.otherComments.tabTitle",
    RemarksTabs.bankOverview: "remarks.bankOverview.tabTitle",
    RemarksTabs.financialHighlights: "remarks.financialHighlights.tabTitle",
  };

  /// Tooltip content mappings for remarks tabs.
  static const Map<RemarksTabs, String> remarksTooltipContent = {
    RemarksTabs.businessRisk: "remarks.businessRisk.tooltipContent",
    // RemarksTabs.industryRisk: "remarks.industryRisk.tooltipContent",
    RemarksTabs.managementRisk: "remarks.managementRisk.tooltipContent",
    RemarksTabs.ownershipStructure: "remarks.ownershipStructure.tooltipContent",
    // RemarksTabs.relationshipHistory:
    //     "remarks.relationshipHistory.tooltipContent",
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
    //RemarksTabs.security: "remarks.security.tooltipContent",
  };

  /// FI tabs visible in collapsed view.
  ///
  /// The exact FI chips you want to keep visible when "View less"
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

  /// Returns visibility rules for FI-related remarks tabs.
  static Map<RemarksTabs, bool Function()> getRemarksRoutes(Customer customer) {
    bool isFIBank() =>
        customer.type == CustomerType.belowInvestmentGradeBanks ||
        customer.type == CustomerType.investmentGradeBanks;

    //bool isNotCorporate() => customer.type != CustomerType.corporate;

    return {
      //RemarksTabs.security: isNotCorporate,
      RemarksTabs.businessExperience: isFIBank,
      RemarksTabs.background: isFIBank,
      RemarksTabs.ownership: isFIBank,
      RemarksTabs.analysisOtherComments: isFIBank,
      RemarksTabs.analysisCapital: isFIBank,
      RemarksTabs.analysisAssets: isFIBank,
      RemarksTabs.analysisManagement: isFIBank,
      RemarksTabs.analysisEarnings: isFIBank,
      RemarksTabs.analysisLiquidity: isFIBank,
      RemarksTabs.otherComments: isFIBank,
      RemarksTabs.bankOverview: isFIBank,
      RemarksTabs.financialHighlights: isFIBank,
    };
  }

  /// Returns visibility rules for recommendation tabs.
  static Map<RecommendationTabs, bool Function()> getRecommendationRoutes() {
    return {
      RecommendationTabs.proposedFacilities: () =>
          AuthRepository.hasRight(RightConstants.proposedFacilities),
      RecommendationTabs.groupPosition: () =>
          AuthRepository.hasRight(RightConstants.groupPosition) &&
          Utils.isGroupApplication(),
      RecommendationTabs.limitCaps: () =>
          AuthRepository.hasRight(RightConstants.limitCaps),
      RecommendationTabs.guarantorsExposure: () =>
          AuthRepository.hasRight(RightConstants.guarantorsExposure),
      RecommendationTabs.queriesAndResponses: () =>
          AuthRepository.hasRight(RightConstants.queriesResponses) &&
          ApprovalUtils.isQueriesTabVisible(),
      RecommendationTabs.previousCreditApproval: () =>
          AuthRepository.hasRight(RightConstants.previousCreditApproval),
      RecommendationTabs.recommendationCurrentApproval: () =>
          AuthRepository.hasRight(RightConstants.recommendationCurrentApproval),
      RecommendationTabs.comments: () =>
          AuthRepository.hasRight(RightConstants.comments),
    };
  }

  /// Returns visibility rules for business account tabs.
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
