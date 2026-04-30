import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/constants.dart";

void main() {
  group("Routes", () {
    test("all route constants have the expected paths", () {
      testRoutes();
      // Home
      expect(Routes.home, "/home");
      expect(Routes.home2, "/home2");

      // Auth
      expect(Routes.login, "/login");
      expect(Routes.selectRole, "/select-role");

      // Dashboard
      expect(Routes.advancedSearch, "/advanced-search");
      expect(Routes.closedRequest, "/closed-request");

      // Request Information
      expect(Routes.requestCreate, "/create-request");
      expect(Routes.applicationBorrowers, "/application-borrowers");
      expect(Routes.groupBorrowers, "/group-borrowers");
      expect(Routes.requestInformation, "/request-information");
      expect(Routes.presentRequest, "/present-request");
      expect(Routes.securityPerfection, "/security-perfection");
      expect(Routes.terminateWithdraw, "/terminate-withdrawal");
      expect(Routes.customerInformation, "/customer-information");
      expect(Routes.sicCodeReview, "/sic-code-review");
      expect(Routes.facilitiesWithCbd, "/facilities-with-cbd");
      expect(Routes.facilitiesWithOtherBanks, "/facilities-with-other-banks");

      // Risk Rating
      expect(Routes.riskRating, "/customer-risk-rating");

      // Conditions & Covenants
      expect(Routes.conditionsSummary, "/conditions-summary");
      expect(Routes.covenantsSummary, "/covenants-summary");

      // Security
      expect(Routes.securitySummaryView, "/security-summary");
      expect(Routes.createSecurity, "/create-security");
      expect(Routes.facilitySecurityLinkage, "/facility-security-linkage");

      // Facilities
      expect(Routes.createFacility, "/create-facility");
      expect(Routes.facilitySummaryView, "/facility-summary");

      // Certification
      expect(Routes.rmCertification, "/rm-certification");
      expect(Routes.documentationCertification, "/documentation-certification");
      expect(
        Routes.limitInputCertification,
        "/credit-control-team-certification",
      );
      expect(Routes.esgCertification, "/esg-certification");

      // Profitability & Account Conduct
      expect(Routes.accountStats, "/account-stats");
      expect(Routes.businessVolume, "/business-volume");
      expect(Routes.accountConduct, "/account-conduct");
      expect(Routes.strategiesAndComments, "/strategies-comments");
      expect(Routes.incomeSummary, "/income-summary");
      expect(
        Routes.relationshipProfitabilityDetailed,
        "/relationship-profitability-detailed",
      );
      expect(Routes.relationshipUtilization, "/relationship-utilisation");
      expect(
        Routes.relationshipProfitabilitySummary,
        "/relationship-profitability-summary",
      );
      expect(Routes.shareOfWalletView, "/share-of-wallet");

      // Remarks
      expect(Routes.remarksCommonTabs, "/remarks-commentary");
      expect(Routes.financialRatiosAnalysis, "/financial-ratios-analysis");
      expect(Routes.guarantorFinancials, "/guarantor-financials");
      expect(Routes.feeStructure, "/fee-structure");
      expect(Routes.proposedFacilities, "/proposed-facilities");
      expect(Routes.groupPosition, "/group-position");
      expect(Routes.limitCaps, "/limit-caps");
      expect(Routes.guarantorsExposure, "/guarantors-exposure");
      expect(Routes.queriesAndResponses, "/queries-responses");
      expect(Routes.comments, "/comments");
      expect(Routes.requestForFOL, "/request-for-fol");
      expect(Routes.creditAssessment, "/credit-assessment");
      expect(Routes.requestForLimitRelease, "/request-for-limit-release");
      expect(Routes.managementComments, "/management-comments");
      expect(Routes.groupSummary, "/group-summary");
      expect(Routes.countrySummary, "/country-summary");

      // eDigital Filing & File Attachments
      expect(Routes.digitalEFiling, "/digital-efiling");
      expect(Routes.fileAttachment, "/file-attachments");

      // Project
      expect(Routes.searchProject, "/search-project");
      expect(Routes.editViewProject, "/edit-project");
      expect(Routes.editContract, "/edit-contract");
      expect(Routes.createProject, "/create-project");
      expect(Routes.linkContract, "/link-contract");

      // ccsys
      expect(Routes.ccsysRequestInformation, "/ccsys-request-information");
      expect(Routes.ccsysCustomerInformation, "/ccsys-customer-information");

      // Admin
      expect(Routes.manageReference, "/reference-data-management");
      expect(Routes.adminRoleRight, "/admin-role-right");
      expect(Routes.userList, "/user-list");
      expect(Routes.adminUserDetails, "/admin-user-details");
      expect(Routes.fileAccess, "/file-access");

      // Components
      expect(Routes.button, "/button");
      expect(Routes.textField, "/textField");
      expect(Routes.datePicker, "/datePicker");
      expect(Routes.alertPage, "/alertPage");
      expect(Routes.loadingPage, "/loadingPage");
      expect(Routes.dropDown, "/dropDown");
      expect(Routes.popup, "/popup");
      expect(Routes.textarea, "/textarea");
      expect(Routes.textEditor, "/textEditor");
      expect(Routes.tooltip, "/tooltip");
      expect(Routes.validation, "/validation");
      expect(Routes.checkbox, "/checkbox");
      expect(Routes.radioGroup, "/radioGroup");
      expect(Routes.accordion, "/accordion");
      expect(Routes.dropdownButton, "/dropdownButton");
      expect(Routes.tableViewPageOne, "/tableViewPageOne");
      expect(Routes.tableViewPageTwo, "/tableViewPageTwo");
      expect(Routes.fileUpload, "/fileUpload");
      expect(Routes.sectionHeader, "/sectionHeader");
      expect(Routes.session, "/session");
      expect(Routes.errorPage, "/errorPage");
      expect(Routes.dynamicInlineForm, "/dynamicInlineForm");
      expect(Routes.dropdownTextBox, "/dropdownTextBox");
      expect(Routes.accessibility, "/accessibility");
      expect(Routes.accessibilityImage, "/accessibilityImage");
      expect(Routes.selectableText, "/selectableText");
      expect(Routes.dynamicForm, "/dynamicForm");
      expect(Routes.validationPopup, "/validationPopup");
      expect(Routes.badge, "/badge");

      // Request (table)
      expect(Routes.table, "/table");

      // Profitability and account conduct
      expect(Routes.facilitySummaryFiView, "facility-summary-fi");

      // Recommendation – Approval
      expect(
        Routes.ownershipCorporateStructure,
        "/ownershipCorporateStructure",
      );
      expect(Routes.groupManagementTeam, "/groupManagementTeam");
      expect(Routes.successsionkeyManRisk, "/successsionkeyManRisk");
      expect(Routes.relationshipFutureStrategy, "/relationshipFutureStrategy");

      // Country Summary
      expect(Routes.rational, "/rational");
      expect(Routes.summaryOfLatestDevelopment, "/summaryOfLatestDevelopment");
      expect(Routes.bankingSector, "/bankingSector");
      expect(Routes.fiRecommendation, "/fiRecommendation");

      // File Attachment / Borrower Segregation (no constants defined)

      // Rich text controls
      expect(Routes.richTextTinyMCE, "/richTextTinyMCE");
      expect(Routes.richTextTextControl, "/richTextTextControl");
    });
  });
}
