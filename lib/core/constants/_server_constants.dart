import 'package:easy_localization/easy_localization.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/request/covenant_condtion/covenant.dart';

class ServerConstants {
  static const String wcasManual = "wcas_manual.pdf";
  static const String spreadSmartManual = "spreadsmart_manual.pdf";

  //role
  static const int roId = 125;
  static const int rmId = 126;
  static const int caId = 135;
  static const int tlbId = 127;
  static const int camId = 128;
  static const int rmbId = 129;
  static const int shbId = 130;
  static const int tldId = 136;
  static const int ccpId = 140;
  static const int bdpId = 141;
  static const int bdId = 3189;
  static const int ccId = 140;
  static const int shlbId = 139;
  static const int shlcId = 138;
  static const int shldId = 137;
  static const int lgtId = 3203;
  static const int lmtId = 3202;
  static const int ccoodId = 134;
  static const int admId = 2024;
  static const int inqusrId = 3251;
  static const int ltId = 3203;
  static const int ltcoodId = 6343;
  static const int optionNAid = 1906;
  static const int optionNOid = 1905;
  static const int optionYESid = 1904;
  static const int optionBothId = 14503; //in facility module required
  static const int mainLimitTypeID = 280;
  static const int reExposureID = 11355;
  static const int productTypeIslamicID = 11322;

  //request
  static const int financialInstitutionId = 14486;
  static const int applicationIsolatedId = 102;
  static const int applicationFullCAId = 100;
  static const int requestFinancialId = 101;
  static const int applicationTypeFIOneOff = 11389;
  static const int applicationTypeFIIsolatedAllocation = 11392;
  static const String corperateCode = "C";
  static const String financialCode = "F";
  static const String financialSegmentPartyInq = "Fin Inst and CF";

//create new request

//create new request
  static const int riskRatingchanges = 11390;
  static const int isolatedMemo = 102;

//create security
  static const String entity = 'Entity';
  static const String subSegmentValidationRefId = "Y";
  static const String defaultBranch = "Al Qouz Branch";
  static const String defaultRegion = "Jumeirah";
  static const int bankGuaranteeId = 79;
  static const int corporateGuaranteeId = 85;
  static const int personalGuaranteeId = 76;
  static const String personal = 'Personal';

//Customer Party Status check
  static const String partyStatusClosed = "Closed";
  static const String nationalID = "NationalID";
  static const String emirates = "Emirates";
  static const String residentValue = 'R';
  static const String residentYes = 'y';
  static const String residentNo = 'n';

// Admin Reference Data

  static const String referenceDataIdTitle = "Reference Data ID";
  static const String referenceNameTitle = "Name";
  static const String referenceDescriptionTitle = "Description";
  static const String reference1Title = "Reference 1";
  static const String reference2Title = "Reference 2";
  static const String reference3Title = "Reference 3";
  static const String reference4Title = "Reference 4";
  static const String reference5Title = "Reference 5";
  static const String referenceStatusTitle = "Status";
// Admin Access Rights
  static const String accessRightUpdate = "NW";
  static const String accessRightSave = "AM";
  static const String aedCurrency = "AED";
  static const String aedDescription = "United Arab Emirates";
  //admin role right
  static const int financialPoolMaker = 132;
  static const int financialPoolChecker = 133;
  static const int financialPoolCoordinator = 131;

  static const int creditApplicationDocumentType = 14182;

  //Dashboard
  static const int bySegmentOrRegionId = 4269;
  static const int groupId = 4263;
  static const int advancedRequestTypeId = 4266;
  static const int customerRIMNumberId = 4262;
  static const int applicationReferenceNumberId = 4261;

  // Security Perfection
  static const int securityStrategyCommentsType = 4255;
  static const int securityAppStrategyCommentsId = 451974;
  static const int securityCategoryID = 4256;
  static const String securityCategoryType = 'Security Perfection';
  static const String appRefNo = "201902APNAR000039";
  static const int rmNameId = 4264;
  static const int pendingWithId = 4265;
  static const String cashCollateralReference = "Y";
  static const String tangibleSecurityReference = "T";

  // Create Security
  static const int securityProviderCategoryEntityId = 8392;

  // Present request
  static const int presentRequestStrategyCommentsType = 1158;
  static const int presentRequestAppStrategyCommentsId = 451974;
  static const int presentRequestCategoryID = 1177;
  static const String presentRequestCategoryType = 'PRESENT REQUEST';

  //Request information Application details strategy details
  static const int requestApplicationInfoCategoryID = 7342;
  static const String requestApplicationInfoCategoryType =
      'PURPOSE OF APPLICATION DETAILED';
  static const int requestApplicationInfoStrategyCommentsType = 7342;
  static const int requestApplicationInfoStrategyCommentsId = 7342;

  /// Covenant Condition
  static const int conditionGeneralId = 14214;
  static const int conditionSpecificId = 14215;
  static const int conditionStandardId = 13945;
  static const int conditionCustomId = 13946;
  static const int conditionActionCreateId = 13936;
  static const String covenantMode = "Edit";
  static const int conditionStatusNewId = 13933;
  static const String financialCovenantReference2 = "11144";
  // static const String conditionPrecedentTerm = "Standard Precedent Term Sheet Conditions 13975";
  // static const String conditionSubsequent = "Standard Conditions Subsequent 13974";
  // static const String conditionPrecedent = "Standard Precedent Conditions 13973";

  //Covenant
  static const int defaultNewStatusId = 11080;
  static const int covenantGeneralId = 13851;
  static const int covenantSpecificId = 13852;
  static const String covenantEdit = "Edit";
  static const String covenantCreate = "Add";
  static const int standardDescriptionId = 11095;
  static const int customDescriptionId = 11096;
  static const int covenantSubTypeIdForFrequencyFilter = 11126;
  static const List<int> excludedFrequencyIds = [
    11614, // Semiannual
    11615, // Fortnighlty
  ];
  static const int covenantTypeIdNonFinancial = 11145;
  static const int covenantTypeIdFinancial = 11144;
  static const int covenantTypeIdInformation = 11143;

  static List<FacilityNew> defaultFacilityList = [
    FacilityNew(limitNo: "ODA0012"),
  ];

  //Covenant Threshold Type IDs
  static const int thresholdTypeMin = 11073;
  static const int thresholdTypeMax = 11074;
  static const int thresholdTypeEqualTo = 11075;
  static const int createActionId = 14216;

  // Covenant Subtype ID groups
  static const List<int> minThresholdSubtypeIds = [11137, 11139];
  static const List<int> maxThresholdSubtypeIds = [
    11131,
    11132,
    11133,
    11134,
    11135,
    11136,
    11138,
    11140
  ];

  //map for description templates
  static Map<int, String> financialDescriptionTemplates = {
    11131: "covenantsConditions.covenantEditDialog.shallNotExceed".tr(),
    11132: "covenantsConditions.covenantEditDialog.shallNotExceed".tr(),
    11133: "covenantsConditions.covenantEditDialog.shallNotExceed".tr(),
    11134: "covenantsConditions.covenantEditDialog.shallNotBeMore".tr(),
    11135: "covenantsConditions.covenantEditDialog.shallNotBeMore".tr(),
    11136: "covenantsConditions.covenantEditDialog.shallNotBeMore".tr(),
    11137: "covenantsConditions.covenantEditDialog.shallNotBeLessMillion".tr(),
    11138: "covenantsConditions.covenantEditDialog.shallNotBeMorePerc".tr(),
    11139: "covenantsConditions.covenantEditDialog.shallNotBeLess".tr(),
    11140: "covenantsConditions.covenantEditDialog.shallNotBeExceedProfit".tr(),
    11141: "covenantsConditions.covenantEditDialog.nonFinancialfirstItem".tr(),
    11142: "covenantsConditions.covenantEditDialog.nonFinancialSecondItem".tr(),
  };

  //TerminateWithDraw
  static const int terminateCategoryID = 1842;
  // Certificate request
  static const String customerName = "RIM 50";
  static const String groupName = "DCMM MM";
  static const String requestName = "Isolate CRPR";
  //certificate Attachments
  static const String attachmentCertificatesID = "WCAS";
  static const String markForwardCertificatesID = "MF";

  // Facilities with CBD request
  static const int groupStrategyCommentsType = 3139;
  static const int groupAppStrategyCommentsId = 451915;
  static const int groupCategoryID = 937;
  static const String groupCategoryType = "Group Information";
  // Facilities with Other Bank request
  static const int otherBankStrategyCommentsType = 3132;
  static const int otherBankAppStrategyCommentsId = 451916;
  static const int otherBankCategoryID = 3132;
  static const String otherBankCategoryType = "Facilities with Other Bank";
  // Facilities with Other BankCBRB request
  static const int cbrbStrategyCommentsType = 3132;
  static const int cbrbAppStrategyCommentsId = 451916;
  static const int cbrbCategoryID = 3132;
  static const String cbrbCategoryType = "Central Bank Risk Bureau Data";

  //FI Credit Risk
  static const int fiCreditRisk = 1;
  static const String fiCreditRiskType = "FI Credit Application";

  //YES/NO/NA
  static const int yesRefId = 1904;
  static const int noRefId = 1905;
  static const int naRefId = 1906;

  //Policy Deivation - Large Exposure Breach
  static const int largeExposureLimitAmountRefId = 8409;
  static const int largeExposureLimitPercentageRefId = 8410;
  static const int largeExposureBreachId = 8393; //301;
  static const String largeExposureBreachName = "large exposure breach";
  // static const String largeExposureLimitAmountRefName =
  //     "Large Exposure Limit Amount";
  // static const String largeExposureLimitPercentageRefName =
  //     "Large Exposure Limit Percentage";

  //Remarks
  static const String incomeStatementAnalysis = 'Income statement Analysis';
  static const String cashFlowAnalysis = "Cash Flow statement Analysis";
  static const String balanceSheetAnalysis = "Balance Sheet Analysis";
  static const String unqualified = "Unqualif'd";

  static const int subSubTypeFinancialProjection = 14191;
  static const int subSubSubTypeCreditApplicationApprovalDecision = 14202;

  //SIC_CODE_REVIEW
  static const String strategyCategorySICCodeReview = "SIC_CODE_REVIEW";

// Dynamic Form
  static const int dynamicFormSecurityID = 15;
  static const int dynamicFormFacilityID = 14;
  static const nameOfZoneKeyValue = "nameOfTheZone";
  //Request Information
  //Reference 1 compare with
  static const String productTypeBoth = "B";
  static const String productTypeIslamic = "I";
  static const String productTypeConventional = "C";

  //profitablility and account conduct
  static const int accountStatsCommentCategoryId = 1784;
  static const String accountStatsCommentCategoryType = "Account Statistics";

  static const int relationshipStrategyCommentCategoryId = 1160;
  static const String relationshipStrategyCommentCategoryType =
      "Relationship Strategy"; // User Role

  static const int depositsStrategyCommentCategoryId = 1161;
  static const String depositsStrategyCommentCategoryType = "Deposits Strategy";

  static const int transactionalBankingCommentCategoryId = 1162;
  static const String transactionalBankingCommentCategoryType =
      "Transaction Banking Comments";

  static const int tradeFinanceCommentCategoryId = 1163;
  static const String tradeFinanceCommentCategoryType =
      "Trade Finance Comments";

  static const int treasuryCommentCategoryId = 1164;
  static const String treasuryFinanceCommentCategoryType = "Treasury Comments";

  static const int shareWalletCommentCategoryId = 936;
  static const String shareWalletCommentCategoryType = "share of Wallet";

  static const Map<UserRole, String> userRoleCode = {
    UserRole.admin: "ADM",
    UserRole.relationshipOfficer: "RO",
    UserRole.relationshipManager: "RM",
    UserRole.teamLeaderBusiness: "TLB",
    UserRole.commercialAreaManager: "CAM",
    UserRole.relationshipManagerBussiness: "RMB",
    UserRole.segmentHeadBusiness: "SHB",
    UserRole.creditCordinator: "CCOOD",
    UserRole.creditAnalyst: "CA",
    UserRole.creditCommitteeProxy: "CCP",
    UserRole.boardDirectorProxy: "BDP",
    UserRole.teamLeaderCreditLevelD1: "TL-D1",
    UserRole.segmentHeadCreditLevelD: "SH-D",
    UserRole.segmentHeadLevelC: "SH-C",
    UserRole.segmentHeadLevelB1: "SH-B1",
    UserRole.segmentHeadLevelB: "SH-B",
    UserRole.creditCommitteeProxyApprover: "CCPA",
    UserRole.boardDirectorProxyApproval: "BDPA",
    UserRole.documentationChecker: "DC",
    UserRole.documentationMaker: "DM",
    UserRole.ccuMaker: "CCU-M",
    UserRole.ccuChecker: "CCU-C",
    UserRole.businessAdmin: "BADM",
    UserRole.icsAdmin: "ICSADM",
    UserRole.inquiryUser: "INQUSR",
    UserRole.financialPoolCoordinator: "FPCOOD",
    UserRole.financialPoolMaker: "FPM",
    UserRole.financialPoolChecker: "FPC",
    UserRole.boardOfDirectorsProxy: "BDP",
    UserRole.creditCommittee: "CC",
    UserRole.boardOfDirectors: "BD",
    UserRole.limitInputTeam: "LIT",
    UserRole.legalTeam: "LT",
    UserRole.legalTeamCoordinator: "LTCOOD",
  };

  static const Map<CertificationType, String> certificationtypeCode = {
    CertificationType.rm: "RM",
    CertificationType.limitInput: "LIT",
    CertificationType.documentation: "DC"
  };

  static const Map<BusinessSegment, int> businessSegmentId = {
    BusinessSegment.corporate: 117,
    BusinessSegment.financialInstitution: 14486
  };

  static const Map<RequestType, int> requestTypeId = {
    RequestType.fullCA: 100,
    RequestType.isolated: 102
  };

  static const Map<ApplicationType, int> applicationTypeId = {
    ApplicationType.newToBank: 103, // NTB
    ApplicationType.annualReview: 104, // Annual Review
    ApplicationType.interimAmendment: 105, // Interim / Amendment
    ApplicationType.reconsideration: 107, // Reconsideration
    ApplicationType.markForward: 11388, // Mark Forward
    ApplicationType.riskRatingChange: 11390, // Risk Rating / Staging
    ApplicationType.documentationDeferral: 11391, // Documentation Deferral
    ApplicationType.oneOffLimit:
        11389, // One-off Limits against 100% cash margin
    ApplicationType.cancellation: 108, // Cancellation
    ApplicationType.isolatedOther: 11387, // Isolated - Others
    ApplicationType.isolatedProjectAllocation:
        11386, // Isolated - Project Allocation
    ApplicationType.isolatedExcessType: 106, // Isolated - Excess Type
    ApplicationType.isolatedAllocation: 11392, // Isolated - Allocation
  };

  static const Map<DocumentType, int> documentTypeId = {
    DocumentType.constitutionalDocument: 14179,
    DocumentType.creditLensDocument: 14180,
    DocumentType.financialStatements: 14181,
    DocumentType.creditApplication: 14182,
    DocumentType.externalOpinions: 14183,
    DocumentType.facilityDocuments: 14184,
    DocumentType.valuationReports: 14185,
    DocumentType.other: 14186,
  };

// Mapping CustomerType to int
  static const Map<CustomerType, int> customerTypeId = {
    CustomerType.country: 1,
    CustomerType.belowInvestmentGradeBanks: 2,
    CustomerType.investmentGradeBanks: 3,
  };
  static const uaeCountryCode = "AE";
// Mapping CustomerType to int
  static const Map<RemarksTabs, int> remarksTabId = {
    RemarksTabs.businessRisk: 1169,
    RemarksTabs.industryRisk: 1168,
    RemarksTabs.managementRisk: 1167,
    RemarksTabs.ownershipStructure: 1166,
    RemarksTabs.relationshipHistory: 1165,
    RemarksTabs.conditions: 8424,
    RemarksTabs.keyRisksAndMitigants: 8425,
    RemarksTabs.otherFacilityRelatedAnalysis: 8426,
    RemarksTabs.guarantorFinancials: 8427,
    RemarksTabs.feeStructure: 8428,
    RemarksTabs.existingAndProposedCollateral: 8429,
    RemarksTabs.settlementLimits: 8430,
    RemarksTabs.cashflowProjectionAnalysis: 8431,
    RemarksTabs.businessExperience: 8432,
    RemarksTabs.background: 8433,
    RemarksTabs.ownership: 8434,
    RemarksTabs.analysisCapital: 8435,
    RemarksTabs.analysisAssets: 8436,
    RemarksTabs.analysisManagement: 8437,
    RemarksTabs.covenants: 8423,
    RemarksTabs.facilityJustification: 8422,
    RemarksTabs.financialRatiosAndAnalysis: 8420,
    RemarksTabs.requestSummary: 8419,
    RemarksTabs.financialHighlights: 8443,
    RemarksTabs.bankOverview: 8442,
    RemarksTabs.otherComments: 8441,
    RemarksTabs.analysisOtherComments: 8440,
    RemarksTabs.analysisLiquidity: 8439,
    RemarksTabs.analysisEarnings: 8438,
    RemarksTabs.security: 8421
  };

  static const int applicationTypeCancelId = 108; //Cancellation
  static const int applicationTypeReconsiderationId = 107; //Reconsideration

  static const Map<CommentsType, int> commentTypeId = {
    CommentsType.requestApplicationDetailed: 7342,
    CommentsType.security: 123,
    CommentsType.approval: 3,
    CommentsType.requestForFOL: 878,
    CommentsType.requestForClosure: 216,
    CommentsType.presentRequest: 1158,
    CommentsType.securityPerfection: 4255,
    CommentsType.facilitiesWithCbd: 3139,
    CommentsType.facilitiesWithOtherBank: 3132,
    CommentsType.centralBankRiskBureauData: 3132,
    CommentsType.conditionsSummary: 216,
    CommentsType.covenantsSummary: 216,
    CommentsType.remarks: 1156,
    CommentsType.accountStats: 28,
    CommentsType.sicCodeReview: 8000,
    CommentsType.strategyComments: 1155,
    CommentsType.terminateWithdraw: 1842,
    CommentsType.shareWallet: 2139,
    CommentsType.riskRating: 14931,
  };

  static const Map<EntityIdentifier, int> entityId = {
    EntityIdentifier.requestApplicationDetailed: 7342,
    EntityIdentifier.security: 123,
    EntityIdentifier.approval: 3,
    EntityIdentifier.requestForFOL: 878,
    EntityIdentifier.requestForClosure: 216,
    EntityIdentifier.presentRequest: 7342,
    EntityIdentifier.securityPerfection: 4255,
    EntityIdentifier.facilitiesWithCbd: 3139,
    EntityIdentifier.facilitiesWithOtherBank: 3132,
    EntityIdentifier.centralBankRiskBureauData: 3132,
    EntityIdentifier.conditionsSummary: 216,
    EntityIdentifier.covenantsSummary: 216,
    EntityIdentifier.shareWallet: 2139,
    EntityIdentifier.strategyComments: 1155,
    EntityIdentifier.terminateWithdraw: 1842,
  };

  // Covenant Category IDs
  static const Map<CovenantType, int> covenantTypeId = {
    CovenantType.information: 11143,
    CovenantType.financial: 11144,
    CovenantType.nonFinancial: 11145,
    CovenantType.none: 0,
  };

  static const List<String> defaultFacilityIds = <String>[
    "GPM0002",
    "GPM0001",
    "LCM0001",
    "PFE0001",
  ];

  // Covenant Sub-Type IDs
  static const Map<CovenantSubType, int> covenantSubTypeId = {
    CovenantSubType.financialStatements: 11126,
    CovenantSubType.projectProgressReport: 11127,
    CovenantSubType.debtorsAndStockAgeing: 11128,
    CovenantSubType.personalNetWorthIncomeStatement: 11129,
    CovenantSubType.operatingBudget: 11130,
    CovenantSubType.other: 11613,
    CovenantSubType.none: 0,
  };

  static const Map<RequestStatus, int> requestStatusId = {
    RequestStatus.initiated: 117,
    RequestStatus.pendingForApproval: 120,
    RequestStatus.approved: 121,
    RequestStatus.declined: 122,
    RequestStatus.requestWithdrawnCancelled: 123,
    RequestStatus.pendingFolIssuance: 124,
    RequestStatus.terminated: 1779,
    RequestStatus.completed: 1907,
    RequestStatus.folIssuedPendingSignOff: 11623, // or 13866 (duplicate exists)
    RequestStatus.folSignOffCompletedPendingFitToLend: 11624, // or 13867
    RequestStatus.fitToLendCompletedPendingLimitRelease: 11625, // or 13868
    RequestStatus.pendingLimitRelease: 11626, // or 13869
    RequestStatus.folNotRequired: 11627, // or 13870
  };

  /// Map of SecurityType → referenceDataListId (int),
  static const Map<SecurityType, int> securityTypeId = {
    SecurityType.assignmentOfInsurancess: 73,
    SecurityType.notarisedCommercialMortgage: 74,
    SecurityType.assignmentOfLeaseholdMusataha: 75,
    SecurityType.personalGuarantee: 76,
    SecurityType.assignmentOfReceivables: 77,
    SecurityType.pledgeOfAccount: 78,
    SecurityType.bankGuarantee: 79,
    SecurityType.chargeOverCbdfsPortfolio: 81,
    SecurityType.pledgeOfBonds: 82,
    SecurityType.conditionalAssignmentOfSpa: 83,
    SecurityType.pledgeOfCommodities: 84,
    SecurityType.corporateGuarantee: 85,
    SecurityType.pledgeOfInvestmentProducts: 86,
    SecurityType.holdOnTitleDeeds: 87,
    SecurityType.pledgeOfSharesBondsOfJointStockCompany: 88,
    SecurityType.mortgageOfProperties: 89,
    SecurityType.pledgeOfSharesOfALimitedLiabilityCompany: 90,
    SecurityType.mortgageOfAircraft: 91,
    SecurityType
        .pledgeOfMoveableAssetsRegisteredWithEircViaUaeMovablesAgreement: 92,
    SecurityType.mortgageOfLeaseholdMusataha: 93,
    SecurityType.pledgeOfPreciousMetals: 94,
    SecurityType.mortgageOfVehicles: 95,
    SecurityType.pledgeOfTd: 96,
    SecurityType.mortgageOfVessel: 97,
    SecurityType.securityCheque: 98,
    SecurityType.mortgageWithFreeZoneAuthorities: 99,
    SecurityType.pledgeOfPlantAndMachineryFixedAssets: 8356,
    SecurityType.promissoryNote: 14175,
    SecurityType.otherFinancialGuaranteeBorrowersCreditInsurance: 14217,
    SecurityType.lienOverSharesHeldByCbdFinancialServices: 14218,
    SecurityType.pledgeOfShares: 14219,
    SecurityType.authorityToDebitAccount: 14220,
    SecurityType.subordinationLetter: 14221,
    SecurityType.thirdPartyPostDatedChequesConsideredGood: 14222,
    SecurityType.postDatedCheque: 14223,
  };
}

void testServerConstants() {
  ServerConstants.roId;
  ServerConstants.rmId;
  ServerConstants.caId;
  ServerConstants.tlbId;
  ServerConstants.camId;
  ServerConstants.rmbId;
  ServerConstants.shbId;
  ServerConstants.tldId;
  ServerConstants.ccpId;
  ServerConstants.bdpId;
  ServerConstants.bdId;
  ServerConstants.ccId;
  ServerConstants.shlbId;
  ServerConstants.shlcId;
  ServerConstants.shldId;
  ServerConstants.lgtId;
  ServerConstants.lmtId;
  ServerConstants.ccoodId;
  ServerConstants.admId;
  ServerConstants.inqusrId;
  ServerConstants.ltId;
  ServerConstants.ltcoodId;
  ServerConstants.optionNAid;
  ServerConstants.optionNOid;
  ServerConstants.optionYESid;
  ServerConstants.optionBothId;
  ServerConstants.mainLimitTypeID;
  ServerConstants.financialInstitutionId;
  ServerConstants.applicationIsolatedId;
  ServerConstants.applicationFullCAId;
  ServerConstants.applicationTypeFIOneOff;
  ServerConstants.referenceDataIdTitle;
  ServerConstants.referenceNameTitle;
  ServerConstants.referenceDescriptionTitle;
  ServerConstants.reference1Title;
  ServerConstants.reference2Title;
  ServerConstants.reference3Title;
  ServerConstants.reference4Title;
  ServerConstants.reference5Title;
  ServerConstants.referenceStatusTitle;
  ServerConstants.accessRightUpdate;
  ServerConstants.accessRightSave;
  ServerConstants.bySegmentOrRegionId;
  ServerConstants.groupId;
  ServerConstants.advancedRequestTypeId;
  ServerConstants.customerRIMNumberId;
  ServerConstants.applicationReferenceNumberId;
  ServerConstants.securityStrategyCommentsType;
  ServerConstants.securityAppStrategyCommentsId;
  ServerConstants.securityCategoryID;
  ServerConstants.securityCategoryType;
  ServerConstants.appRefNo;
  ServerConstants.rmNameId;
  ServerConstants.pendingWithId;
  ServerConstants.presentRequestStrategyCommentsType;
  ServerConstants.presentRequestAppStrategyCommentsId;
  ServerConstants.presentRequestCategoryID;
  ServerConstants.presentRequestCategoryType;
  ServerConstants.requestApplicationInfoCategoryID;
  ServerConstants.requestApplicationInfoCategoryType;
  ServerConstants.requestApplicationInfoStrategyCommentsId;
  ServerConstants.requestApplicationInfoStrategyCommentsType;
  ServerConstants.conditionGeneralId;
  ServerConstants.conditionSpecificId;
  ServerConstants.conditionStandardId;
  ServerConstants.conditionCustomId;
  ServerConstants.terminateCategoryID;
  ServerConstants.customerName;
  ServerConstants.groupName;
  ServerConstants.requestName;
  ServerConstants.attachmentCertificatesID;
  ServerConstants.groupStrategyCommentsType;
  ServerConstants.groupAppStrategyCommentsId;
  ServerConstants.groupCategoryID;
  ServerConstants.groupCategoryType;
  ServerConstants.otherBankStrategyCommentsType;
  ServerConstants.otherBankAppStrategyCommentsId;
  ServerConstants.otherBankCategoryID;
  ServerConstants.otherBankCategoryType;
  ServerConstants.cbrbStrategyCommentsType;
  ServerConstants.cbrbAppStrategyCommentsId;
  ServerConstants.cbrbCategoryID;
  ServerConstants.cbrbCategoryType;
  ServerConstants.fiCreditRisk;
  ServerConstants.fiCreditRiskType;
  ServerConstants.largeExposureBreachId;
  ServerConstants.userRoleCode;
  ServerConstants.businessSegmentId;
  ServerConstants.requestTypeId;
  ServerConstants.applicationTypeId;
  ServerConstants.documentTypeId;
  ServerConstants.customerTypeId;
  ServerConstants.applicationTypeCancelId;
  ServerConstants.applicationTypeReconsiderationId;
  ServerConstants.commentTypeId;
  ServerConstants.entityId;
  ServerConstants.covenantTypeId;
  ServerConstants.covenantSubTypeId;
}
