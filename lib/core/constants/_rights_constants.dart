part of 'constants.dart';

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
  static const String ccsysRecommendationApproval =
      "ccsys-recommendation-approval";
  static const String referenceDataManagement = "reference-data-management";
  static const String referenceDialog = "reference-dialog";
  static const String roleRightMapping = "role-right-mapping";
  static const String usersList = "users-list";
  static const String userAccess = "user-access";
  static const String fileAccess = "file-access";
  static const String remarksCommentary = "remarks-commentary";
  // static const String recommendationApproval = "recommendation-approval";
  static const String businessVolumeAccountStats =
      "business-volume-account-stats";
  // static const String limitInputCertification = "credit-control-team-certification";
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
  RightConstants.facilitySummary: 16,  //17
  // RightConstants.facilitySummaryFi: 18,
  // RightConstants.createSecurity: 18, 
  RightConstants.securitySummary: 17,
  RightConstants.covenantsSummary: 18,
  RightConstants.conditionsSummary: 19,
  RightConstants.facilitySecurityLinkage: 20,
  RightConstants.facilitiesWithCbd: 21,
  RightConstants.facilitiesWithOtherBanks: 22,
  RightConstants.businessVolumeAccountStats: 23,
  RightConstants.businessVolume: 24,
  RightConstants.accountStats: 25,
  RightConstants.accountConduct: 26,
  RightConstants.relationshipUtilisation: 27,
  RightConstants.relationshipProfitabilitySummary: 28,
  RightConstants.relationshipProfitabilityDetailed: 29,
  RightConstants.incomeSummary: 30,
  RightConstants.strategiesComments: 31,
  RightConstants.revenueCrossSell: 32,
  RightConstants.shareOfWallet: 33,
  RightConstants.remarksCommentary: 34,
  RightConstants.rmCertification: 35,
  RightConstants.esgCertification: 36,
  RightConstants.documentationCertification: 37,
  // RightConstants.limitInputCertification: 41,
  RightConstants.creditControlTeamCertification: 38,
  // RightConstants.recommendationApproval: 43,
  RightConstants.proposedFacilities: 39,
  RightConstants.groupPosition: 40,
  RightConstants.limitCaps: 41,
  RightConstants.guarantorsExposure: 42,
  RightConstants.queriesResponses: 43,
  RightConstants.comments: 44,
  RightConstants.creditAssessment: 45,
  RightConstants.groupSummary: 46,
  RightConstants.managementComments: 47,
  RightConstants.requestForFol: 48,
  RightConstants.requestForLimitRelease: 49,
  RightConstants.requestForClosure: 50,
  RightConstants.fileAttachments: 51,
  RightConstants.appendix: 52,

// admin
  RightConstants.referenceDataManagement: 53,
  RightConstants.roleRightMapping: 54,
  RightConstants.fileAccess: 55,
  RightConstants.userAccess: 56,
  RightConstants.usersList: 57,

// digital filing
  RightConstants.digitalFiling: 58,

// project
  RightConstants.searchProject: 59,
  RightConstants.createProject: 60,
  RightConstants.editProject: 61,
  RightConstants.linkContract: 62,
  RightConstants.editContract: 63,

// ccsys
  RightConstants.ccsysCreateRequest: 64,
  RightConstants.ccsysRequestInformation: 65,
  RightConstants.ccsysCustomerInformation: 66,
  RightConstants.ccsysRecommendationApproval: 67

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
