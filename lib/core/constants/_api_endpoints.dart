part of "constants.dart";

//All local and Mock APIs to be updated here once deployed
class APIEndpoints {
  //Common
  static String saveUIAuditUrl = "${mockAPI}saveUIAuditData";
  // static String getCountries = "${mockAPI}getCountries";
  static String getCountries = "country/getPhoCountryList";
  static String getComments = "reviewComment/getComments";
  static String saveComments = "reviewComment/saveComments";
  static String saveReviewComments = "reviewComment/saveReviewComments";

  static String getCurrencyCode = "rating/getCurrencyList";
  static String mockAPI = "mock/";
  static String gopiLocal = "http://10.220.167.18:8080/wcas/";
  static String vishnuLocal = "http://10.220.162.182:8080/wcas/";
  static String anwarLocal = "http://10.220.167.42:8080/wcas/";
  static String sheejaLocal = "http://10.220.160.192:8080/wcas/";
  static String seemaLocal = "http://10.220.167.2:8080/wcas/";

//auth
  static String login = "auth/validateUser";
  static String refreshToken = "auth/regenerateToken";
  static String updateUserRole = "auth/updateUserRole";
  static String logout = "auth/updateLogout";
  static String referenceData = "referenceData/getReferenceData";
  static String getAuthRoleRightMap = "auth/getRoleRightMapping";

  //Draft
  static String saveDraft = "autosave/saveAutoSavedData";
  static String getDraft = "autosave/getAutoSavedData";
  static String deleteDraft = "autosave/deleteAutoSavedDraft";

  //Admin
  static String getRoleRightMap = "referenceData/getRoleRightMap";
  static String saveRoleRightMap = "referenceData/saveRoleRightMap";
  static String getUsersList = "userManagement/getUserList";
  static String configurableReferenceData =
      "referenceData/getConfigurableReferenceData";
  static String getReferenceData = "referenceData/getReferenceData";
  static String saveConfigurableReferenceData =
      "referenceData/saveConfigurableReferenceData";

  static String getAdminUserDetails = "userManagement/getUserDetails";
  static String saveAdminUserDetails = "userManagement/saveUserDetail";
  static String getLoggedUserDetails = "auth/getLoggedUserDetails";

  //Appendix
  static String getAppendixImage = "appendix/getAppendixImage";
  static String saveAppendixImage = "appendix/saveAppendixImage";
  static String deleteAppendixImage = "appendix/deleteAppendixImage";
  static String saveAppendixBusinnesSegment =
      "appendix/saveAppendixBusinnesSegment";
  static String getAppendixBusinessSegement =
      "appendix/getAppendixBusinessSegement";
  static String getAppendixComment = "appendix/getAppendixComment";
  static String saveAppendixComment = "appendix/saveAppendixComment";
  static String deleteReview = "appendix/deleteReview";
  static String deletAppendixComment = "appendix/removeAppendixComment";
  static String extractAppendixXlsx = "appendix/extractxlsx";
  static String deleteExtractAppendixXlsx = "appendix/deleteExtractXlsx";
  static String fetchAppendixXlsx = "appendix/getAppendixXlsx";

  //Request
  static String getCustomerProfile =
      "customerprofile/getCustomerProfileByPartyInq";
  static String getUserByRole = "apim/bpm/getUsersByRoles";
  static String getApplicableReconApplication =
      "requestInfo/getApplicableReconApplication";
  static String getBorrowerNonBorrower = "requestInfo/getBorrowersNonBorrowers";

  static String getProducts = "";
  static String validateSubSegment = "requestInfo/validateSubSegment";
  static String getProductDetail(int id) {
    return "${mockAPI}admin/api/products/view/$id";
  }

  /// Customer information
  static String searchPartyInq = "partyInq/getCustomerProfile";
  static String getChildRimsForGroup = "customer-info/getChildRimsForGroup";
  static String getCustomerInformationByRim =
      "customer-info/getCustomerInformationDetails";
  static String saveCustomerInformation =
      "customer-info/saveCustomerInformationDetails";
  static String getSICCodeReview = "customer-info/getSICCodeReviewByCustInfoId";
  static String saveSICcodeReview =
      "customer-info/saveSICCodeReviewByAppRefNoAndRIM";

  //File Attachment & Digital eFiling
  static String getFileAccessRight = "referenceData/getFileAccessRight";
  static String getFiles = "nafs/files";
  static String uploadDocuments = "nafs/store-batch";
  static String uploadDocumentsMultipart = "nafs/store-batch-mp";
  static String getCompanyRims = "api/application/group/rims";
  static String uploadDigitalDocuments =
      "api/edms/insertDocumentByRepositoryBatch";
  static String uploadDigitalDocumentsMultipart =
      "api/edms/insertDocumentByRepositoryBatch/multipart";
  static String downloadFile = "nafs/download";
  static String deleteFile = "nafs/delete";
  static String getFileUploadDatas = "api/edms/tree/build";
  static String downloadFileDigital = "api/edms/downloadDocumentByRepository";
  static String mergeDownloadFileDigital = "api/edms/merge-download";
  static String zipDownloadFileDigital = "api/edms/download-files-zip";
  static String linkToApplication = "api/edms/link/sharepoint";
  static String getCustomerInformationByRimOwnership =
      "customer-info/getCustomerOwnershipDetails";

  static String getCustomerInformationByRimException =
      "customer-info/getBorrowerExcptionsByCustomerInfo";

  static String saveCustomerOwnerShipInfo =
      "customer-info/saveCustomerInformationDetails";

  static String deleteOwnership = "customer-info/deleteCustomerOwnershipDetail";

  static String deleteException = "customer-info/deleteBorrowerExcption";

  static String getCustomerRequestInfo = "${mockAPI}getPipelineRequestDetails";
  static String getReviewComments = "${mockAPI}getReviewComments";
  static String updateTerminatedStatus = "requestInfo/updateTerminatedStatus";
  static String getApplicationDetails = "requestInfo/getApplicationDetails";
  static String getLastApprovedApplications =
      "requestInfo/getLastApprovedApplication";
  static String getApplicationBorrowers = "${mockAPI}getApplicationBorrowers";
  static String saveApplicationInformation =
      "requestInfo/saveApplicationInformation";

  //ccsys
  static String getCustomerInformationCCSYS =
      "ccsys/customerInformation/getCustomerInfo";
  static String saveCustomerInformationCCSYS =
      "ccsys/customerInformation/saveCustomerInfo";
  static String getApplicationDetailsCCSYS =
      "ccsys/requestInformation/getApplicationDetails";
  static String getCcsysCustomerProfile = "ccsys/createModule/getPartyDetails";
  static String saveCcsysApplicationInformation =
      "ccsys/requestInformation/saveApplicationInformation";
  static String getCcsysLastApprovedApplicationDetails =
      "ccsys/requestInformation/getLastApprovedApplicationDetails";
  static String saveCcsysCustomerInfo =
      "ccsys/customerInformation/saveCustomerInfo";
  static String getCcsysCustomerInfo =
      "ccsys/customerInformation/getCustomerInfo";
  static String getLastAssignedRoleCCSYS = "approvals/getLastAssignedRole";
  static String submitApplicationCCSYS = "ccsys/approvals/submitApplication";

  ///File Attachment

  static String getFileAttachments = "referenceData/getFileAccessRight";
  static String saveFileAttachments = "referenceData/saveFileAccessRight";

  /// Dashboard
  static String getSummary = "dashboard/getDashboardSummaryCount";
  static String getDashboardAgeingCount = "dashboard/getDashboardAgeingCount";
  static String getDocumentationSummary = "dashboard/getDocumentationSummary";
  static String getRequestDetailsWorkList = "dashboard/getWorklist";
  static String getWorklistForBarGraph = "dashboard/getWorklistForBarGraph";
  static String getUsersByRoles = "apim/bpm/getUsersByRoles";
  static String assignToUser = "apim/bpm/assignToUser";
  static String getClosedRequestDetailsWorkList = "dashboard/getWorklist";

  static String getRolesByUser = "dashboard/getRolesByUser";
  static String getDashboardRoleMapList = "approvals/getDashboardRoleMapList";
  static String getWorklistForSearchCriteria =
      "dashboard/getWorklistForSearchCriteria";

//Condition -Covenant
  static String getCovenants = "covenants/getCovenants";
  static String saveCovenants = "covenants/saveCovenants";
  static String getConditions = "conditions/getConditions";
  static String saveConditions = "conditions/saveConditions";
  static String getStategyComment = "appStrategyComment/getStrategyComment";
  static String saveStategyComment = "appStrategyComment/saveStrategyComment";

  //Profitability
  static String getBussinessVolume = "profitability/getBusinessVolume";
  static String saveBussinessVolume = "profitability/saveBusinessVolume";
  static String getAccountStats = "profitability/getAccountStats";
  static String getAccountConductData = "profitability/getAccountConduct";

  static String saveAccountConductData = "profitability/saveAccountConduct";
  static String getRelationshipUtilization =
      "profitability/getRelationshipUtilization";
  static String saveRelationshipUtilization =
      "profitability/saveRelationshipUtilization";
  static String getRelationshipProfitabilityDetailed =
      "profitability/getIncomeSummary";
  static String getRelProfitDetComments = "${mockAPI}getRelProfitDetComments";
  static String getrelationshipProfitabilitySummary =
      "profitability/getProfitabilityRAROC";
  static String postRelationshipProfitabilitySummary =
      "profitability/saveProfitabilityRAROC";
  static String getStrategyComments = "${mockAPI}getStrategyComments";
  static String saveStrategyComments = "${mockAPI}postStrategyComments";
  static String getShareofWallet = "profitability/getShareOfWallet";
  static String getIncomeSummary = "profitability/getIncomeSummary";
  static String saveIncomeSummary = "profitability/saveIncomeSummary";

  /// Risk rating
  static String getRatingDetails = "riskRating/getRatingDetails";
  static String getUpdatedRating = "riskRating/getUpdatedRating";
  static String saveRatingDetailsUpdated = "riskRating/saveRatingDetails";

  //facility api
  static String getFacilitySummaryListPerRim =
      "facility/getFacilitySummaryListPerRim";
  static String getProjectList = "facility/getProjectList";
  static String getLimitsandFacilities = "facility/getLimitsandFacilities";
  static String saveFacilityDetailsNew = "facility/saveFacilityDetails";
  static String getExchangeRate = "rating/getExchangeRate";
  static String getFacilityDetails = "facility/getFacilityDetails";
  static String getFacilityConditionsList =
      "facility/getFacilityConditionsList";
  static String saveFacilitySummaryList = "facility/saveFacilitySummaryList";
  static String getBorrowersMap = "facility/getBorrowersMap";
  static String getBorrowers = "facility/getBorrowers";

  static String getSecurityDetails = "security/getSecurityDetails";
  static String saveSecurityDetails = "security/saveSecurityDetails";
  static String getSecuritySummaryList = "security/getSecuritySummaryList";
  static String deleteFacilityItem = "facility/deleteFacility";

  static String getSecurityDynamicForm = "security/getDynamicFormData";
  static String saveFacilitySecurityLinkDetails =
      "security/saveFacilitySecurityLinkDetails";
  static String getStandardConditions = "${mockAPI}getStandardConditions";

  static String getFacilities =
      "security/getFacilitySummaryList"; //for covenant dialog requiured
  static String getFeeDefaultRates = "${mockAPI}getFacilityFeeDefaultRates";
  static String deleteSecurityDetails = "security/deleteSecurity";
  static String getFacilitiesDynamicForm = "${mockAPI}getFacilitiesDynamicForm";
  static String saveFacilitiesDetails = "${mockAPI}saveFacilityDetails";

  static String saveFacilitySubLimit = "${mockAPI}saveFacilitySubLimit";
  static String getFacilitySubTypes = "${mockAPI}getFacilitySubTypes";
  static String getControllingLimitNoData =
      "facility/getControllingLimitNumData";

// Certificate
  static String getCertificateDetails = "certifications/getCertificateDetails";
  static String saveCertificateDetails =
      "certifications/saveCertificateDetails";
  static String getEsgCertificateDetails =
      "certifications/getEsgCertificationsDetails";
  static String saveEsgCertificationDetails =
      "certifications/saveEsgCertificationsDetails";

  /// Group information
  static String getGroupInformation = "groupInfo/getGroupInformation";
  static String getFacilityWithOtherBank = "groupInfo/getOtherBankFacilities";
  static String getShareofWalletDetails = "groupInfo/getShareOfWalletDetails";
  static String saveFacilityWithOtherBank = "groupInfo/saveOtherBankFacilities";
  static String getLinkedFacilities = "groupInfo/getLinkedFacilities";
  static String getApplicationStrategyDetails =
      "requestInfo/getApplicationStrategyDetails";
  static String saveApplicationStrategyDetails =
      "requestInfo/saveApplicationStrategyDetails";
  static String saveCBRBData = "groupInfo/saveCBRBData";
  static String deletCBRBInformation = "groupInfo/deletCBRBInformation";
  static String deleteWithOtherBank = "groupInfo/deleteWithOtherBank";

  static String uploadDocument = "${mockAPI}uploadDocument";

  ///Project
  static String getProjectDetails = "${mockAPI}getProjectDetails";
  static String getLinkContract = "${mockAPI}getLinkCommitmentNumber";
  static String getPerPartyLimit = "${mockAPI}getPerPartyLimit";

  static String getContractByContractCodeDetails =
      "contract/getContractByContractCode";
  static String getLinkedCMNForRimDetails = "contract/getLinkedCMNForRim";

  static String saveProjectDetails = "project/saveProject";
  static String getContractDetails = "contract/getContractors";
  static String saveContractDetails = "contract/saveContract";
  static String getSearchProjectDetails = "project/getProjectByProject";
  static String getSearchProjectDetailsContract =
      "project/getProjectByContract";
  static String getProjectBorrower = "project/getBorrower";

  //Approval
  static String getGroupPositionDetails = "approvals/getGroupPositionDetails";
  //static String getProposedFacilities = "${mockAPI}getProposedFacilities";
  static String getQueryResponse = "/getQueryResponse";
  // static String getCompanyLimitDetails =
  //     "${mockAPI}approvals/getCompanyLimitDetails";
  static String getCompanyLimitDetails = "approvals/getCompanyLimitDetails";
  // static String getGuarantorExposure =
  //     "${mockAPI}approvals/getGuarantorExposure";
  static String getGuarantorExposure = "approvals/getGuarantorExposure";
  static String submitApplicationApproval = "approvals/submitApplication";
  static String validateApproval = "approvals/validateApproval";

  static String getGroupCustomers = "${mockAPI}getGroupCustomers";
  static String getCustomerByRim = "requestInfo/getPotentialRim";
  // "${mockAPI}getCustomerByRim";
  static String getSecurityDeferral = "requestInfo/getSecurityDeferralDetails";
  static String saveSecurityDeferralDetails =
      "requestInfo/saveSecurityDeferralDetails";

  // Output Forms
  static String getOutputForms = "outputForm/getPreviewList";
  static String generateProjectExposureSummary =
      "outputForm/generateProjectExposureSummary";
  static String generateFICountryForm = "outputForm/generateFICountryForm";
  static String generateMarkForward = "outputForm/generateMarkForward";
  static String generateFIInvestmentGradeBank =
      "outputForm/generateFIInvestmentGradeBank";
  static String generateGroupExposureSummary =
      "outputForm/generateGroupExposureSummary";
  static String generateCAPart1 = "outputForm/corporate/generateCAPartOne";
  static String generateCAPart2 = "outputForm/corporate/generateCAPartTwo";
  static String generateIsolatedMemo =
      "outputForm/corporate/generateIsolatedMemo";
  static String generateTermSheet = "outputForm/corporate/generateTermSheet";
  static String generateSummaryOfChanges =
      "outputForm/corporate/generateSummaryOfChanges";
  static String generateFIAnnexure = "outputForm/generateFIAnnexure";
  static String generateFIBelowInvGrd = "outputForm/generateFIBelowInvGrd";
  static String generateAppendixII = "outputForm/generateAppendixII";

  static String getPipelineRequestDetails =
      "requestInfo/getPipelineRequestDetails";
  static String getLegalAndLimitDetails = "approvals/getLegalAndLimitDetails";

  //Remarks
  static String getRelationshipStrategyDetailsByRim =
      "remarks/getRelationshipStrategyDetailsByRim";
  static String saveRelationshipStrategyDetailsByRim =
      "remarks/saveRelationshipStrategyDetailsByRim";
  static String getFeeStructureData = "remarks/getFeeStructureDetails";
  static String saveFeeStructureData = "remarks/saveFeeStructureDetails";
  static String deleteFeeStructureData = "remarks/deleteFeeStructureDetails";
  static String getFinancialDataFromCreditLens =
      "remarks/getFinancialDetailsFromCreditLens";
  static String getFinancialRatioAnalysisDetails =
      "remarks/getFinancialRatioAnalysisDetails";
  static String saveFinancialRatioAnalysisDetails =
      "remarks/saveFinancialRatioAnalysisDetails";
  // static String submitApplicationApproval = "approvals/submitApplication";
  static String deleteFinancialRatioAnalysisDetails =
      "remarks/deleteFinancialRatioAnalysisDetails";
  static String deleteGuarantorDetails = "remarks/deleteGuarantorDetails";
  static String deleteGuarantorDetailsByEntityId =
      "remarks/deleteGuarantorDetailsByEntityId";
  static String saveGuarantorFinancialDetails =
      "remarks/saveGuarantorFinancialDetails";
  static String getGuarantorFinancialDetails =
      "remarks/getGuarantorFinancialDetails";
  static String saveCleanExposureInfo = "approvals/saveCleanExposureInfo";
  static String getCleanExposureInfo = "approvals/getCleanExposureInfo";
  static String validateRSAToken = "approvals/validateRSAToken";
}

void testEndpoints() {
  APIEndpoints.mockAPI;
  APIEndpoints.login;
  APIEndpoints.refreshToken;
  APIEndpoints.getRoleRightMap;
  APIEndpoints.updateUserRole;
  APIEndpoints.logout;
  APIEndpoints.saveRoleRightMap;
  APIEndpoints.referenceData;
  APIEndpoints.getCustomerProfile;
  APIEndpoints.getUserByRole;
  APIEndpoints.getUsersList;
  APIEndpoints.getApplicableReconApplication;
  APIEndpoints.getPipelineRequestDetails;
  APIEndpoints.saveUIAuditUrl;
  APIEndpoints.getCustomerRequestInfo;
  APIEndpoints.configurableReferenceData;
  APIEndpoints.saveConfigurableReferenceData;
  APIEndpoints.getReviewComments;
  APIEndpoints.assignToUser;
  APIEndpoints.updateTerminatedStatus;
  APIEndpoints.getAdminUserDetails;
  APIEndpoints.saveAdminUserDetails;
  APIEndpoints.getApplicationStrategyDetails;
  APIEndpoints.saveApplicationStrategyDetails;
  APIEndpoints.getCertificateDetails;
  APIEndpoints.saveCertificateDetails;
  APIEndpoints.getApplicationDetails;
  APIEndpoints.getCustomerInformationByRim;
  APIEndpoints.getCountries;
  APIEndpoints.saveCustomerInformation;
  APIEndpoints.getFileAttachments;
  APIEndpoints.saveFileAttachments;
  APIEndpoints.getSummary;
  APIEndpoints.getDocumentationSummary;
  APIEndpoints.getRequestDetailsWorkList;
  APIEndpoints.getEsgCertificateDetails;
  APIEndpoints.saveEsgCertificationDetails;
  APIEndpoints.getCovenants;
  APIEndpoints.getConditions;
  APIEndpoints.saveConditions;
  APIEndpoints.getUsersByRoles;
  APIEndpoints.getCcsysCustomerInfo;
  APIEndpoints.getFacilities;
  APIEndpoints.getComments;
  APIEndpoints.saveComments;
  APIEndpoints.saveCovenants;
  APIEndpoints.getSICCodeReview;
  APIEndpoints.saveSICcodeReview;
  APIEndpoints.getAccountConductData;
  APIEndpoints.saveAccountConductData;

  APIEndpoints.getRelationshipUtilization;
  APIEndpoints.saveRelationshipUtilization;

  APIEndpoints.getRelationshipProfitabilityDetailed;
  APIEndpoints.getRelProfitDetComments;
  APIEndpoints.getrelationshipProfitabilitySummary;
  APIEndpoints.postRelationshipProfitabilitySummary;
  APIEndpoints.getStrategyComments;
  APIEndpoints.saveStrategyComments;
  APIEndpoints.getShareofWallet;
  APIEndpoints.getIncomeSummary;
  APIEndpoints.saveIncomeSummary;

  APIEndpoints.getRatingDetails;
  APIEndpoints.getUpdatedRating;
  APIEndpoints.saveRatingDetailsUpdated;
  APIEndpoints.getSecuritySummaryList;
  APIEndpoints.getFacilitySummaryListPerRim;
  APIEndpoints.saveFacilitySecurityLinkDetails;
  APIEndpoints.saveSecurityDetails;
  APIEndpoints.deleteSecurityDetails;
  APIEndpoints.getGroupInformation;
  APIEndpoints.getFacilityWithOtherBank;
  APIEndpoints.getShareofWalletDetails;
  APIEndpoints.saveFacilityWithOtherBank;
  APIEndpoints.getBussinessVolume;
  APIEndpoints.saveBussinessVolume;
  APIEndpoints.getAccountStats;
  APIEndpoints.getLinkedFacilities;

  APIEndpoints.getSecurityDynamicForm;
  APIEndpoints.getCurrencyCode;
  APIEndpoints.getFacilitiesDynamicForm;

  APIEndpoints.saveProjectDetails;
  APIEndpoints.getProjectDetails;
  APIEndpoints.getContractDetails;
  APIEndpoints.getLinkContract;
  APIEndpoints.getPerPartyLimit;
  APIEndpoints.saveContractDetails;
  APIEndpoints.getGroupPositionDetails;
  //APIEndpoints.getProposedFacilities;
  APIEndpoints.getQueryResponse;
  APIEndpoints.getCompanyLimitDetails;
  APIEndpoints.getGroupCustomers;
  APIEndpoints.getCustomerByRim;
  APIEndpoints.getSecurityDeferral;
  APIEndpoints.getApplicationBorrowers;
  APIEndpoints.saveApplicationInformation;
  APIEndpoints.saveCcsysApplicationInformation;
  APIEndpoints.getCcsysLastApprovedApplicationDetails;

  APIEndpoints.saveCcsysCustomerInfo;

  APIEndpoints.getOutputForms;
  APIEndpoints.deleteFacilityItem;
  APIEndpoints.saveFacilitySubLimit;
  APIEndpoints.getSearchProjectDetails;
  APIEndpoints.getFeeStructureData;
  APIEndpoints.saveFeeStructureData;
  APIEndpoints.getClosedRequestDetailsWorkList;
}
