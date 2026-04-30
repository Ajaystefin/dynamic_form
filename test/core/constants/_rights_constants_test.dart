import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/constants.dart";

void main() {
  test("all rights constants have the expected string values", () {
    expect(navigationOrderMap, isA<Map<String, int>>());
    expect(RightConstants.login, "login");
    expect(RightConstants.selectRole, "select-role");
    expect(RightConstants.dashboard, "dashboard");
    expect(RightConstants.advancedSearch, "advanced-search");
    expect(RightConstants.closedRequest, "closed-request");
    expect(RightConstants.createNewRequest, "create-new-request");
    expect(RightConstants.applicationBorrowers, "application-borrowers");
    expect(RightConstants.groupBorrowers, "group-borrowers");
    expect(RightConstants.requestInformation, "request-information");
    expect(RightConstants.pipelineDialog, "pipeline-dialog");
    expect(RightConstants.presentRequest, "present-request");
    expect(RightConstants.securityPerfection, "security-perfection");
    expect(RightConstants.terminateWithdrawal, "terminate-withdrawal");
    expect(RightConstants.customerInformation, "customer-information");
    expect(RightConstants.sicCodeReview, "sic-code-review");
    expect(RightConstants.facilitiesWithCbd, "facilities-with-cbd");
    expect(
      RightConstants.facilitiesWithOtherBanks,
      "facilities-with-other-banks",
    );
    expect(RightConstants.addBankDialog, "add-bank-dialog");
    expect(RightConstants.customerRiskRating, "customer-risk-rating");
    expect(RightConstants.conditionsSummary, "conditions-summary");
    expect(RightConstants.conditionsUpdate, "conditions-update");
    expect(RightConstants.covenantsSummary, "covenants-summary");
    expect(RightConstants.covenantsUpdate, "covenants-update");
    expect(
      RightConstants.covenantConditionFacilityDialogue,
      "covenant-condition-facility-dialogue",
    );
    expect(RightConstants.securitySummary, "security-summary");
    expect(RightConstants.selectFacilityDialog, "select-facility-dialog");
    expect(RightConstants.createSecurity, "create-security");
    expect(RightConstants.facilitySecurityLinkage, "facility-security-linkage");
    expect(RightConstants.createFacility, "create-facility");
    expect(RightConstants.facilitySummary, "facility-summary");
    expect(RightConstants.facilitySummaryFi, "facility-summary-fi");
    expect(RightConstants.rmCertification, "rm-certification");
    expect(
      RightConstants.documentationCertification,
      "documentation-certification",
    );
    expect(
      RightConstants.creditControlTeamCertification,
      "credit-control-team-certification",
    );
    expect(RightConstants.esgCertification, "esg-certification");
    expect(RightConstants.accountStats, "account-stats");
    expect(RightConstants.businessVolume, "business-volume");
    expect(RightConstants.accountConduct, "account-conduct");
    expect(RightConstants.strategiesComments, "strategies-comments");
    expect(RightConstants.incomeSummary, "income-summary");
    expect(
      RightConstants.relationshipProfitabilityDetailed,
      "relationship-profitability-detailed",
    );
    expect(RightConstants.relationshipUtilisation, "relationship-utilisation");
    expect(
      RightConstants.relationshipProfitabilitySummary,
      "relationship-profitability-summary",
    );
    expect(RightConstants.revenueCrossSell, "revenue-cross-sell");
    expect(RightConstants.shareOfWallet, "share-of-wallet");
    expect(RightConstants.proposedFacilities, "proposed-facilities");
    expect(RightConstants.groupPosition, "group-position");
    expect(RightConstants.limitCaps, "limit-caps");
    expect(RightConstants.guarantorsExposure, "guarantors-exposure");
    expect(RightConstants.queriesResponses, "queries-responses");
    expect(RightConstants.comments, "comments");
    expect(RightConstants.requestForFol, "request-for-fol");
    expect(RightConstants.creditAssessment, "credit-assessment");
    expect(RightConstants.requestForLimitRelease, "request-for-limit-release");
    expect(RightConstants.requestForClosure, "request-for-closure");
    expect(RightConstants.managementComments, "management-comments");
    expect(RightConstants.groupSummary, "group-summary");
    expect(RightConstants.preview, "preview");
    expect(RightConstants.countrySummary, "country-summary");
    expect(RightConstants.fileAttachments, "file-attachments");
    expect(RightConstants.digitalFiling, "digital-filing");
    expect(RightConstants.uploadDialog, "upload-dialog");
    expect(RightConstants.appendix, "appendix");
    expect(RightConstants.searchProject, "search-project");
    expect(RightConstants.editProject, "edit-project");
    expect(RightConstants.editContract, "edit-contract");
    expect(RightConstants.createProject, "create-project");
    expect(RightConstants.linkContract, "link-contract");
    expect(RightConstants.ccsysCreateRequest, "ccsys-create-request");
    expect(RightConstants.ccsysRequestInformation, "ccsys-request-information");
    expect(
      RightConstants.ccsysCustomerInformation,
      "ccsys-customer-information",
    );
    expect(
      RightConstants.ccsysRecommendationApproval,
      "ccsys-recommendation-approval",
    );
    expect(RightConstants.referenceDataManagement, "reference-data-management");
    expect(RightConstants.referenceDialog, "reference-dialog");
    expect(RightConstants.roleRightMapping, "role-right-mapping");
    expect(RightConstants.usersList, "users-list");
    expect(RightConstants.userAccess, "user-access");
    expect(RightConstants.fileAccess, "file-access");
    expect(RightConstants.remarksCommentary, "remarks-commentary");
    // expect(RightConstants.recommendationApproval, 'recommendation-approval');
    expect(
      RightConstants.businessVolumeAccountStats,
      "business-volume-account-stats",
    );
    // expect(RightConstants.limitInputCertification,
    // 'limit-input-certification');
  });
}
