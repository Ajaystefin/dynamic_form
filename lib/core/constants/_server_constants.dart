import "package:easy_localization/easy_localization.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";

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
  static const int shlb1Id = 11397;
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
  static const int optionBothId = 15739; //in facility module required
  static const int mainLimitTypeID = 280;
  static const int periodDays = 14576;
  static const int periodMonth = 14577;
  static const int periodYears = 14578;
  static const int reExposureID = 11355;
  static const int productTypeIslamicID = 11322;
  static const int ccpaId = 3188;
  static const int bdpaId = 3189;
  static const int dcId = 3203;
  static const int dmId = 6343;
  static const int ccucId = 11398;
  static const int ccumId = 3202;

// some id mission need to add
  static const Map<UserRole, int> userRoleId = {
    UserRole.admin: admId,
    UserRole.relationshipOfficer: roId,
    UserRole.relationshipManager: rmId,
    UserRole.teamLeaderBusiness: tlbId,
    UserRole.commercialAreaManager: camId,
    UserRole.relationshipManagerBussiness: rmbId,
    UserRole.segmentHeadBusiness: shbId,
    UserRole.creditCordinator: ccoodId,
    UserRole.creditAnalyst: caId,
    UserRole.creditCommitteeProxy: ccpId,
    UserRole.boardDirectorProxy: bdpId,
    UserRole.teamLeaderCreditLevelD1: tldId,
    UserRole.segmentHeadCreditLevelD: shldId,
    UserRole.segmentHeadLevelC: shlcId,
    UserRole.segmentHeadLevelB1: shlb1Id,
    UserRole.segmentHeadLevelB: shlbId,
    UserRole.creditCommitteeProxyApprover: ccpaId,
    UserRole.boardDirectorProxyApproval: bdpaId,
    UserRole.documentationChecker: dcId,
    UserRole.documentationMaker: dmId,
    UserRole.ccuMaker: ccumId,
    UserRole.ccuChecker: ccucId,
    // UserRole.businessAdmin: baId,
    // UserRole.icsAdmin: icsaId,
    UserRole.inquiryUser: inqusrId,
    // UserRole.financialPoolCoordinator: fpcId,
    // UserRole.financialPoolMaker: fpmId,
    // UserRole.financialPoolChecker: fpcId,
    UserRole.creditCommittee: ccId,
    UserRole.boardOfDirectors: bdId,
    // UserRole.limitInputTeam: litId,
    UserRole.legalTeam: ltId,
    UserRole.legalTeamCoordinator: ltcoodId,
  };

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

//appendix
  static const String ratingSP = "RatingSP";
  static const String countryMap = "CountryMap";
  static const String countryGovt = "CountryGovt";
  static const String corporate = "corporate";
  static const String financialInstitution = "financialInstitution";
  static const String bank = "Bank";
  static const String financial = "Financial";
  static const String country = "Country";
  static const String threats = "threats";
  static const String strengths = "strengths";
  static const String bigBank = "Below Investment Grade - Bank";
  static const String belowInvestmentGradeBank = "belowinvestmentgradebanks";

  static const String groupCorporateStucture = "Group Corporate Structure";

  static const String pngExtension = ".png";
  static const String jpgExtension = ".jpg";
  static const String jpegExtension = ".jpeg";
  static const String bmpExtension = ".tiff";
  static const String webpExtension = ".tif";
  static const String xlsxExtension = ".xlsx";
  static const String xlsExtension = ".xls";
  static const String pdfExtension = ".pdf";

  static const String pdf = "pdf";
  static const String word = "word";

  static const String mapHint = "map";
  static const String govHint = "gov";
  static const String governmentHint = "government";
  static const String ratingHint = "rating";

  static const String funded = "FUNDED";
  static const String nonFunded = "NON FUNDED";
  static const String indi = "INDI";

//create new request
  static const String riskRatingchanges = "RR"; // 11390;
  static const int isolatedMemoId = 102; // 102;
  static const String isolatedMemo = "MEMO"; // 102;
  static const int countryIDFI = 14487;
  static const String countryNameFI = "country";
  static const String countryClassCode = "7018";

//create security
  static const String entity = "Entity";
  static const String naturalPerson = "Natural Person";
  static const String subSegmentValidationRefId = "Y";
  static const String defaultSegment = "Corporate";
  static const String defaultBranch = "Al Qouz Branch";
  static const String defaultRegion = "Jumeirah";
  static const int bankGuaranteeId = 79;
  static const int corporateGuaranteeId = 85;
  static const int personalGuaranteeId = 76;
  static const int financialGuranteeID = 14217;
  static const String personal = "Personal";

//Customer Party Status check
  static const String partyStatusClosed = "Closed";
  static const String nationalID = "NationalID";
  static const String emirates = "Emirates";
  static const String residentValue = "R";
  static const String residentYes = "y";
  static const String residentNo = "n";

// Admin Reference Data

  static const int subSegmentValidationReftType = 2329;
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
  static const String securityCategoryType = "Security Perfection";
  static const String appRefNo = "201902APNAR000039";
  static const int rmNameId = 4264;
  static const int pendingWithId = 4265;
  static const String cashCollateralReference = "Y";
  static const String tangibleSecurityReference = "T";

  // Create Security
  static const int securityProviderCategoryEntityId = 8392;
  static const int securityProviderCategoryNaturalPersonId = 8391;
  static const int fiOtherSecurityGroupId = 14574;
  static const int commitmentAccountNumberStartWith100 = 100;

  static const int commitmentAccountNumberStartWith400 = 400;

  // Present request
  static const int presentRequestStrategyCommentsType = 1158;
  static const int presentRequestAppStrategyCommentsId = 451974;
  static const int presentRequestCategoryID = 1177;
  static const String presentRequestCategoryType = "PRESENT REQUEST";

  //Request information Application details strategy details
  static const int requestApplicationInfoCategoryID = 7342;
  static const String requestApplicationInfoCategoryType =
      "PURPOSE OF APPLICATION DETAILED";
  static const int requestApplicationInfoStrategyCommentsType = 7342;
  static const int requestApplicationInfoStrategyCommentsId = 7342;

  //Policy Deivation
  static const String policyDeviationFI = "fi";
  static const String policyDeviationCorporate = "corporate";
  static const String policyDeviationCorporateC = "c";

  //Project Contract Application details strategy details
  static const int contractCategoryID = 8444;
  static const String contractCategoryType = "CONTRACT";
  static const int contractStrategyCommentsType = 8444;
  static const int contractStrategyCommentsId = 8444;
  //CONTRACT
  static const String strategyCategoryContract = "CONTRACT";
  static const String strategyCategoryESGDynamicSection = "ESG_SECTION";

  //CCSYS
  static const String strategyCategoryCCSYS = "CCSYS";
  static const int ccsysAppReferenceId = 11618;
  static const String ccsysAppReferenceName = "CCSYS";
  static const String ccsysAppReference1 = "CS";
  static const String ccsysAppReference2 = "APN";
  static const String ccsysAppReference3 = "C";
  static const String ccsysAppReference4 = "NA";
  static const String ccsysAppReference5 = "";
  static const String legalStatusNP = "NP";
  static const String legalStatusJP = "JP";
  static const String residenceRE = "RE";
  static const String residenceNR = "NR";
  static const String psLeiYes = "Y";
  static const String psLeiNo = "N";
  static const String lifeCycleStatusWaiting = "waiting";
  static const String lifeCycleStatusAssigned = "assigned";
  static const Set<int> lifeCycleReadOnlyStatuses = {
    121, //Approved
    122, //Decline
    123, //Cancelled
    1779, //Terminated
    1907, //Completed
  };

  //User Action Id  Reference Dat _id       User Action     Reference Data key
  //USER_ACTION_TYPE
  static const int userActionReturn = 3192;
  static const int userActionApproved = 1908;
  static const int userActionDeclineCancel = 1909;
  static const int userActionRecommend = 1910;
  static const int returnForClarification = 15397;
  static const int returnForQuery = 15398;
  static const int sendToDocumentMaker = 13859;
  static const int sendToDocumentChecker = 13861;
  static const int sendToRORM = 13860;
  static const int returnToCCUmaker = 3192;
  static const int acceptCloseApplication = 13853;
  static const int assignToUser = 3193;
  static const int initiateFinalFOL = 3194;
  static const int finalFOLGenerated = 3198;

  // 1908	23	Approved
  // 1909	23	Declined
  // 1910	23	Recommended

  //Search Project
  static const String project = "Project";
  static const String contract = "Contract";
  static const int mainContractorId = 14825;
  static const String mainContractor = "Main Contractor";

  //Percentage calcilation max reach
  static const String dot_100 = "100.";
  static const String max_100 = "100";
  static const int int_100 = 100;

  /// Facility Security Linkage
  static const int facilityLinkageLimitCaps = 935;
  static const facilityTypeReferenceID = 4; // in create a facility reference
  static const int facilityTypeOthersID = 15771;
  static const int fiFacilityTypeOthersID = 15705;
  static const String newProductCode = "NEW_PRODUCT";
  // === LC/LG reference IDs (Conventional + Islamic + "All types") === remove 25(For Testing add both)
  // (Use const so they are immutable and sharable everywhere)
  static const Set<int> kLcIds = {
    // LC (Conventional)
    43, 44, 45, 46, 47, 48,
    // LC (Islamic)
    62, 63, 64, 65, 66,
    // LC - All types
    11573, 11574,
  };

  static const Set<int> kLgIds = {
    // LG (Conventional)
    49, 50, 51, 52, 53, 54,
    // LG (Islamic)
    67, 68, 69, 70, 71, 72,
    // LG - All types
    11572, 11575,
  };

  /// Ratings (Country).
  static const List<String> kCountryRatings = <String>[
    "AAA",
    "AA",
    "A",
    "BBB",
    "BB",
    "B",
    "CCC",
    "CC",
    "C",
    "D",
  ];

  /// Covenant Condition
  static const int conditionGeneralId = 14214;
  static const int conditionSpecificId = 14215;
  static const int conditionStandardId = 13945;
  static const int conditionCustomId = 13946;
  static const int conditionActionCreateId = 13936;
  static const int covenantActionCreateId = 14216;
  static const String covenantMode = "Edit";
  static const int conditionStatusNewId = 13933;
  static const String financialCovenantReference2 = "11144";
  static const Set<int> initialFinancialSubtypeIds = {
    11131,
    11132,
    11133,
    11134,
    11135,
    11136,
    11137,
    11138,
    11139,
    11140,
  };

  // static const String conditionPrecedentTerm = "Standard Precedent Term Sheet
  // Conditions 13975";
  // static const String conditionSubsequent = "Standard Conditions Subsequent
  // 13974";
  // static const String conditionPrecedent = "Standard Precedent Conditions
  // 13973";

  //Covenant
  static const int defaultNewStatusId = 11080;
  static const String defaultNewStatus = "New";
  static const int covenantGeneralId = 13851;
  static const int covenantSpecificId = 13852;
  static const String covenantEdit = "Edit";
  static const String covenantCreate = "Add";
  static const int standardDescriptionId = 11095;
  static const int customDescriptionId = 11096;
  static const int auditStatusUnqualified = 11086;
  static const int covenantSubTypeIdForFrequencyFilter = 11126;
  static const List<int> excludedFrequencyIds = [
    11614, // Semiannual
    11615, // Fortnighlty
  ];
  static const int covenantTypeIdNonFinancial = 11145;
  static const int covenantTypeIdFinancial = 11144;
  static const int covenantTypeIdInformation = 11143;
  static const int covenantToBeTestedName =
      9999; //required in spreadsmart data mentioned by BA

  static List<FacilityNew> defaultFacilityList = [
    FacilityNew(limitNo: "ODA0012"),
  ];

  //facility screen ------------
  /// Product codes that make Fee Default Rate table mandatory
  static const Set<String> mandatoryFeeProductCodes = {
    "LCM",
    "LST",
    "B-SCF",
    "S-SCF",
  };

  // Normalization mapping for indexLcLGCommision (server id -> option key)
  static const Map<String, String> dfIndexLcLgCommisionIdToOptionKey = {
    "15748": "fixedCommision",
    "15749": "linkedToTd",
    "15750": "standardTariff",
  };

  // Dynamic dropdown special-case key
  static const String dfIndexLcLgCommisionKey = "indexLcLGCommision";

  static const String yesText = "yes";
  static const String noText = "no";
  static const String facilityAedCurrency = "AED";
  static const String productCodeClt = "CLT"; //limit caps
  static const String limitCapsDescriptionIdString = "935";
  static const String labelNew = "NEW";
  static const String projectNameGeneral = "General";
  static const String productCodeIjrf = "IJRF";
  static const String advanceTypeNonRevolving = "Non- Revolving";
  static const int advanceTypeNonRevolvingId = 232;

  // Facility limit labels (UI)
  static const String mainLimitLabel = "Main Limit";
  static const String subLimitLabel = "Sub Limit";

  // Facility corporate/FI- Groups ID
  static const int termLoanGroupId = 11313;
  static const int generalLimitGroupId = 11312;
  static const int projectSpecificLimitsID = 11315;
  static const int projectStandByLimitID = 11317;
  static const int pfeLimitGroupId = 11314;

  static const int generalTradeGroup = 14504;
  static const int sovergianGroup = 14505;
  static const int dcmGroup = 14506;
  static const int bilateralLoanGroup = 14507;
  static const int treasuryGroup = 14508;
  static const int fixedIncomeGroup = 14509;
  static const int corporateCrossBorderGroup = 14510;

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
    11140,
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
  static const int groupAppStrategyCommentsId = 28;
  static const int groupCategoryID = 937;
  static const String groupCategoryType = "Group Information";
  // Facilities with Other Bank request
  static const int otherBankStrategyCommentsType = 3132;
  static const int otherBankAppStrategyCommentsId = 451916;
  static const int otherBankCategoryID = 938;
  static const String otherBankCategoryType = "Facilities with Other Bank";
  // Facilities with Other BankCBRB request
  static const int cbrbStrategyCommentsType = 3132;
  static const int cbrbAppStrategyCommentsId = 451916;
  static const int cbrbCategoryID = 936;
  static const String cbrbCategoryType = "Central Bank Risk Bureau Data";

  //FI Credit Risk
  static const int fiCreditRisk = 1;
  static const String fiCreditRiskType = "FI Credit Application";

  //YES/NO/NA
  static const int yesRefId = 1904;
  static const int noRefId = 1905;
  static const int naRefId = 1906;

  //Remarks guarantor spreadsheet URL
  // static const String spreadSmartUrl = 'https://spreadsmartcbd.cbd.dev/CBD/';

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
  static const String incomeStatementAnalysis = "Income statement Analysis";
  static const String cashFlowAnalysis = "Cash Flow statement Analysis";
  static const String balanceSheetAnalysis = "Balance Sheet Analysis";
  static const int balanceSheetAnalysisCategory =
      236; // Cash Flow statement Analysis
  static const String unqualified = "Unqualif'd";
  static const String dataNotAvailable = "data not available";
  static const List<String> desiredNames = <String>[
    "Revenue",
    "EBITDA (recurring only)",
    "Net Income",
    "Total Assets",
    "Tangible NetWorth",
    "Cash / Bank Deposits",
    "Total Debt",
    "Net Debt / EBITDA",
  ];

  static const int subSubTypeFinancialProjection = 14191;
  static const int subSubSubTypeCreditApplicationApprovalDecision = 14202;

  static const int languageEnglish = 14192;
  static const int languageArabic = 14193;

  //SIC_CODE_REVIEW
  static const String strategyCategorySICCodeReview = "SIC_CODE_REVIEW";

// Dynamic Form
  static const int dynamicFormSecurityID = 15;
  static const int dynamicFormFacilityID = 14;
  static const String allFacilityProductType = "All";
  static const String facilityMainLimit = "Main Limit ";
  static const String facilitySubLimit = "Sub Limit ";

  static const List<String> guarantorDocumentTypes = <String>[
    "Emirates ID",
    "Passport",
  ];
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
  static const String depositsStrategyCommentCategoryType = "Deposit Strategy";

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

  static const int esgCommentsCategoryId = 13932;
  static const String esgCommentCategoryType = "ESG Comments";

  static const int ermCommentsCategoryId = 13931;
  static const String ermCommentCategoryType = "ERM Comments";

  static const int relationshipProfitabilityDetailedCommentCategoryId = 1160;
  static const String relationshipProfitabilityDetailedCommentCategoryType =
      "Relationship Strategy"; // User Role

  static const int rAROCCommentCategoryId = 15437;
  static const String rAROCCommentCategoryType = "RAROC Comments"; // User Role

  static const int appendixCommentCategoryId = 15175;
  static const String appendixCommentCategoryType =
      "Group Corporate Structure"; // User Role
  static const String hide = "HIDE"; // User Role

  static const int assignToMeAction = 3199;

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
    UserRole.creditCommittee: "CC",
    UserRole.boardOfDirectors: "BD",
    UserRole.limitInputTeam: "LIT",
    UserRole.legalTeam: "LT",
    UserRole.legalTeamCoordinator: "LTCOOD",
  };

  static const Map<String, UserRole> userCodeRole = {
    "ADM": UserRole.admin,
    "RO": UserRole.relationshipOfficer,
    "RM": UserRole.relationshipManager,
    "TLB": UserRole.teamLeaderBusiness,
    "CAM": UserRole.commercialAreaManager,
    "RMB": UserRole.relationshipManagerBussiness,
    "SHB": UserRole.segmentHeadBusiness,
    "CCOOD": UserRole.creditCordinator,
    "CA": UserRole.creditAnalyst,
    "CCP": UserRole.creditCommitteeProxy,
    "BDP": UserRole.boardDirectorProxy,
    "TL-D1": UserRole.teamLeaderCreditLevelD1,
    "SH-D": UserRole.segmentHeadCreditLevelD,
    "SH-C": UserRole.segmentHeadLevelC,
    "SH-B1": UserRole.segmentHeadLevelB1,
    "SH-B": UserRole.segmentHeadLevelB,
    "CCPA": UserRole.creditCommitteeProxyApprover,
    "BDPA": UserRole.boardDirectorProxyApproval,
    "DC": UserRole.documentationChecker,
    "DM": UserRole.documentationMaker,
    "CCU-M": UserRole.ccuMaker,
    "CCU-C": UserRole.ccuChecker,
    "BADM": UserRole.businessAdmin,
    "ICSADM": UserRole.icsAdmin,
    "INQUSR": UserRole.inquiryUser,
    "FPCOOD": UserRole.financialPoolCoordinator,
    "FPM": UserRole.financialPoolMaker,
    "FPC": UserRole.financialPoolChecker,
    "CC": UserRole.creditCommittee,
    "BD": UserRole.boardOfDirectors,
    "LIT": UserRole.limitInputTeam,
    "LT": UserRole.legalTeam,
    "LTCOOD": UserRole.legalTeamCoordinator,
  };

  static const Map<CertificationType, String> certificationtypeCode = {
    CertificationType.rm: "RM",
    CertificationType.limitInput: "LIT",
    CertificationType.documentation: "DC",
  };

  static const Map<BusinessSegment, int> businessSegmentId = {
    BusinessSegment.corporate: 14485,
    BusinessSegment.financialInstitution: 14486,
  };

  static const Map<BusinessSegment, String> businessSegmentType = {
    BusinessSegment.corporate: "Corporate",
    BusinessSegment.financialInstitution: "Financial Institution",
  };

  static const Map<RequestType, int> requestTypeId = {
    RequestType.fullCA: 100,
    RequestType.isolated: 102,
  };

  static const categoryNameOrder = <String>[
    "New to Bank",
    "Annual Review - Same Level",
    "Annual Review - Increase",
    "Annual Review - Decrease",
    "Interim Review - Same Level",
    "Interim Review - Increase",
    "Interim Review - Decrease",
    "Reconsideration - Same Level",
    "Reconsideration - Increase",
    "Reconsideration - Decrease",
    "Facility Cancelation",
    "Isolated Memo",
  ];

  static const stageNamesOrder = <String>[
    "FOL not required",
    "FOL Draft under Preparation",
    "FOL Draft under RM/RO review",
    "FOL Draft under DC review",
    "FOL Draft under Finalization",
    "FOL under client sign off",
    "Executed Documents under review",
    "Discrepancies advised to RM",
    "Final Fit to lend checks",
    "Final fit to lend checks review with DC",
    "Fit to Lend checks completed",
  ];

  //This is for new changes for Custom Application Type base
  static const Map<ApplicationType, int> applicationTypeIdCustom = {
    ApplicationType.newToBank: 15809, // NTB
    ApplicationType.annualReview: 15810, // Annual Review
    ApplicationType.interimAmendment: 15811, // Interim / Amendment
    ApplicationType.reconsideration: 15813, // Reconsideration
    ApplicationType.markForward: 15817, // Mark Forward
    ApplicationType.riskRatingChange: 15819, // Risk Rating / Staging
    ApplicationType.documentationDeferral: 15820, // Documentation Deferral
    ApplicationType.oneOffLimit:
        15818, // One-off Limits against 100% cash margin
    ApplicationType.cancellation: 15814, // Cancellation
    ApplicationType.isolatedOther: 15815, // Isolated - Others
    ApplicationType.isolatedProjectAllocation:
        15816, // Isolated - Project Allocation
    ApplicationType.isolatedExcessType: 15812, // Isolated - Excess Type
    ApplicationType.isolatedAllocation: 15821, // Isolated - Allocation
  };

  static const Map<ApplicationType, String> applicationSubTypeCode = {
    ApplicationType.newToBank: "NW", // NTB
    ApplicationType.annualReview: "AR", // Annual Review
    ApplicationType.interimAmendment: "AM", // Interim / Amendment
    ApplicationType.reconsideration: "R", // Reconsideration
    ApplicationType.markForward: "MF", // Mark Forward
    ApplicationType.riskRatingChange: "RR", // Risk Rating / Staging
    ApplicationType.documentationDeferral: "DD", // Documentation Deferral
    ApplicationType.oneOffLimit:
        "CM", // One-off Limits against 100% cash margin
    ApplicationType.cancellation: "CA", // Cancellation
    ApplicationType.isolatedOther: "IO", // Isolated - Others
    ApplicationType.isolatedProjectAllocation:
        "IP", // Isolated - Project Allocation
    ApplicationType.isolatedExcessType: "IE", // Isolated - Excess Type
    ApplicationType.isolatedAllocation: "IA", // Isolated - Allocation
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

  static const int annualReview = 15810;

  static const int documentForRm = 2121;
  static const int documentForCredit = 3244;

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

  static Map<int, Reference> facilityValuationRefs = {
    14184: Reference(
      id: 14184,
      name: "Facility Documents",
      description: "File Attachement - Facility Documents",
      isActive: true,
    ),
    14185: Reference(
      id: 14185,
      name: "Valuation Reports",
      description: "File Attachement - Valuation Reports",
      isActive: true,
    ),
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
    RemarksTabs.security: 8421,
  };

  static const int applicationTypeCancelId = 108; //Cancellation
  static const int applicationTypeReconsiderationId = 15813; //Reconsideration

  static const Map<CommentsType, int> commentTypeId = {
    CommentsType.requestApplicationDetailed: 7342,
    CommentsType.security: 123,
    CommentsType.approval: 939, // 3 change to 939
    CommentsType.requestForFOL: 878,
    CommentsType.requestForClosure: 939,
    CommentsType.requestForLimitRelease: 15169,
    CommentsType.queriesResponses: 6345,
    CommentsType.presentRequest: 1158,
    CommentsType.securityPerfection: 4256,
    CommentsType.facilitiesWithCbd: 3139,
    CommentsType.facilitiesWithOtherBank: 3132,
    CommentsType.centralBankRiskBureauData: 3132,
    CommentsType.conditionsSummary: 216,
    CommentsType.covenantsSummary: 215,
    CommentsType.remarks: 1156,
    CommentsType.accountStats: 28,
    CommentsType.sicCodeReview: 8000,
    CommentsType.strategyComments: 1155,
    CommentsType.terminateWithdraw: 1842,
    CommentsType.shareWallet: 2139,
    CommentsType.riskRating: 14931,
    CommentsType.externalRiskRatingFi: 15466,
    CommentsType.contract: 8444,
    CommentsType.relationshipProfitabilityDetailed: 64,
    CommentsType.rarocCommonComments: 15437,
    CommentsType.creditAppraisal: 1159,
    CommentsType.ccsys: 939,
    CommentsType.appendix: 15175,
    CommentsType.creditBrief: 1159,
    CommentsType.groupSummary: 15125,
    CommentsType.groupOverview: 15127,
    CommentsType.groupManagement: 15128,
    CommentsType.successionRisk: 15129,
    CommentsType.relationshipStrategy: 15130,
    CommentsType.managementComment: 15126,
    CommentsType.countrySummary: 15125,
    CommentsType.recommendCurrentApproval: 15468,
    CommentsType.folAdditionalComment: 15767,
    CommentsType.previousCreditApproval: 15768,
  };

  static const Map<CommentsCategory, int> commentCategoryId = {
    CommentsCategory.requestApplicationDetailed: 7342,
    CommentsCategory.security: 123,
    CommentsCategory.approval: 939,
    CommentsCategory.requestForFOL: 878,
    CommentsCategory.requestForClosure: 939,
    CommentsCategory.requestForLimitRelease: 15169,
    CommentsCategory.queriesResponses: 6345,
    CommentsCategory.presentRequest: 1158,
    CommentsCategory.securityPerfection: 4255,
    CommentsCategory.facilitiesWithCbd: 28,
    CommentsCategory.facilitiesWithOtherBank: 3139,
    CommentsCategory.centralBankRiskBureauData: 3132,
    CommentsCategory.conditionsSummary: 216,
    CommentsCategory.covenantsSummary: 216,
    CommentsCategory.remarks: 1156,
    CommentsCategory.accountStats: 28,
    CommentsCategory.sicCodeReview: 8000,
    CommentsCategory.strategyComments: 1155,
    CommentsCategory.terminateWithdraw: 1842,
    CommentsCategory.shareWallet: 2139,
    CommentsCategory.riskRating: 14931,
    CommentsCategory.contract: 8444,
    CommentsCategory.relationshipProfitabilityDetailed: 64,
    CommentsCategory.rarocCommonComments: 15437,
    CommentsCategory.creditAppraisal: 1159,
    CommentsCategory.ccsys: 939,
    CommentsCategory.appendix: 15175,
    CommentsCategory.creditBrief: 1159,
    CommentsCategory.groupSummary: 15125,
    CommentsCategory.groupOverview: 15127,
    CommentsCategory.groupManagement: 15128,
    CommentsCategory.successionRisk: 15129,
    CommentsCategory.relationshipStrategy: 15130,
    CommentsCategory.managementComment: 15126,
  };

  static const Map<ApprovalCategory, int> approvalCategoryId = {
    ApprovalCategory.creditAppraisal: 15135,
    ApprovalCategory.creditBreif: 15136,
    ApprovalCategory.groupOverview: 15127,
    ApprovalCategory.groupManagement: 15128,
    ApprovalCategory.groupRisk: 15129,
    ApprovalCategory.groupStrategy: 15130,
    ApprovalCategory.creditCommittee: 15131,
    ApprovalCategory.ccoComment: 15132,
    ApprovalCategory.ceoComment: 15133,
    ApprovalCategory.bcicComment: 15134,
    ApprovalCategory.request: 15461,
    ApprovalCategory.rational: 15462,
    ApprovalCategory.summaryOfLastDev: 15463,
    ApprovalCategory.bankingSector: 15464,
    ApprovalCategory.fiRecommendation: 15465,
    ApprovalCategory.recommendCurrentApproval: 15469,
    ApprovalCategory.previousCreditApproval: 15769,
  };

  static const Map<ApprovalCategory, String> approvalCategoryType = {
    ApprovalCategory.creditAppraisal: "Credit Assessment Remarks",
    ApprovalCategory.creditBreif: "Credit Brief (Group Exposure Summary)",
    ApprovalCategory.groupOverview:
        "Group Overview,Ownership and Corporate Structure",
    ApprovalCategory.groupManagement:
        "Group Management Team, Ownership and Corporate Structure",
    ApprovalCategory.groupRisk: "Succession/Keyman Risk/Management Risk",
    ApprovalCategory.groupStrategy: "Relationship and Future Strategy",
    ApprovalCategory.creditCommittee: "Credit Committee Recommendations",
    ApprovalCategory.ccoComment: "CCO Comments",
    ApprovalCategory.ceoComment: "CEO Comments",
    ApprovalCategory.bcicComment: "BCIC Comments",
    ApprovalCategory.request: "Request",
    ApprovalCategory.rational: "Rationale",
    ApprovalCategory.summaryOfLastDev:
        "Summary of Latest developments & Highlights",
    ApprovalCategory.bankingSector: "Banking Sector",
    ApprovalCategory.fiRecommendation: "FI Recommendation",
    ApprovalCategory.recommendCurrentApproval:
        "Recommendation for Current Approval",
    ApprovalCategory.previousCreditApproval: "Previous CC/BCIC Credit Approval",
  };

  static const Map<EntityIdentifier, int> entityId = {
    EntityIdentifier.requestApplicationDetailed: 7342,
    EntityIdentifier.security: 123,
    EntityIdentifier.approval: 939,
    EntityIdentifier.requestForFOL: 878,
    EntityIdentifier.requestForClosure: 939,
    EntityIdentifier.requestForLimitRelease: 15169,
    EntityIdentifier.queriesResponses: 6345,
    EntityIdentifier.presentRequest: 7342,
    EntityIdentifier.securityPerfection: 4256,
    EntityIdentifier.facilitiesWithCbd: 3139,
    EntityIdentifier.facilitiesWithOtherBank: 3132,
    EntityIdentifier.centralBankRiskBureauData: 3139,
    EntityIdentifier.conditionsSummary: 216,
    EntityIdentifier.covenantsSummary: 215,
    EntityIdentifier.shareWallet: 2139,
    EntityIdentifier.strategyComments: 1155,
    EntityIdentifier.terminateWithdraw: 1842,
    EntityIdentifier.contract: 8444,
    EntityIdentifier.relationshipProfitabilityDetailed: 64,
    EntityIdentifier.rarocCommonComments: 15437,
    EntityIdentifier.creditAssesment: 1159,
    EntityIdentifier.groupSummary: 15125,
    EntityIdentifier.managementComment: 15126,
    EntityIdentifier.ccsys: 939,
    EntityIdentifier.appendix: 15175,
    EntityIdentifier.recommendCurrentApproval: 15468,
    EntityIdentifier.countrySummary: 15125,
    EntityIdentifier.previousCreditApproval: 15768,
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
    // RequestStatus.pendingFinancialSpreading: 118,
    // RequestStatus.fsCompleted: 119,
  };

  // static const Map<String, RequestStatus> requestStatusTitle = {
  //   "Initiated": RequestStatus.initiated,
  //   "Pending Financial Spreading":
  //       RequestStatus.pendingFinancialSpreading, // out of scope
  //   "FS Completed": RequestStatus.fsCompleted, // out of scope
  //   "Pending for Approval": RequestStatus.pendingApproval,
  //   "Approved": RequestStatus.approved,
  //   "Declined": RequestStatus.declined,
  //   "Request withdrawn/cancelled": RequestStatus.requestWithdrawnCancelled,
  //   "Pending FOL issuance": RequestStatus.pendingFolIssuance,
  //   "Terminated": RequestStatus.terminated,
  //   "Completed": RequestStatus.completed,
  //   "FOL sign-off completed, pending fit-to-lend checks":
  //       RequestStatus.folSignOffCompletedPendingFitToLend,
  //   "Fit to lend checks completed, pending Limit Release":
  //       RequestStatus.fitToLendCompletedPendingLimitRelease,
  //   "Pending Limit Release": RequestStatus.pendingLimitRelease,
  //   "FOL not required": RequestStatus.folNotRequired,
  //   "FOL issued, pending sign-off": RequestStatus.folIssuedPendingSignOff,
  // };

  static const Map<RequestStatus, String> requestStatusTitle = {
    RequestStatus.initiated: "Initiated",
    RequestStatus.pendingForApproval: "Pending for Approval",
    RequestStatus.approved: "Approved",
    RequestStatus.declined: "Declined",
    RequestStatus.requestWithdrawnCancelled: "Request withdrawn/cancelled",
    RequestStatus.pendingFolIssuance: "Pending FOL issuance",
    RequestStatus.terminated: "Terminated",
    RequestStatus.completed: "Completed",
    RequestStatus.folIssuedPendingSignOff: "FOL issued, pending sign-off",
    RequestStatus.folSignOffCompletedPendingFitToLend:
        "FOL sign-off completed, pending fit-to-lend checks",
    RequestStatus.fitToLendCompletedPendingLimitRelease:
        "Fit to lend checks completed, pending Limit Release",
    RequestStatus.pendingLimitRelease: "Pending Limit Release",
    RequestStatus.folNotRequired: "FOL not required",
  };

  static const Map<ApplicationSubType, String> applicationSubType = {
    ApplicationSubType.riskRating: "RR",
    ApplicationSubType.cashMargin: "CM",
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

  static const Map<FacilityType, int> facilityTypeId = {
    FacilityType.overdraftRealEstateProject:
        17, // Overdraft Real Estate/Project
    FacilityType.overdraftAgainstSharesBonds:
        18, // Overdraft against Shares/Bonds
    FacilityType.flexiOverdraft: 19, // Flexi Overdraft
    FacilityType.overdraftAgainstProgressPaymentCertificate:
        20, // Overdraft against Progress Payment Certificate
    FacilityType.overdraftOnCbdFsPortfolio: 21, // Overdraft on CBD FS Portfolio
    FacilityType.overdraftAgainstInvestmentProducts:
        22, // Overdraft against investment products
    FacilityType.loanAgainstTasdeer: 23, // Loan against Tasdeer
    FacilityType.chequeDiscounting: 25, // Cheque Discounting
    FacilityType.loanAgainstCollectionDocumentsInventoryFinance:
        26, // Loan against collection documents / Inventory Finance
    FacilityType.exportBillDiscounting: 30, // Export Bill Discounting
    FacilityType.loanAgainstInvoiceSales: 31, // Loan against invoice sales
    FacilityType.loanAgainstProgressPaymentCertificate:
        32, // Loan against Progress Payment Certificate
    FacilityType.loanAgainstTrustReceipt: 33, // Loan Against Trust Receipt
    FacilityType.loanAgainstAcceptanceDocument:
        34, // Loan against acceptance document
    FacilityType.loanAgainstInvoicePurchase:
        35, // Loan against invoice purchase
    FacilityType.termLoanCommercial: 36, // Term Loan - Commercial
    FacilityType.realEstateLoan: 37, // Real Estate Loan
    FacilityType.syndicationLoans: 38, // Syndication Loans
    FacilityType.rentalLoan: 39, // Rental Loan
    FacilityType.vehicleLoan: 40, // Vehicle Loan
    FacilityType.loanForPurchaseOfListedBonds:
        41, // Loan for Purchase of Listed Bonds
    FacilityType.letterOfCreditOverseasTime:
        43, // Letter of Credit - Overseas Time
    FacilityType.letterOfCreditOverseasSight:
        44, // Letter of Credit - Overseas Sight
    FacilityType.letterOfCreditLocalSight: 45, // Letter of Credit - Local Sight
    FacilityType.letterOfCreditLocalTime: 46, // Letter of Credit - Local Time
    FacilityType.standbyLetterOfCredit: 47, // Standby Letter of Credit
    FacilityType.avalisation: 48, // Avalisation
    FacilityType.letterOfGuaranteeBidTender:
        49, // Letter of Guarantee - Bid/Tender
    FacilityType.letterOfGuaranteePerformance:
        50, // Letter of Guarantee - Performance
    FacilityType.letterOfGuaranteeAdvancePayment:
        51, // Letter of Guarantee -Advance Payment
    FacilityType.letterOfGuaranteeFinancial:
        52, // Letter of Guarantee - Financial
    FacilityType.letterOfGuaranteeRetentionAndMaintenance:
        53, // Letter of Guarantee - Retention and maintenance
    FacilityType.letterOfGuaranteeLabourGuarantee:
        54, // Letter of Guarantee -Labour Guarantee
    FacilityType.murabaha: 56, // Murabaha
    FacilityType.tawarruq: 58, // Tawarruq
    FacilityType.ijarah: 59, // Ijarah
    FacilityType.forwardIjarah: 60, // Forward Ijarah
    FacilityType.overdraftIslamic: 61, // Overdraft Islamic
    FacilityType.letterOfCreditOverseasSightIslamic:
        62, // Letter of Credit - Overseas Sight (Islamic)
    FacilityType.letterOfCreditLocalSightIslamic:
        63, // Letter of Credit - Local Sight (Islamic)
    FacilityType.letterOfCreditOverseasTimeIslamic:
        64, // Letter of Credit - Overseas Time (Islamic)
    FacilityType.letterOfCreditLocalTimeIslamic:
        65, // Letter of Credit - Local Time (Islamic)
    FacilityType.standbyLetterOfCreditIslamic:
        66, // Standby Letter of Credit (Islamic)
    FacilityType.letterOfGuaranteeBidIslamic:
        67, // Letter of Guarantee Bid (Islamic)
    FacilityType.letterOfGuaranteeFinancialIslamic:
        68, // Letter of Guarantee Financial (Islamic)
    FacilityType.letterOfGuaranteeLabourIslamic:
        69, // Letter of Guarantee Labour (Islamic)
    FacilityType.letterOfGuaranteePerformanceIslamic:
        70, // Letter of Guarantee Performance (Islamic)
    FacilityType.letterOfGuaranteeAdvancePaymentIslamic:
        71, // Letter of Guarantee - Advance Payment (Islamic)
    FacilityType.letterOfGuaranteeRetentionAndMaintenanceIslamic:
        72, // Letter of Guarantee - Retention and Maintenance (Islamic)
    FacilityType.limitCaps: 935, // Limit Caps
    FacilityType.overallPfeLimit: 3131, // Overall PFE Limit
    FacilityType.taharuqAgainstInvoice: 3142, // Taharuq Against Invoice
    FacilityType.vehicleLoanUptoProposedAmount:
        3187, // Vehicle Loan upto Proposed Amount
    FacilityType.tawarrukAgainstPpc: 1848, // Tawarruk against PPC
    FacilityType.prsProfitRateSwaps: 1849, // PRS (profit rate swaps)
    FacilityType.letterOfGuaranteeAllTypes:
        11572, // Letter of Guarantee - All types
    FacilityType.letterOfCreditAllTypes: 11573, // Letter of Credit - All types
    FacilityType.letterOfCreditAllTypesIslamic:
        11574, // Letter of Credit - All types (Islamic)
    FacilityType.letterOfGuaranteeAllTypesIslamic:
        11575, // Letter of Guarantee - All types (Islamic)
    FacilityType.shortTermLoan: 11576, // Short Term Loan
    FacilityType.openAccountTrAdvancePaymentAgainstProFormaInvoices:
        11577, // Open Account TR - Advance Payment against Pro-forma Invoices
    FacilityType.openAccountTrAdvancePaymentAgainstCopiesOfShippingDocuments:
        // Open Account TR - Advance
        // Payment against copies of shipping documents
        11578,
    FacilityType.openAccountTrPostShipmentPostDelivery:
        11579, // Open Account TR - Post Shipment / Post Delivery
    FacilityType.openAccountTrPostDeliveryPostSupplierCreditPeriod:
        11580, // Open Account TR - Post Delivery Post Supplier Credit Period
    FacilityType.moveableAssets: 11581, // Moveable Assets
    FacilityType.immoveableAssets: 11582, // Immoveable Assets
    FacilityType.factoringWithoutRecoursesRevolving:
        11583, // Factoring without recourses (Revolving)
    FacilityType.corporateCreditCard: 11584, // Corporate Credit Card
    FacilityType.buyerLedSupplyChainFinancing:
        11585, // Buyer Led Supply Chain Financing
    FacilityType.sellerLedSupplyChainFinancing:
        11586, // Seller Led Supply Chain Financing
    FacilityType.financingExportCollectionDocuments:
        11587, // Financing export Collection Documents
    FacilityType.tasdeerLtpPre: 11588, // Tasdeer (LTP) (Pre)
    FacilityType.tasdeerLtpPost: 11589, // Tasdeer (LTP) (Post)
    FacilityType.openAccountTrAdvancePaymentAgainstProFormaInvoicesIslamic:
        13871,
    // Open Account TR - Advance Payment against copies of shipping documents
    // (Islamic)
    FacilityType
            .openAccountTrAdvancePaymentAgainstCopiesOfShippingDocumentsIslamic:
        13872,
    // Open Account TR - Post Shipment / Post Delivery (Islamic)
    FacilityType.openAccountTrPostShipmentPostDeliveryIslamic: 13873,
    FacilityType.openAccountTrPostDeliveryPostSupplierCreditPeriodIslamic:
        // Open Account TR - Post Delivery Post Supplier Credit Period (Islamic)
        13874,
    FacilityType.notDisclosure: 14436, // Not Disclosure
  };

  static const Map<UserAction, String> userActionList = {
    UserAction.completed: "Completed",
    UserAction.saveNext: "Save Next",
    UserAction.draftSave: "Draft Save",
    UserAction.approveOnBehalfOf: "Approved",
    UserAction.assignToCreditApprovalTeam:
        "Assign / Reassign to Credit & Credit Approval team",
    UserAction.returned: "Return",
    UserAction.approved: "Approved",
    UserAction.declined: "Declined",
    UserAction.recommended: "Recommended",
    UserAction.acceptCloseApplication: "Accept & Close Application",
    UserAction.selfAssignedCA: "Self Assigned - CA",
    UserAction.returnToPool: "Return to Pool",
    UserAction.assignToAdmin: "Assign / reassign from Admin",
    UserAction.assignFromBusinessAdmin: "Assign / reassign from Business Admin",
  };

  static const Map<FOLTypeAction, String> folTypeActionList = {
    FOLTypeAction.documentationSubmitted: "Documentation Submitted",
    FOLTypeAction.documentationCompleted: "Documentation Completed",
    FOLTypeAction.assignedToDcDm: "Assign to DC/DM",
    FOLTypeAction.initiateFinalFOL: "Initiated Final FOL",
    FOLTypeAction.autoAssignedToDocPool: "Auto Assigned to Documentation Pool",
    FOLTypeAction.draftFolGenerated: "Draft FOL Generated",
    FOLTypeAction.finalFolGenerated: "Final FOL Generated",
    FOLTypeAction.selfAssignedCcuMaker: "Self Assigned - CCU Maker",
    FOLTypeAction.sendToCCUChecker: "Send to CCU Checker",
    FOLTypeAction.autoAssigndToCcuPool:
        "Auto Assigned to Credit Control Unit Pool",
    FOLTypeAction.sendToDocumentation: "Send to Documentation",
    FOLTypeAction.sendToDocumentationMaker: "Send to Documentation Maker",
    FOLTypeAction.sendToRoRm: "Send to RO/RM",
    FOLTypeAction.sendToDocumentationChecker: "Send to Documentation Checker",
    FOLTypeAction.sendToCCU: "Send to CCU",
    FOLTypeAction.initiateFitToLend: "Initiate Fit-to-lend",
    FOLTypeAction.sendToCCUMaker: "Send to CCU Maker",
    FOLTypeAction.returnFromDocCCU: "Return from Documentation /CCU",
    FOLTypeAction.initiatedDraftFOL: "Initiated Draft FOL",
    FOLTypeAction.returnForAmendment: "Returned For Amendment",
    FOLTypeAction.returnForAmendmentCMO: "Returned For Amendment (CMO)",
    FOLTypeAction.initiateLimitLoading: "Initiate Limit Loading",
    FOLTypeAction.sentToLimitLoading: "Sent to limit loading",
    FOLTypeAction.executedDocsUnderReview: "Executed Docs under review",
    FOLTypeAction.returnToDM: "Returned to DM",
    FOLTypeAction.folNotRequired: "FOL Not Required",
  };
// ─────────────────────────────────────────────────────────────────────────
// Workflow Config
// ─────────────────────────────────────────────────────────────────────────

// Status
  static const String active = "Active";
  static const String inactive = "Inactive";
  static const List<String> statusOptions = [active, inactive];

// ── Request Type codes ──────────────────────────
  static const String requestTypeCodeFull = "FULL";
  static const String requestTypeCodeMemo = "MEMO";

  static const String requestTypeLabelFull = "Full CA";
  static const String requestTypeLabelMemo = "Memo";

  static const Map<String, String> requestTypeCodeToLabel = {
    requestTypeCodeFull: requestTypeLabelFull,
    requestTypeCodeMemo: requestTypeLabelMemo,
  };

  static const Map<String, String> requestTypeLabelToCode = {
    requestTypeLabelFull: requestTypeCodeFull,
    requestTypeLabelMemo: requestTypeCodeMemo,
  };

  // ── Segment codes ───────────────────────────────
  static const String segmentCodeCorporate = "C";
  static const String segmentCodeFI = "F";

  static const String segmentLabelCorporate = "Corporate";
  static const String segmentLabelFI = "FI";

  static const Map<String, String> segmentCodeToLabel = {
    segmentCodeCorporate: segmentLabelCorporate,
    segmentCodeFI: segmentLabelFI,
  };

  static const Map<String, String> segmentLabelToCode = {
    segmentLabelCorporate: segmentCodeCorporate,
    segmentLabelFI: segmentCodeFI,
  };

// ─────────────────────────────────────────────────────────────────────────
// Workflow Config end
// ─────────────────────────────────────────────────────────────────────────
}

void testServerConstants() {
  [
    ServerConstants.roId,
    ServerConstants.rmId,
    ServerConstants.caId,
    ServerConstants.tlbId,
    ServerConstants.camId,
    ServerConstants.rmbId,
    ServerConstants.shbId,
    ServerConstants.tldId,
    ServerConstants.ccpId,
    ServerConstants.bdpId,
    ServerConstants.bdId,
    ServerConstants.ccId,
    ServerConstants.shlbId,
    ServerConstants.shlcId,
    ServerConstants.shldId,
    ServerConstants.lgtId,
    ServerConstants.lmtId,
    ServerConstants.ccoodId,
    ServerConstants.admId,
    ServerConstants.inqusrId,
    ServerConstants.ltId,
    ServerConstants.ltcoodId,
    ServerConstants.optionNAid,
    ServerConstants.optionNOid,
    ServerConstants.optionYESid,
    ServerConstants.optionBothId,
    ServerConstants.mainLimitTypeID,
    ServerConstants.financialInstitutionId,
    ServerConstants.applicationIsolatedId,
    ServerConstants.applicationFullCAId,
    ServerConstants.applicationTypeFIOneOff,
    ServerConstants.referenceDataIdTitle,
    ServerConstants.referenceNameTitle,
    ServerConstants.referenceDescriptionTitle,
    ServerConstants.reference1Title,
    ServerConstants.reference2Title,
    ServerConstants.reference3Title,
    ServerConstants.reference4Title,
    ServerConstants.reference5Title,
    ServerConstants.referenceStatusTitle,
    ServerConstants.accessRightUpdate,
    ServerConstants.accessRightSave,
    ServerConstants.bySegmentOrRegionId,
    ServerConstants.groupId,
    ServerConstants.advancedRequestTypeId,
    ServerConstants.customerRIMNumberId,
    ServerConstants.applicationReferenceNumberId,
    ServerConstants.securityStrategyCommentsType,
    ServerConstants.securityAppStrategyCommentsId,
    ServerConstants.securityCategoryID,
    ServerConstants.securityCategoryType,
    ServerConstants.appRefNo,
    ServerConstants.rmNameId,
    ServerConstants.pendingWithId,
    ServerConstants.presentRequestStrategyCommentsType,
    ServerConstants.presentRequestAppStrategyCommentsId,
    ServerConstants.presentRequestCategoryID,
    ServerConstants.presentRequestCategoryType,
    ServerConstants.requestApplicationInfoCategoryID,
    ServerConstants.requestApplicationInfoCategoryType,
    ServerConstants.requestApplicationInfoStrategyCommentsId,
    ServerConstants.requestApplicationInfoStrategyCommentsType,
    ServerConstants.conditionGeneralId,
    ServerConstants.conditionSpecificId,
    ServerConstants.conditionStandardId,
    ServerConstants.conditionCustomId,
    ServerConstants.terminateCategoryID,
    ServerConstants.customerName,
    ServerConstants.groupName,
    ServerConstants.requestName,
    ServerConstants.attachmentCertificatesID,
    ServerConstants.groupStrategyCommentsType,
    ServerConstants.groupAppStrategyCommentsId,
    ServerConstants.groupCategoryID,
    ServerConstants.groupCategoryType,
    ServerConstants.otherBankStrategyCommentsType,
    ServerConstants.otherBankAppStrategyCommentsId,
    ServerConstants.otherBankCategoryID,
    ServerConstants.otherBankCategoryType,
    ServerConstants.cbrbStrategyCommentsType,
    ServerConstants.cbrbAppStrategyCommentsId,
    ServerConstants.cbrbCategoryID,
    ServerConstants.cbrbCategoryType,
    ServerConstants.fiCreditRisk,
    ServerConstants.fiCreditRiskType,
    ServerConstants.largeExposureBreachId,
    ServerConstants.userRoleCode,
    ServerConstants.businessSegmentId,
    ServerConstants.requestTypeId,
    ServerConstants.applicationTypeId,
    ServerConstants.documentTypeId,
    ServerConstants.customerTypeId,
    ServerConstants.applicationTypeCancelId,
    ServerConstants.applicationTypeReconsiderationId,
    ServerConstants.commentTypeId,
    ServerConstants.entityId,
    ServerConstants.covenantTypeId,
    ServerConstants.covenantSubTypeId,
    ServerConstants.nonFunded,
  ];
}
