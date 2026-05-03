part of "constants.dart";

class Routes {
  static const home = "/home";
  static const home2 = "/home2";

  //auth
  static const login = "/login";
  static const logout = "/logout";
  static const loginSuccess = "/login-success";
  static const ssoFailed = "/sso-error";
  static const splash = "/splash";
  static const selectRole = "/select-role";
  static const regionNotSetAccessDenied = "/access-denied";

  //dashboard
  static const advancedSearch = "/advanced-search";
  static const closedRequest = "/closed-request";

  //request Information
  static const requestCreate = "/create-request";
  static const applicationBorrowers = "/application-borrowers";
  static const groupBorrowers = "/group-borrowers";
  static const requestInformation = "/request-information";
  static const presentRequest = "/present-request";
  static const securityPerfection = "/security-perfection";
  static const terminateWithdraw = "/terminate-withdrawal";
  static const customerInformation = "/customer-information";
  static const sicCodeReview = "/sic-code-review";
  static const facilitiesWithCbd = "/facilities-with-cbd";
  static const facilitiesWithOtherBanks = "/facilities-with-other-banks";

  //Risk Rating
  static const riskRating = "/customer-risk-rating";

  //conditions
  static const conditionsSummary = "/conditions-summary";

  //Covenants
  static const covenantsSummary = "/covenants-summary";

  //Security
  static const securitySummaryView = "/security-summary";
  static const createSecurity = "/create-security";

  static const facilitySecurityLinkage = "/facility-security-linkage";

  //Facilities
  static const createFacility = "/create-facility";
  static const facilitySummaryView = "/facility-summary";

  //Certification
  static const rmCertification = "/rm-certification";
  static const documentationCertification = "/documentation-certification";
  static const limitInputCertification = "/credit-control-team-certification";
  static const esgCertification = "/esg-certification";

  //Profitability and Account Conduct
  static const accountStats = "/account-stats";
  static const businessVolume = "/business-volume";
  static const accountConduct = "/account-conduct";
  static const strategiesAndComments = "/strategies-comments";
  static const incomeSummary = "/income-summary";
  static const relationshipProfitabilityDetailed =
      "/relationship-profitability-detailed";
  static const relationshipUtilization = "/relationship-utilisation";
  static const relationshipProfitabilitySummary =
      "/relationship-profitability-summary";
  static const shareOfWalletView = "/share-of-wallet";

  //remarks
  static const remarksCommonTabs = "/remarks-commentary";
  static const financialRatiosAnalysis = "/financial-ratios-analysis";
  static const guarantorFinancials = "/guarantor-financials";
  static const feeStructure = "/fee-structure";
  static const proposedFacilities = "/proposed-facilities";
  static const groupPosition = "/group-position";
  static const limitCaps = "/limit-caps";
  static const guarantorsExposure = "/guarantors-exposure";
  static const queriesAndResponses = "/queries-responses";
  static const comments = "/comments";
  static const requestForFOL = "/request-for-fol";
  static const requestForClosure = "/request-for-closure";
  static const creditAssessment = "/credit-assessment";
  static const requestForLimitRelease = "/request-for-limit-release";
  static const managementComments = "/management-comments";
  static const groupSummary = "/group-summary";
  static const countrySummary = "/country-summary";
  static const recommendationCurrentApproval =
      "/recommendation-for-current-approval";
  static const creditAssessmentFI = "/credit-assessment-fi";
  static const previousCreditApproval = "/previous-cc-bcic-credit-approval";

  //eDigital Filing & File Attachments
  static const digitalEFiling = "/digital-efiling";
  static const fileAttachment = "/file-attachments";

  //project
  static const searchProject = "/search-project";
  static const editViewProject = "/edit-project";
  static const editContract = "/edit-contract";
  static const createProject = "/create-project";
  static const linkContract = "/link-contract";

  // ccsys
  static const ccsysApproval = "/ccsys-recommendation-approval";
  static const ccsysCreateRequest = "/ccsys-create-request";
  static const ccsysRequestInformation = "/ccsys-request-information";
  static const ccsysCustomerInformation = "/ccsys-customer-information";
  static const ccsysTerminateWithdraw = "/ccsys-terminate-withdrawal";

  //admin
  static const manageReference = "/reference-data-management";
  static const adminRoleRight = "/admin-role-right";
  static const userList = "/user-list";
  static const adminUserDetails = "/admin-user-details";
  static const fileAccess = "/file-access";
  static const workflowConfiguration = "/workflow-configuration";

  //components
  static const button = "/button";
  static const textField = "/textField";
  static const datePicker = "/datePicker";
  static const alertPage = "/alertPage";
  static const loadingPage = "/loadingPage";
  static const dropDown = "/dropDown";
  static const popup = "/popup";
  static const textarea = "/textarea";
  static const textEditor = "/textEditor";
  static const tooltip = "/tooltip";
  static const validation = "/validation";
  static const checkbox = "/checkbox";
  static const radioGroup = "/radioGroup";
  static const accordion = "/accordion";
  static const dropdownButton = "/dropdownButton";
  static const tableViewPageOne = "/tableViewPageOne";
  static const tableViewPageTwo = "/tableViewPageTwo";
  static const fileUpload = "/fileUpload";
  static const sectionHeader = "/sectionHeader";
  static const session = "/session";
  static const errorPage = "/errorPage";
  static const dynamicInlineForm = "/dynamicInlineForm";
  static const dropdownTextBox = "/dropdownTextBox";
  static const accessibility = "/accessibility";
  static const accessibilityImage = "/accessibilityImage";
  static const selectableText = "/selectableText";
  static const dynamicForm = "/dynamicForm";
  static const validationPopup = "/validationPopup";
  static const badge = "/badge";
  //request
  static const table = "/table";

  //Profitability and account conduct
  static const facilitySummaryFiView = "facility-summary-fi";
  static const createFacilityFI = "/create-facility-fi";

  //recommendation - approval
  static const ownershipCorporateStructure = "/ownershipCorporateStructure";
  static const groupManagementTeam = "/groupManagementTeam";
  static const successsionkeyManRisk = "/successsionkeyManRisk";
  static const relationshipFutureStrategy = "/relationshipFutureStrategy";

  static const request = "/request";
  static const rational = "/rational";
  static const summaryOfLatestDevelopment = "/summaryOfLatestDevelopment";
  static const bankingSector = "/bankingSector";
  static const fiRecommendation = "/fiRecommendation";

  //file Attachment
  static const appendix = "/appendix";

  //Borrowers Segregation

  //
  static const richTextTinyMCE = "/richTextTinyMCE";
  static const richTextTextControl = "/richTextTextControl";

  static const screenIndex = "/index";
}

void testRoutes() {
  [
    Routes.home,
    Routes.home2,
    Routes.login,
    Routes.selectRole,
    Routes.advancedSearch,
    Routes.closedRequest,
    Routes.requestCreate,
    Routes.applicationBorrowers,
    Routes.groupBorrowers,
    Routes.requestInformation,
    Routes.presentRequest,
    Routes.securityPerfection,
    Routes.terminateWithdraw,
    Routes.customerInformation,
    Routes.sicCodeReview,
    Routes.facilitiesWithCbd,
    Routes.facilitiesWithOtherBanks,
    Routes.riskRating,
    Routes.conditionsSummary,
    Routes.covenantsSummary,
    Routes.securitySummaryView,
    Routes.createSecurity,
    Routes.facilitySecurityLinkage,
    Routes.createFacility,
    Routes.facilitySummaryView,
    Routes.rmCertification,
    Routes.documentationCertification,
    Routes.limitInputCertification,
    Routes.esgCertification,
    Routes.accountStats,
    Routes.businessVolume,
    Routes.accountConduct,
    Routes.strategiesAndComments,
    Routes.incomeSummary,
    Routes.relationshipProfitabilityDetailed,
    Routes.relationshipUtilization,
    Routes.relationshipProfitabilitySummary,
    Routes.shareOfWalletView,
    Routes.remarksCommonTabs,
    Routes.financialRatiosAnalysis,
    Routes.guarantorFinancials,
    Routes.feeStructure,
    Routes.proposedFacilities,
    Routes.groupPosition,
    Routes.limitCaps,
    Routes.guarantorsExposure,
    Routes.queriesAndResponses,
    Routes.comments,
    Routes.requestForFOL,
    Routes.creditAssessment,
    Routes.requestForLimitRelease,
    Routes.managementComments,
    Routes.groupSummary,
    Routes.countrySummary,
    Routes.digitalEFiling,
    Routes.fileAttachment,
    Routes.searchProject,
    Routes.editViewProject,
    Routes.editContract,
    Routes.createProject,
    Routes.linkContract,
    Routes.ccsysRequestInformation,
    Routes.ccsysCustomerInformation,
    Routes.manageReference,
    Routes.adminRoleRight,
    Routes.userList,
    Routes.adminUserDetails,
    Routes.fileAccess,
    Routes.button,
    Routes.textField,
    Routes.datePicker,
    Routes.alertPage,
    Routes.loadingPage,
    Routes.dropDown,
    Routes.popup,
    Routes.textarea,
    Routes.textEditor,
    Routes.tooltip,
    Routes.validation,
    Routes.checkbox,
    Routes.radioGroup,
    Routes.accordion,
    Routes.dropdownButton,
    Routes.tableViewPageOne,
    Routes.tableViewPageTwo,
    Routes.fileUpload,
    Routes.sectionHeader,
    Routes.session,
    Routes.errorPage,
    Routes.dynamicInlineForm,
    Routes.dropdownTextBox,
    Routes.accessibility,
    Routes.accessibilityImage,
    Routes.selectableText,
    Routes.dynamicForm,
    Routes.validationPopup,
    Routes.badge,
    Routes.table,
    Routes.facilitySummaryFiView,
    Routes.ownershipCorporateStructure,
    Routes.groupManagementTeam,
    Routes.successsionkeyManRisk,
    Routes.relationshipFutureStrategy,
    Routes.rational,
    Routes.summaryOfLatestDevelopment,
    Routes.bankingSector,
    Routes.fiRecommendation,
    Routes.richTextTinyMCE,
    Routes.richTextTextControl,
  ];
}
