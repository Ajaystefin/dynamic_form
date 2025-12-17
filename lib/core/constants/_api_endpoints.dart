part of 'constants.dart';

//All local and Mock APIs to be updated here once deployed
class APIEndpoints {
  //Common
  static String saveUIAuditUrl = "${mockAPI}saveUIAuditData";
  // static String getCountries = "${mockAPI}getCountries";
  static String getCountries = "country/getPhoCountryList";
  static String getComments = "reviewComment/getComments";
  static String saveComments = "reviewComment/saveComments";
  static String getRatesInq = "${mockAPI}RatesInq";
  static String getCountryCode = "${mockAPI}RatesInq";
  static String mockAPI = "mock/";

  //auth
  static String login = "auth/validateUser";
  static String refreshToken = "auth/regenerateToken";
  static String updateUserRole = "auth/updateUserRole";
  static String logout = "auth/updateLogout";
  static String referenceData = "referenceData/getReferenceData";
  static String getAuthRoleRightMap = "auth/getRoleRightMapping";

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
  static String getCompanyRims = "api/application/group/rims";
  static String uploadDigitalDocuments =
      "api/edms/insertDocumentByRepositoryBatch";
  static String downloadFile = "nafs/download";
  static String deleteFile = "nafs/delete";
  static String getFileUploadDatas =
      "api/edms/tree/build"; //"${mockAPI}rowFileUploadData_1";
  static String downloadFileDigital = "api/edms/downloadDocumentByRepository";
  static String mergeDownloadFileDigital = "api/edms/merge-download";
  static String zipDownloadFileDigital = "api/edms/download-files-zip";

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

  ///File Attachment

  static String getFileAttachments = "referenceData/getFileAccessRight";
  static String saveFileAttachments = "referenceData/saveFileAccessRight";

  /// Dashboard
  static String getSummary = "dashboard/getDashboardSummaryCount";
  static String getDashboardAgeingCount = "dashboard/getDashboardAgeingCount";
  static String getDocumentationSummary = "dashboard/getDocumentationSummary";
  static String getRequestDetailsWorkList = "dashboard/getWorklist";
  static String getUsersByRoles = "apim/bpm/getUsersByRoles";
  static String assignToUser = "apim/bpm/assignToUser";
  static String getClosedRequestDetailsWorkList = "dashboard/getWorklist";

  static String getRolesByUser = "dashboard/getRolesByUser";
  static String getWorklistForSearchCriteria =
      "dashboard/getWorklistForSearchCriteria";

//Condition -Covenant
  static String getCovenants = "covenants/getCovenants";
  static String getConditions = "conditions/getConditions";
  static String saveConditions = "conditions/saveConditions";
  static String saveCovenants = "covenants/saveCovenants";
  static String getStategyComment = "appStrategyComment/getStrategyComment";
  static String saveStategyComment = "appStrategyComment/saveStrategyComment";

  //Profitability
  static String getBussinessVolume = "profitability/getBusinessVolume";
  static String saveBussinessVolume = "profitability/saveBusinessVolume";
  static String getAccountStats = "profitability/getAccountStats";
  static String getAccountConductData = "${mockAPI}getAccountConduct";
  static String getRelationshipUtilization =
      "${mockAPI}getRelationshipUtilization";
  static String getRelationshipProfitabilityDetailed =
      "${mockAPI}getRelationshipProfitabilityDetailed";
  static String getRelProfitDetComments = "${mockAPI}getRelProfitDetComments";
  static String getrelationshipProfitabilitySummary =
      "${mockAPI}getrelationshipProfitabilitySummary";
  static String postRelationshipProfitabilitySummary =
      "${mockAPI}postRelationshipProfitabilitySummary";
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
  static String getFacilitySummaryList =
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
  static String saveFacilityDetails = "${mockAPI}saveFacilityDetails";

  static String saveFacilitySubLimit = "${mockAPI}saveFacilitySubLimit";
  static String getFacilitySubTypes = "${mockAPI}getFacilitySubTypes";
  static String getControllingLimitNoData =
      "http://10.220.165.77:8081/wcas/facility/getControllingLimitNumData";

// Certificate
  static String getCertificateDetails = "certifications/getCertificateDetails";
  static String saveCertificateDetails =
      "certifications/saveCertificateDetails";
  static String getEsgCertificateDetails =
      "certifications/getEsgCertificationsDetails";
  static String saveEsgCertificationDetails =
      "certifications/saveEsgCertificationsDetails";

  /// Group information
  static String getGroupInformation = "${mockAPI}getGroupInformation";
  static String getFacilityWithOtherBank = "${mockAPI}getFacilityWithOtherBank";
  static String getShareofWalletDetails = "${mockAPI}getShareofWalletDetails";
  static String saveFacilityWithOtherBank =
      "${mockAPI}saveFacilityWithOtherBank";
  static String getLinkedFacilities = "${mockAPI}getLinkedFacilities";
  static String getApplicationStrategyDetails =
      "requestInfo/getApplicationStrategyDetails";
  static String saveApplicationStrategyDetails =
      "requestInfo/saveApplicationStrategyDetails";

  static String uploadDocument = "${mockAPI}uploadDocument";

  ///Project
  static String saveProjectDetails = "${mockAPI}saveProjectDetails";
  static String getProjectDetails = "${mockAPI}getProjectDetails";
  static String getContractDetails = "${mockAPI}getContractDetails";
  static String getLinkContract = "${mockAPI}getLinkCommitmentNumber";
  static String getPerPartyLimit = "${mockAPI}getPerPartyLimit";
  static String saveContractDetails = "${mockAPI}saveContractDetails";
  static String getSearchProjectDetails = "${mockAPI}getSearchProjectDetails";

  //Approval
  static String getProposedFacilities = "${mockAPI}getProposedFacilities";
  static String getQueryResponse = "${mockAPI}getQueryResponse";
  static String getCompanyLimitDetails =
      "${mockAPI}approvals/getCompanyLimitDetails";
  static String getGuarantorExposure =
      "${mockAPI}approvals/getGuarantorExposure";
  static String getGroupCustomers = "${mockAPI}getGroupCustomers";
  static String getCustomerByRim = "requestInfo/getPotentialRim";
  // "${mockAPI}getCustomerByRim";
  static String getSecurityDeferral = "${mockAPI}getSecurityDeferralDetails";
  static String getOutputForms = "${mockAPI}getOutputForms";
  static String getPipelineRequestDetails =
      "requestInfo/getPipelineRequestDetails";
  static String getLegalAndLimitDetails =
      "${mockAPI}approvals/getLegalAndLimitDetails";

  //Remarks
  static String getRelationshipStrategyDetailsByRim =
      "remarks/getRelationshipStrategyDetailsByRim";
  static String saveRelationshipStrategyDetailsByRim =
      "remarks/saveRelationshipStrategyDetailsByRim";
  static String getFeeStructureData = "remarks/getFeeStructureDetails";
  static String saveFeeStructureData = "remarks/saveFeeStructureDetails";
  static String deleteFeeStructureData = "remarks/deleteFeeStructureDetails";
  static String getFinancialDataFromCreditLens =
      "${mockAPI}remarks/getFinancialDetailsFromCreditLens";
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

  APIEndpoints.getFacilities;
  APIEndpoints.getComments;
  APIEndpoints.saveComments;
  APIEndpoints.saveCovenants;
  APIEndpoints.getSICCodeReview;
  APIEndpoints.saveSICcodeReview;
  APIEndpoints.getAccountConductData;
  APIEndpoints.getRelationshipUtilization;
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
  APIEndpoints.getFacilitySummaryList;
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
  APIEndpoints.getRatesInq;
  APIEndpoints.getSecurityDynamicForm;
  APIEndpoints.getCountryCode;
  APIEndpoints.getFacilitiesDynamicForm;
  APIEndpoints.saveFacilitiesDetails;
  APIEndpoints.saveProjectDetails;
  APIEndpoints.getProjectDetails;
  APIEndpoints.getContractDetails;
  APIEndpoints.getLinkContract;
  APIEndpoints.getPerPartyLimit;
  APIEndpoints.saveContractDetails;
  APIEndpoints.getProposedFacilities;
  APIEndpoints.getQueryResponse;
  APIEndpoints.getCompanyLimitDetails;
  APIEndpoints.getGroupCustomers;
  APIEndpoints.getCustomerByRim;
  APIEndpoints.getSecurityDeferral;
  APIEndpoints.getApplicationBorrowers;
  APIEndpoints.saveApplicationInformation;
  APIEndpoints.getOutputForms;
  APIEndpoints.saveFacilityDetails;
  APIEndpoints.deleteFacilityItem;
  APIEndpoints.saveFacilitySubLimit;
  APIEndpoints.getSearchProjectDetails;
  APIEndpoints.getFeeStructureData;
  APIEndpoints.saveFeeStructureData;
  APIEndpoints.getClosedRequestDetailsWorkList;
}
