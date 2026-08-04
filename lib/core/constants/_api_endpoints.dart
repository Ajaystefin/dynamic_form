part of "constants.dart";

/// Contains API endpoint definitions used throughout the application.
///
/// All local and mock API endpoints should be updated here once deployed.
class APIEndpoints {
  /// Common

  /// Endpoint used to save UI audit data.
  static String saveUIAuditUrl = "${mockAPI}saveUIAuditData";

  /// Endpoint used to retrieve the country list.
  static String getCountries = "country/getPhoCountryList";

  /// Endpoint used to retrieve review comments.
  static String getComments = "reviewComment/getComments";

  /// Endpoint used to save comments.
  static String saveComments = "reviewComment/saveComments";

  /// Endpoint used to save review comments.
  static String saveReviewComments = "reviewComment/saveReviewComments";

  /// Endpoint used to retrieve currency codes.
  static String getCurrencyCode = "rating/getCurrencyList";

  /// Endpoint used to retrieve exchange rates for all currencies.
  static String getCurrencyRateList = "rating/getCurrencyList";

  /// Base mock API path.
  static String mockAPI = "mock/";

  /// Authentication API endpoints.

  /// Endpoint used to validate user credentials.
  static String login = "auth/validateUser";

  /// Endpoint used to regenerate an authentication token.
  static String refreshToken = "auth/regenerateToken";

  /// Endpoint used to update the user's active role.
  static String updateUserRole = "auth/updateUserRole";

  /// Endpoint used to update user logout status.
  static String logout = "auth/updateLogout";

  /// Endpoint used to retrieve reference data.
  static String referenceData = "referenceData/getReferenceData";

  /// Endpoint used to retrieve role-right mappings.
  static String getAuthRoleRightMap = "auth/getRoleRightMapping";

  /// Draft management API endpoints.

  /// Endpoint used to save auto-saved draft data.
  static String saveDraft = "autosave/saveAutoSavedData";

  /// Endpoint used to retrieve auto-saved draft data.
  static String getDraft = "autosave/getAutoSavedData";

  /// Endpoint used to delete an auto-saved draft.
  static String deleteDraft = "autosave/deleteAutoSavedDraft";

  /// Administration API endpoints.

  /// Endpoint used to retrieve role-right mappings.
  static String getRoleRightMap = "referenceData/getRoleRightMap";

  /// Endpoint used to save role-right mappings.
  static String saveRoleRightMap = "referenceData/saveRoleRightMap";

  /// Endpoint used to retrieve the user list.
  static String getUsersList = "userManagement/getUserList";

  /// Endpoint used to retrieve configurable reference data.
  static String configurableReferenceData =
      "referenceData/getConfigurableReferenceData";

  /// Endpoint used to retrieve reference data.
  static String getReferenceData = "referenceData/getReferenceData";

  /// Endpoint used to save configurable reference data.
  static String saveConfigurableReferenceData =
      "referenceData/saveConfigurableReferenceData";

  /// Endpoint used to retrieve user details.
  static String getAdminUserDetails = "userManagement/getUserDetails";

  /// Endpoint used to save user details.
  static String saveAdminUserDetails = "userManagement/saveUserDetail";

  /// Endpoint used to retrieve details of the currently logged-in user.
  static String getLoggedUserDetails = "auth/getLoggedUserDetails";

  /// Appendix API endpoints.

  /// Endpoint used to retrieve appendix images.
  static String getAppendixImage = "appendix/getAppendixImage";

  /// Endpoint used to save appendix images.
  static String saveAppendixImage = "appendix/saveAppendixImage";

  /// Endpoint used to delete appendix images.
  static String deleteAppendixImage = "appendix/deleteAppendixImage";

  /// Endpoint used to save appendix business segment data.
  static String saveAppendixBusinnesSegment =
      "appendix/saveAppendixBusinnesSegment";

  /// Endpoint used to retrieve appendix business segment data.
  static String getAppendixBusinessSegement =
      "appendix/getAppendixBusinessSegement";

  /// Endpoint used to retrieve appendix comments.
  static String getAppendixComment = "appendix/getAppendixComment";

  /// Endpoint used to save appendix comments.
  static String saveAppendixComment = "appendix/saveAppendixComment";

  /// Endpoint used to delete an appendix review.
  static String deleteReview = "appendix/deleteReview";

  /// Endpoint used to remove an appendix comment.
  static String deletAppendixComment = "appendix/removeAppendixComment";

  /// Endpoint used to extract appendix XLSX data.
  static String extractAppendixXlsx = "appendix/extractxlsx";

  /// Endpoint used to delete extracted appendix XLSX data.
  static String deleteExtractAppendixXlsx = "appendix/deleteExtractXlsx";

  /// Endpoint used to retrieve appendix XLSX data.
  static String fetchAppendixXlsx = "appendix/getAppendixXlsx";

  /// Request-related API endpoints.

  /// Endpoint used to retrieve customer profile information by party inquiry.
  static String getCustomerProfile =
      "customerprofile/getCustomerProfileByPartyInq";

  /// Endpoint used to retrieve applicable reconsideration applications.
  static String getApplicableReconApplication =
      "requestInfo/getApplicableReconApplication";

  /// Endpoint used to retrieve borrower and non-borrower information.
  static String getBorrowerNonBorrower = "requestInfo/getBorrowersNonBorrowers";

  /// Endpoint used to validate the selected sub-segment.
  static String validateSubSegment = "requestInfo/validateSubSegment";

  /// Returns the endpoint used to retrieve product details by identifier.
  static String getProductDetail(int id) {
    return "${mockAPI}admin/api/products/view/$id";
  }

  /// Customer information API endpoints.

  /// Endpoint used to search and retrieve customer profile information.
  static String searchPartyInq = "partyInq/getCustomerProfile";

  /// Endpoint used to retrieve child RIMs for a group.
  static String getChildRimsForGroup = "customer-info/getChildRimsForGroup";

  /// Endpoint used to retrieve customer information by RIM.
  static String getCustomerInformationByRim =
      "customer-info/getCustomerInformationDetails";

  /// Endpoint used to save customer information details.
  static String saveCustomerInformation =
      "customer-info/saveCustomerInformationDetails";

  /// Endpoint used to retrieve SIC code review details.
  static String getSICCodeReview = "customer-info/getSICCodeReviewByCustInfoId";

  /// Endpoint used to save SIC code review details.
  static String saveSICcodeReview =
      "customer-info/saveSICCodeReviewByAppRefNoAndRIM";

  /// File Attachment and Digital eFiling API endpoints.

  /// Endpoint used to retrieve file access rights.
  static String getFileAccessRight = "referenceData/getFileAccessRight";

  /// Endpoint used to retrieve files from NAFS.
  static String getFiles = "nafs/files";

  /// Endpoint used to retrieve legacy files from sharepoint.
  static String getLegacyFiles = "api/edms/legacyfiles";

  /// Endpoint used to upload documents using multipart requests.
  static String uploadDocumentsMultipart = "nafs/store-batch-mp";

  /// Endpoint used to retrieve company RIM information.
  static String getCompanyRims = "api/application/group/rims";

  /// Endpoint used to upload digital documents using multipart requests.
  static String uploadDigitalDocumentsMultipart =
      "api/edms/insertDocumentByRepositoryBatch/multipart";

  /// Endpoint used to download a file from NAFS.
  static String downloadFile = "nafs/download";

  /// Endpoint used to delete a file from NAFS.
  static String deleteFile = "nafs/delete";

  /// Endpoint used to retrieve file upload tree data.
  static String getFileUploadDatas = "api/edms/tree/build";

  /// Endpoint used to download a digital document.
  static String downloadFileDigital = "api/edms/downloadDocumentByRepository";

  /// Endpoint used to download merged digital documents.
  static String mergeDownloadFileDigital = "api/edms/merge-download";

  /// Endpoint used to download multiple digital documents as a ZIP archive.
  static String zipDownloadFileDigital = "api/edms/download-files-zip";

  /// Endpoint used to link documents to an application in SharePoint.
  static String linkToApplication = "api/edms/link/sharepoint";

  /// Endpoint used to retrieve customer ownership details by RIM.
  static String getCustomerInformationByRimOwnership =
      "customer-info/getCustomerOwnershipDetails";

  /// Endpoint used to retrieve borrower exception details.
  static String getCustomerInformationByRimException =
      "customer-info/getBorrowerExcptionsByCustomerInfo";

  /// Endpoint used to delete customer ownership details.
  static String deleteOwnership = "customer-info/deleteCustomerOwnershipDetail";

  /// Endpoint used to delete borrower exceptions.
  static String deleteException = "customer-info/deleteBorrowerExcption";

  /// Endpoint used to retrieve customer request information.
  static String getCustomerRequestInfo = "${mockAPI}getPipelineRequestDetails";

  /// Endpoint used to retrieve review comments.
  static String getReviewComments = "${mockAPI}getReviewComments";

  /// Endpoint used to update application terminated status.
  static String updateTerminatedStatus = "requestInfo/updateTerminatedStatus";

  /// Endpoint used to retrieve application details.
  static String getApplicationDetails = "requestInfo/getApplicationDetails";

  /// Endpoint used to retrieve the last approved application.
  static String getLastApprovedApplications =
      "requestInfo/getLastApprovedApplication";

  /// Endpoint used to retrieve application borrower details.
  static String getApplicationBorrowers = "${mockAPI}getApplicationBorrowers";

  /// Endpoint used to save application information.
  static String saveApplicationInformation =
      "requestInfo/saveApplicationInformation";

  /// Endpoint used to validate prior request cancellation.
  static String cancelPriorValidation = "requestInfo/cancelPriorValidation";

  /// CCSYS API endpoints.

  /// Endpoint used to retrieve customer information from CCSYS.
  static String getCustomerInformationCCSYS =
      "ccsys/customerInformation/getCustomerInfo";

  /// Endpoint used to save customer information in CCSYS.
  static String saveCustomerInformationCCSYS =
      "ccsys/customerInformation/saveCustomerInfo";

  /// Endpoint used to retrieve application details from CCSYS.
  static String getApplicationDetailsCCSYS =
      "ccsys/requestInformation/getApplicationDetails";

  /// Endpoint used to retrieve customer profile details from CCSYS.
  static String getCcsysCustomerProfile = "ccsys/createModule/getPartyDetails";

  /// Endpoint used to save application information in CCSYS.
  static String saveCcsysApplicationInformation =
      "ccsys/requestInformation/saveApplicationInformation";

  /// Endpoint used to retrieve the last approved application details
  /// from CCSYS.
  static String getCcsysLastApprovedApplicationDetails =
      "ccsys/requestInformation/getLastApprovedApplicationDetails";

  /// Endpoint used to save customer information in CCSYS.
  static String saveCcsysCustomerInfo =
      "ccsys/customerInformation/saveCustomerInfo";

  /// Endpoint used to retrieve customer information from CCSYS.
  static String getCcsysCustomerInfo =
      "ccsys/customerInformation/getCustomerInfo";

  /// Endpoint used to retrieve the last assigned role.
  static String getLastAssignedRoleCCSYS = "approvals/getLastAssignedRole";

  /// Endpoint used to submit an application in CCSYS.
  static String submitApplicationCCSYS = "ccsys/approvals/submitApplication";

  /// Endpoint used to generate output forms and submit them to SharePoint.
  static String generateOutputFormsAndSubmitToSharepoint =
      "approvals/generateOutputFormsAndSubmitToSharepoint";

  /// File attachment API endpoints.

  /// Endpoint used to retrieve file attachment access rights.
  static String getFileAttachments = "referenceData/getFileAccessRight";

  /// Endpoint used to save file attachment access rights.
  static String saveFileAttachments = "referenceData/saveFileAccessRight";

  /// Dashboard API endpoints.

  /// Endpoint used to retrieve dashboard summary counts.
  static String getSummary = "dashboard/getDashboardSummaryCount";

  /// Endpoint used to retrieve dashboard ageing counts.
  static String getDashboardAgeingCount = "dashboard/getDashboardAgeingCount";

  /// Endpoint used to retrieve dashboard documentation summary data.
  static String getDocumentationSummary = "dashboard/getDocumentationSummary";

  /// Endpoint used to retrieve worklist data.
  static String getRequestDetailsWorkList = "dashboard/getWorklist";

  /// Endpoint used to retrieve worklist data for bar graph visualizations.
  static String getWorklistForBarGraph = "dashboard/getWorklistForBarGraph";

  /// Endpoint used to retrieve users by roles.
  static String getUsersByRoles = "apim/bpm/getUsersByRoles";

  /// Endpoint used to assign a request to a user.
  static String assignToUser = "apim/bpm/assignToUser";

  /// Endpoint used to retrieve closed request worklist data.
  static String getClosedRequestDetailsWorkList = "dashboard/getWorklist";

  /// Endpoint used to retrieve filtered users by roles.
  static String getFilteredUsersByrole = "apim/bpm/getFilteredUsersByRoles";

  /// Endpoint used to retrieve roles assigned to a user.
  static String getRolesByUser = "dashboard/getRolesByUser";

  /// Endpoint used to retrieve dashboard role mapping data.
  static String getDashboardRoleMapList = "approvals/getDashboardRoleMapList";

  /// Endpoint used to retrieve worklist data based on search criteria.
  static String getWorklistForSearchCriteria =
      "dashboard/getWorklistForSearchCriteria";

  /// Condition and covenant API endpoints.

  /// Endpoint used to retrieve covenant details.
  static String getCovenants = "covenants/getCovenants";

  /// Endpoint used to save covenant details.
  static String saveCovenants = "covenants/saveCovenants";

  /// Endpoint used to retrieve condition details.
  static String getConditions = "conditions/getConditions";

  /// Endpoint used to save condition details.
  static String saveConditions = "conditions/saveConditions";

  /// Endpoint used to retrieve application strategy comments.
  static String getStategyComment = "appStrategyComment/getStrategyComment";

  /// Endpoint used to save application strategy comments.
  static String saveStategyComment = "appStrategyComment/saveStrategyComment";

  /// Profitability API endpoints.

  /// Endpoint used to retrieve business volume details.
  static String getBussinessVolume = "profitability/getBusinessVolume";

  /// Endpoint used to save business volume details.
  static String saveBussinessVolume = "profitability/saveBusinessVolume";

  /// Endpoint used to retrieve account statistics.
  static String getAccountStats = "profitability/getAccountStats";

  /// Endpoint used to retrieve account conduct data.
  static String getAccountConductData = "profitability/getAccountConduct";

  /// Endpoint used to save account conduct data.
  static String saveAccountConductData = "profitability/saveAccountConduct";

  /// Endpoint used to retrieve relationship utilization details.
  static String getRelationshipUtilization =
      "profitability/getRelationshipUtilization";

  /// Endpoint used to save relationship utilization details.
  static String saveRelationshipUtilization =
      "profitability/saveRelationshipUtilization";

  /// Endpoint used to retrieve detailed relationship profitability data.
  static String getRelationshipProfitabilityDetailed =
      "profitability/getIncomeSummary";

  /// Endpoint used to retrieve relationship profitability comments.
  static String getRelProfitDetComments = "${mockAPI}getRelProfitDetComments";

  /// Endpoint used to retrieve relationship profitability summary data.
  static String getrelationshipProfitabilitySummary =
      "profitability/getProfitabilityRAROC";

  /// Endpoint used to save relationship profitability summary data.
  static String postRelationshipProfitabilitySummary =
      "profitability/saveProfitabilityRAROC";

  /// Endpoint used to retrieve strategy comments.
  static String getStrategyComments = "${mockAPI}getStrategyComments";

  /// Endpoint used to save strategy comments.
  static String saveStrategyComments = "${mockAPI}postStrategyComments";

  /// Endpoint used to retrieve share of wallet information.
  static String getShareofWallet = "profitability/getShareOfWallet";

  /// Endpoint used to retrieve income summary details.
  static String getIncomeSummary = "profitability/getIncomeSummary";

  /// Endpoint used to save income summary details.
  static String saveIncomeSummary = "profitability/saveIncomeSummary";

  /// Risk rating API endpoints.

  /// Endpoint used to retrieve risk rating details.
  static String getRatingDetails = "riskRating/getRatingDetails";

  /// Endpoint used to retrieve updated risk rating information.
  static String getUpdatedRating = "riskRating/getUpdatedRating";

  /// Endpoint used to save risk rating details.
  static String saveRatingDetailsUpdated = "riskRating/saveRatingDetails";

  /// Facility API endpoints.

  /// Endpoint used to retrieve facility summary details by RIM.
  static String getFacilitySummaryListPerRim =
      "facility/getFacilitySummaryListPerRim";

  /// Endpoint used to retrieve project details associated with facilities.
  static String getProjectList = "facility/getProjectList";

  /// Endpoint used to retrieve limits and facilities information.
  static String getLimitsandFacilities = "facility/getLimitsandFacilities";

  /// Endpoint used to save facility details.
  static String saveFacilityDetailsNew = "facility/saveFacilityDetails";

  /// Endpoint used to retrieve facility details.
  static String getFacilityDetails = "facility/getFacilityDetails";

  /// Endpoint used to retrieve facility condition details.
  static String getFacilityConditionsList =
      "facility/getFacilityConditionsList";

  /// Endpoint used to save facility summary details.
  static String saveFacilitySummaryList = "facility/saveFacilitySummaryList";

  /// Endpoint used to retrieve borrower mappings.
  static String getBorrowersMap = "facility/getBorrowersMap";

  /// Endpoint used to retrieve borrower details.
  static String getBorrowers = "facility/getBorrowers";

  /// Endpoint used to retrieve security details.
  static String getSecurityDetails = "security/getSecurityDetails";

  /// Endpoint used to save security details.
  static String saveSecurityDetails = "security/saveSecurityDetails";

  /// Endpoint used to retrieve security summary details.
  static String getSecuritySummaryList = "security/getSecuritySummaryList";

  /// Endpoint used to delete a facility.
  static String deleteFacilityItem = "facility/deleteFacility";

  /// Endpoint used to delete a facility condition.
  static String deleteFacilityCondition = "facility/deleteFacilityCondition";

  /// Security API endpoints.

  /// Endpoint used to retrieve dynamic security form data.
  static String getSecurityDynamicForm = "security/getDynamicFormData";

  /// Endpoint used to save facility-security link details.
  static String saveFacilitySecurityLinkDetails =
      "security/saveFacilitySecurityLinkDetails";

  /// Endpoint used to retrieve standard conditions.
  static String getStandardConditions = "${mockAPI}getStandardConditions";

  /// Endpoint used to retrieve facility summary details.
  ///
  /// Required for the covenant dialog.
  static String getFacilities = "security/getFacilitySummaryList";

  /// Endpoint used to delete security details.
  static String deleteSecurityDetails = "security/deleteSecurity";

  /// Endpoint used to retrieve dynamic facility form data.
  static String getFacilitiesDynamicForm = "${mockAPI}getFacilitiesDynamicForm";

  /// Endpoint used to save facility details.
  static String saveFacilitiesDetails = "${mockAPI}saveFacilityDetails";

  /// Endpoint used to save facility sub-limit details.
  static String saveFacilitySubLimit = "${mockAPI}saveFacilitySubLimit";

  /// Endpoint used to retrieve controlling limit number data.
  static String getControllingLimitNoData =
      "facility/getControllingLimitNumData";

  /// Certificate API endpoints.

  /// Endpoint used to retrieve certificate details.
  static String getCertificateDetails = "certifications/getCertificateDetails";

  /// Endpoint used to save certificate details.
  static String saveCertificateDetails =
      "certifications/saveCertificateDetails";

  /// Endpoint used to retrieve ESG certification details.
  static String getEsgCertificateDetails =
      "certifications/getEsgCertificationsDetails";

  /// Endpoint used to save ESG certification details.
  static String saveEsgCertificationDetails =
      "certifications/saveEsgCertificationsDetails";

  /// Group information API endpoints.

  /// Endpoint used to retrieve group information details.
  static String getGroupInformation = "groupInfo/getGroupInformation";

  /// Endpoint used to retrieve facilities with other banks.
  static String getFacilityWithOtherBank = "groupInfo/getOtherBankFacilities";

  /// Endpoint used to retrieve share of wallet details.
  static String getShareofWalletDetails = "groupInfo/getShareOfWalletDetails";

  /// Endpoint used to save facilities with other banks.
  static String saveFacilityWithOtherBank = "groupInfo/saveOtherBankFacilities";

  /// Endpoint used to retrieve linked facilities.
  static String getLinkedFacilities = "groupInfo/getLinkedFacilities";

  /// Endpoint used to retrieve application strategy details.
  static String getApplicationStrategyDetails =
      "requestInfo/getApplicationStrategyDetails";

  /// Endpoint used to save application strategy details.
  static String saveApplicationStrategyDetails =
      "requestInfo/saveApplicationStrategyDetails";

  /// Endpoint used to save CBRB data.
  static String saveCBRBData = "groupInfo/saveCBRBData";

  /// Endpoint used to delete CBRB information.
  static String deletCBRBInformation = "groupInfo/deletCBRBInformation";

  /// Endpoint used to delete facility information from other banks.
  static String deleteWithOtherBank = "groupInfo/deleteWithOtherBank";

  /// Endpoint used to upload documents.
  static String uploadDocument = "${mockAPI}uploadDocument";

  /// Project API endpoints.

  /// Endpoint used to retrieve project details.
  static String getProjectDetails = "${mockAPI}getProjectDetails";

  /// Endpoint used to retrieve linked commitment numbers.
  static String getLinkContract = "${mockAPI}getLinkCommitmentNumber";

  /// Endpoint used to retrieve per-party limit details.
  static String getPerPartyLimit = "${mockAPI}getPerPartyLimit";

  /// Endpoint used to retrieve contract details by contract code.
  static String getContractByContractCodeDetails =
      "contract/getContractByContractCode";

  /// Endpoint used to retrieve linked CMN details for a RIM.
  static String getLinkedCMNForRimDetails = "contract/getLinkedCMNForRim";

  /// Endpoint used to save project details.
  static String saveProjectDetails = "project/saveProject";

  /// Endpoint used to retrieve contractor details.
  static String getContractDetails = "contract/getContractors";

  /// Endpoint used to save contract details.
  static String saveContractDetails = "contract/saveContract";

  /// Endpoint used to search projects by project information.
  static String getSearchProjectDetails = "project/getProjectByProject";

  /// Endpoint used to search projects by contract information.
  static String getSearchProjectDetailsContract =
      "project/getProjectByContract";

  /// Endpoint used to retrieve project borrower details.
  static String getProjectBorrower = "project/getBorrower";

  /// Approval API endpoints.

  /// Endpoint used to retrieve group position details.
  static String getGroupPositionDetails = "approvals/getGroupPositionDetails";

  // static String getProposedFacilities = "${mockAPI}getProposedFacilities";

  /// Endpoint used to retrieve company limit details.
  static String getCompanyLimitDetails = "approvals/getCompanyLimitDetails";

  /// Endpoint used to retrieve guarantor exposure details.
  static String getGuarantorExposure = "approvals/getGuarantorExposure";

  /// Endpoint used to submit an application for approval.
  static String submitApplicationApproval = "approvals/submitApplication";

  /// Endpoint used to validate approval actions.
  static String validateApproval = "approvals/validateApproval";

  /// Endpoint used to retrieve customer details by RIM.
  static String getCustomerByRim = "requestInfo/getPotentialRim";

  // "${mockAPI}getCustomerByRim";

  /// Endpoint used to retrieve security deferral details.
  static String getSecurityDeferral = "requestInfo/getSecurityDeferralDetails";

  /// Endpoint used to save security deferral details.
  static String saveSecurityDeferralDetails =
      "requestInfo/saveSecurityDeferralDetails";

  /// Endpoint used to save clean exposure information.
  static String saveCleanExposureInfo = "approvals/saveCleanExposureInfo";

  /// Endpoint used to retrieve clean exposure information.
  static String getCleanExposureInfo = "approvals/getCleanExposureInfo";

  /// Endpoint used to validate an RSA token.
  static String validateRSAToken = "approvals/validateRSAToken";

  /// Output Forms API endpoints.

  /// Endpoint used to retrieve output form preview data.
  static String getOutputForms = "outputForm/getPreviewList";

  /// Endpoint used to generate the Project Exposure Summary output form.
  static String generateProjectExposureSummary =
      "outputForm/generateProjectExposureSummary";

  /// Endpoint used to generate the Mark Forward output form.
  static String generateMarkForward = "outputForm/generateMarkForward";

  /// Endpoint used to retrieve pipeline request details.
  static String getPipelineRequestDetails =
      "requestInfo/getPipelineRequestDetails";

  /// Endpoint used to retrieve legal and limit details.
  static String getLegalAndLimitDetails = "approvals/getLegalAndLimitDetails";

  /// Remarks API endpoints.

  /// Endpoint used to retrieve relationship strategy details by RIM.
  static String getRelationshipStrategyDetailsByRim =
      "remarks/getRelationshipStrategyDetailsByRim";

  /// Endpoint used to save relationship strategy details by RIM.
  static String saveRelationshipStrategyDetailsByRim =
      "remarks/saveRelationshipStrategyDetailsByRim";

  /// Endpoint used to retrieve fee structure details.
  static String getFeeStructureData = "remarks/getFeeStructureDetails";

  /// Endpoint used to save fee structure details.
  static String saveFeeStructureData = "remarks/saveFeeStructureDetails";

  /// Endpoint used to delete fee structure details.
  static String deleteFeeStructureData = "remarks/deleteFeeStructureDetails";

  /// Endpoint used to retrieve financial data from CreditLens.
  static String getFinancialDataFromCreditLens =
      "remarks/getFinancialDetailsFromCreditLens";

  /// Endpoint used to retrieve financial ratio analysis details.
  static String getFinancialRatioAnalysisDetails =
      "remarks/getFinancialRatioAnalysisDetails";

  /// Endpoint used to save financial ratio analysis details.
  static String saveFinancialRatioAnalysisDetails =
      "remarks/saveFinancialRatioAnalysisDetails";

  // static String submitApplicationApproval = "approvals/submitApplication";

  /// Endpoint used to delete financial ratio analysis details.
  static String deleteFinancialRatioAnalysisDetails =
      "remarks/deleteFinancialRatioAnalysisDetails";

  /// Endpoint used to delete guarantor details.
  static String deleteGuarantorDetails = "remarks/deleteGuarantorDetails";

  /// Endpoint used to delete guarantor details by entity ID.
  static String deleteGuarantorDetailsByEntityId =
      "remarks/deleteGuarantorDetailsByEntityId";

  /// Endpoint used to save guarantor financial details.
  static String saveGuarantorFinancialDetails =
      "remarks/saveGuarantorFinancialDetails";

  /// Endpoint used to retrieve guarantor financial details.
  static String getGuarantorFinancialDetails =
      "remarks/getGuarantorFinancialDetails";
}

/// Prints all configured API endpoints for verification and debugging.
void testEndpoints() {
  [
    APIEndpoints.mockAPI,
    APIEndpoints.login,
    APIEndpoints.refreshToken,
    APIEndpoints.getRoleRightMap,
    APIEndpoints.updateUserRole,
    APIEndpoints.logout,
    APIEndpoints.saveRoleRightMap,
    APIEndpoints.referenceData,
    APIEndpoints.getCustomerProfile,
    APIEndpoints.getUsersList,
    APIEndpoints.getApplicableReconApplication,
    APIEndpoints.getPipelineRequestDetails,
    APIEndpoints.saveUIAuditUrl,
    APIEndpoints.getCustomerRequestInfo,
    APIEndpoints.configurableReferenceData,
    APIEndpoints.saveConfigurableReferenceData,
    APIEndpoints.getReviewComments,
    APIEndpoints.assignToUser,
    APIEndpoints.updateTerminatedStatus,
    APIEndpoints.getAdminUserDetails,
    APIEndpoints.saveAdminUserDetails,
    APIEndpoints.getApplicationStrategyDetails,
    APIEndpoints.saveApplicationStrategyDetails,
    APIEndpoints.getCertificateDetails,
    APIEndpoints.saveCertificateDetails,
    APIEndpoints.getApplicationDetails,
    APIEndpoints.getCustomerInformationByRim,
    APIEndpoints.getCountries,
    APIEndpoints.saveCustomerInformation,
    APIEndpoints.getFileAttachments,
    APIEndpoints.saveFileAttachments,
    APIEndpoints.getSummary,
    APIEndpoints.getDocumentationSummary,
    APIEndpoints.getRequestDetailsWorkList,
    APIEndpoints.getEsgCertificateDetails,
    APIEndpoints.saveEsgCertificationDetails,
    APIEndpoints.getCovenants,
    APIEndpoints.getConditions,
    APIEndpoints.saveConditions,
    APIEndpoints.getUsersByRoles,
    APIEndpoints.getFilteredUsersByrole,
    APIEndpoints.getCcsysCustomerInfo,
    APIEndpoints.getFacilities,
    APIEndpoints.getComments,
    APIEndpoints.saveComments,
    APIEndpoints.saveCovenants,
    APIEndpoints.getSICCodeReview,
    APIEndpoints.saveSICcodeReview,
    APIEndpoints.getAccountConductData,
    APIEndpoints.saveAccountConductData,

    APIEndpoints.getRelationshipUtilization,
    APIEndpoints.saveRelationshipUtilization,

    APIEndpoints.getRelationshipProfitabilityDetailed,
    APIEndpoints.getRelProfitDetComments,
    APIEndpoints.getrelationshipProfitabilitySummary,
    APIEndpoints.postRelationshipProfitabilitySummary,
    APIEndpoints.getStrategyComments,
    APIEndpoints.saveStrategyComments,
    APIEndpoints.getShareofWallet,
    APIEndpoints.getIncomeSummary,
    APIEndpoints.saveIncomeSummary,

    APIEndpoints.getRatingDetails,
    APIEndpoints.getUpdatedRating,
    APIEndpoints.saveRatingDetailsUpdated,
    APIEndpoints.getSecuritySummaryList,
    APIEndpoints.getFacilitySummaryListPerRim,
    APIEndpoints.saveFacilitySecurityLinkDetails,
    APIEndpoints.saveSecurityDetails,
    APIEndpoints.deleteSecurityDetails,
    APIEndpoints.getGroupInformation,
    APIEndpoints.getFacilityWithOtherBank,
    APIEndpoints.getShareofWalletDetails,
    APIEndpoints.saveFacilityWithOtherBank,
    APIEndpoints.getBussinessVolume,
    APIEndpoints.saveBussinessVolume,
    APIEndpoints.getAccountStats,
    APIEndpoints.getLinkedFacilities,

    APIEndpoints.getSecurityDynamicForm,
    APIEndpoints.getCurrencyCode,
    APIEndpoints.getFacilitiesDynamicForm,

    APIEndpoints.saveProjectDetails,
    APIEndpoints.getProjectDetails,
    APIEndpoints.getContractDetails,
    APIEndpoints.getLinkContract,
    APIEndpoints.getPerPartyLimit,
    APIEndpoints.saveContractDetails,
    APIEndpoints.getGroupPositionDetails,
    //APIEndpoints.getProposedFacilities,
    APIEndpoints.getCompanyLimitDetails,
    APIEndpoints.getCustomerByRim,
    APIEndpoints.getSecurityDeferral,
    APIEndpoints.getApplicationBorrowers,
    APIEndpoints.saveApplicationInformation,
    APIEndpoints.saveCcsysApplicationInformation,
    APIEndpoints.getCcsysLastApprovedApplicationDetails,

    APIEndpoints.saveCcsysCustomerInfo,

    APIEndpoints.getOutputForms,
    APIEndpoints.deleteFacilityItem,
    APIEndpoints.saveFacilitySubLimit,
    APIEndpoints.getSearchProjectDetails,
    APIEndpoints.getFeeStructureData,
    APIEndpoints.saveFeeStructureData,
    APIEndpoints.getClosedRequestDetailsWorkList,
  ].forEach(logger.i);
}
