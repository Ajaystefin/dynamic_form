part of "constants.dart";

class RightConstants {
  static const String login = "login";
  static const String selectRole = "select-role";
  static const String dashboard = "dashboard";
  static const String advancedSearch = "advanced-search";
  static const String closedRequest = "closed-request";
  static const String createNewRequest = "create-new-request";
  static const String applicationBorrowers = "application-borrowers";
  static const String groupBorrowers = "group-borrowers";
  static const String requestInformation = "request-information";
  static const String pipelineDialog = "pipeline-dialog";
  static const String presentRequest = "present-request";
  static const String securityPerfection = "security-perfection";
  static const String terminateWithdrawal = "terminate-withdrawal";
  static const String customerInformation = "customer-information";
  static const String sicCodeReview = "sic-code-review";
  static const String facilitiesWithCbd = "facilities-with-cbd";
  static const String facilitiesWithOtherBanks = "facilities-with-other-banks";
  static const String addBankDialog = "add-bank-dialog";
  static const String customerRiskRating = "customer-risk-rating";
  static const String conditionsSummary = "conditions-summary";
  static const String conditionsUpdate = "conditions-update";
  static const String covenantsSummary = "covenants-summary";
  static const String covenantsUpdate = "covenants-update";
  static const String covenantConditionFacilityDialogue =
      "covenant-condition-facility-dialogue";
  static const String securitySummary = "security-summary";
  static const String selectFacilityDialog = "select-facility-dialog";
  static const String createSecurity = "create-security";
  static const String facilitySecurityLinkage = "facility-security-linkage";
  static const String createFacility = "create-facility";
  static const String facilitySummary = "facility-summary";
  static const String facilitySummaryFi = "facility-summary-fi";
  static const String rmCertification = "rm-certification";
  static const String documentationCertification =
      "documentation-certification";
  static const String creditControlTeamCertification =
      "credit-control-team-certification";
  static const String esgCertification = "esg-certification";
  static const String accountStats = "account-stats";
  static const String businessVolume = "business-volume";
  static const String accountConduct = "account-conduct";
  static const String strategiesComments = "strategies-comments";
  static const String incomeSummary = "income-summary";
  static const String relationshipProfitabilityDetailed =
      "relationship-profitability-detailed";
  static const String relationshipUtilisation = "relationship-utilisation";
  static const String relationshipProfitabilitySummary =
      "relationship-profitability-summary";
  static const String revenueCrossSell = "revenue-cross-sell";
  static const String shareOfWallet = "share-of-wallet";
  static const String proposedFacilities = "proposed-facilities";
  static const String groupPosition = "group-position";
  static const String limitCaps = "limit-caps";
  static const String guarantorsExposure = "guarantors-exposure";
  static const String queriesResponses = "queries-responses";
  static const String previousCreditApproval =
      "previous-cc-bcic-credit-approval";
  static const String recommendationCurrentApproval =
      "recommendation-for-current-approval";
  static const String comments = "comments";
  static const String requestForFol = "request-for-fol";
  static const String creditAssessment = "credit-assessment";
  static const String requestForLimitRelease = "request-for-limit-release";
  static const String requestForClosure = "request-for-closure";
  static const String managementComments = "management-comments";
  static const String groupSummary = "group-summary";
  static const String preview = "preview";
  static const String countrySummary = "country-summary";
  static const String fileAttachments = "file-attachments";
  static const String digitalFiling = "digital-filing";
  static const String uploadDialog = "upload-dialog";
  static const String appendix = "appendix";
  static const String searchProject = "search-project";
  static const String editProject = "edit-project";
  static const String editContract = "edit-contract";
  static const String createProject = "create-project";
  static const String linkContract = "link-contract";
  static const String ccsysCreateRequest = "ccsys-create-request";
  static const String ccsysRequestInformation = "ccsys-request-information";
  static const String ccsysCustomerInformation = "ccsys-customer-information";
  static const String ccsysTerminationWithdrawal = "ccsys-terminate-withdrawal";

  static const String ccsysRecommendationApproval =
      "ccsys-recommendation-approval";
  static const String referenceDataManagement = "reference-data-management";
  static const String referenceDialog = "reference-dialog";
  static const String roleRightMapping = "role-right-mapping";
  static const String usersList = "users-list";
  static const String userAccess = "user-access";
  static const String fileAccess = "file-access";
  static const String workflowConfiguration = "workflow-configuration";
  static const String remarksCommentary = "remarks-commentary";
  // static const String recommendationApproval = "recommendation-approval";
  static const String businessVolumeAccountStats =
      "business-volume-account-stats";
  // static const String limitInputCertification =
  // "credit-control-team-certification";
}

final Map<String, int> navigationOrderMap = {
  RightConstants.login: 1,
  RightConstants.selectRole: 2,
  RightConstants.dashboard: 3,
  RightConstants.advancedSearch: 4,
  RightConstants.closedRequest: 5,
  RightConstants.createNewRequest: 6,
  RightConstants.groupBorrowers: 7,
  RightConstants.applicationBorrowers: 8,
  RightConstants.requestInformation: 9,
  RightConstants.presentRequest: 10,
  RightConstants.securityPerfection: 11,
  RightConstants.terminateWithdrawal: 12,
  RightConstants.customerInformation: 13,
  RightConstants.sicCodeReview: 14,
  RightConstants.customerRiskRating: 15,
  // RightConstants.createFacility: 16,
  RightConstants.facilitySummary: 16, //17
  // RightConstants.facilitySummaryFi: 18,

  RightConstants.securitySummary: 17,
  RightConstants.createSecurity: 18, //This is a sub-route
  RightConstants.covenantsSummary: 19,
  RightConstants.conditionsSummary: 20,
  RightConstants.facilitySecurityLinkage: 21,
  RightConstants.facilitiesWithCbd: 22,
  RightConstants.facilitiesWithOtherBanks: 23,
  // RightConstants.businessVolumeAccountStats: 24,
  RightConstants.businessVolume: 25,
  RightConstants.accountStats: 26,
  RightConstants.accountConduct: 27,
  RightConstants.relationshipUtilisation: 28,
  RightConstants.relationshipProfitabilitySummary: 29,
  RightConstants.relationshipProfitabilityDetailed: 30,
  RightConstants.incomeSummary: 31,
  RightConstants.strategiesComments: 32,
  // RightConstants.revenueCrossSell: 33,
  RightConstants.shareOfWallet: 34,
  RightConstants.remarksCommentary: 35,
  RightConstants.rmCertification: 36,
  RightConstants.esgCertification: 37,
  RightConstants.documentationCertification: 38,
  // RightConstants.limitInputCertification: 42,
  RightConstants.creditControlTeamCertification: 39,
  // RightConstants.recommendationApproval: 44,
  RightConstants.proposedFacilities: 40,
  RightConstants.groupPosition: 41,
  RightConstants.limitCaps: 42,
  RightConstants.guarantorsExposure: 43,
  RightConstants.queriesResponses: 44,
  RightConstants.previousCreditApproval: 45,
  RightConstants.recommendationCurrentApproval: 46,
  RightConstants.comments: 47,
  RightConstants.creditAssessment: 48,
  RightConstants.groupSummary: 49,
  RightConstants.managementComments: 50,
  RightConstants.requestForFol: 51,
  RightConstants.requestForLimitRelease: 52,
  RightConstants.requestForClosure: 53,
  RightConstants.fileAttachments: 54,
  RightConstants.appendix: 55,

// admin
  RightConstants.referenceDataManagement: 56,
  RightConstants.roleRightMapping: 57,
  RightConstants.fileAccess: 58,
  RightConstants.userAccess: 59,
  RightConstants.usersList: 60,

// digital filing
  RightConstants.digitalFiling: 61,

// project
  RightConstants.searchProject: 62,
  RightConstants.createProject: 63,
  RightConstants.editProject: 64,
  RightConstants.linkContract: 65,
  RightConstants.editContract: 66,

// ccsys
  RightConstants.ccsysCreateRequest: 67,
  RightConstants.ccsysRequestInformation: 68,
  RightConstants.ccsysTerminationWithdrawal: 69,
  RightConstants.ccsysCustomerInformation: 70,
  RightConstants.ccsysRecommendationApproval: 71,

  // RightConstants.pipelineDialog: 10,
  // RightConstants.covenantsUpdate: 22,
  // RightConstants.covenantConditionFacilityDialogue: 23,
  // RightConstants.conditionsUpdate: 25,
  // RightConstants.addBankDialog: 30,
  // RightConstants.selectFacilityDialog: 57,
  // RightConstants.referenceDialog: 64,
  // RightConstants.preview: 70,
  // RightConstants.countrySummary: 71,
  // RightConstants.uploadDialog: 73,
};
