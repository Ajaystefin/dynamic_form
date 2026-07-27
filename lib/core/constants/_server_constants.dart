import "package:easy_localization/easy_localization.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";

/// Application-wide server constants, reference IDs, mappings,
/// configuration values, and lookup collections used across WCAS.
class ServerConstants {
  /// Relationship Officer role ID.
  static const int roId = 125;

  /// Relationship Manager role ID.
  static const int rmId = 126;

  /// Credit Analyst role ID.
  static const int caId = 135;

  /// Team Leader Business role ID.
  static const int tlbId = 127;

  /// Commercial Area Manager role ID.
  static const int camId = 128;

  /// Relationship Manager Business role ID.
  static const int rmbId = 129;

  /// Segment Head Business role ID.
  static const int shbId = 130;

  /// Team Leader Credit Level D1 role ID.
  static const int tldId = 136;

  /// Credit Committee Proxy role ID.
  static const int ccpId = 140;

  /// Board Director Proxy role ID.
  static const int bdpId = 141;

  /// Board Director role ID.
  static const int bdId = 3189;

  /// Credit Committee role ID.
  static const int ccId = 140;

  /// Segment Head Level B role ID.
  static const int shlbId = 139;

  /// Segment Head Level B1 role ID.
  static const int shlb1Id = 11397;

  /// Segment Head Level C role ID.
  static const int shlcId = 138;

  /// Segment Head Level D role ID.
  static const int shldId = 137;

  /// Legal Team role ID.
  static const int lgtId = 3203;

  /// Limit Management Team role ID.
  static const int lmtId = 3202;

  /// Credit Coordinator role ID.
  static const int ccoodId = 134;

  /// Administrator role ID.
  static const int admId = 2024;

  /// Inquiry User role ID.
  static const int inqusrId = 3251;

  /// Legal Team role ID.
  static const int ltId = 3203;

  /// Legal Team Coordinator role ID.
  static const int ltcoodId = 6343;

  /// Not Applicable option ID.
  static const int optionNAid = 1906;

  /// No option ID.
  static const int optionNOid = 1905;

  /// Yes option ID.
  static const int optionYESid = 1904;

  /// Both option ID.
  static const int optionBothId = 15739;

  /// Main limit type ID.
  static const int mainLimitTypeID = 280;

  /// Islamic product type ID.
  static const int productTypeIslamicID = 11322;

  /// Credit Committee Proxy Approver role ID.
  static const int ccpaId = 3188;

  /// Board Director Proxy Approval role ID.
  static const int bdpaId = 3189;

  /// Documentation Checker role ID.
  static const int dcId = 3203;

  /// Documentation Maker role ID.
  static const int dmId = 6343;

  /// CCU Checker role ID.
  static const int ccucId = 11398;

  /// CCU Maker role ID.
  static const int ccumId = 3202;

  /// Maps user roles to their corresponding server role IDs.
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
    UserRole.inquiryUser: inqusrId,
    UserRole.creditCommittee: ccId,
    UserRole.boardOfDirectors: bdId,
    UserRole.legalTeam: ltId,
    UserRole.legalTeamCoordinator: ltcoodId,
  };

  /// Request///

  /// Financial Institution customer type ID.
  static const int financialInstitutionId = 14486;

  /// Isolated application request type ID.
  static const int applicationIsolatedId = 102;

  /// Full Credit Application request type ID.
  static const int applicationFullCAId = 100;

  /// Financial request type ID.
  static const int requestFinancialId = 101;

  /// FI one-off limit application type ID.
  static const int applicationTypeFIOneOff = 11389;

  /// Corporate segment code.
  static const String corperateCode = "C";

  /// Financial Institution segment code.
  static const String financialCode = "F";

  /// Financial segment value used for party inquiry.
  static const String financialSegmentPartyInq = "Fin Inst and CF";

  /// Appendix ///

  /// S&P rating appendix identifier.
  static const String ratingSP = "RatingSP";

  /// Country map appendix identifier.
  static const String countryMap = "CountryMap";

  /// Country government appendix identifier.
  static const String countryGovt = "CountryGovt";

  /// Corporate appendix category.
  static const String corporate = "corporate";

  /// Financial institution appendix category.
  static const String financialInstitution = "financialInstitution";

  /// Bank appendix category.
  static const String bank = "Bank";

  /// Financial appendix category.
  static const String financial = "Financial";

  /// Country appendix category.
  static const String country = "Country";

  /// Threats appendix section.
  static const String threats = "threats";

  /// Strengths appendix section.
  static const String strengths = "strengths";

  /// Below investment grade bank category.
  static const String bigBank = "Below Investment Grade - Bank";

  /// Group corporate structure appendix section.
  static const String groupCorporateStucture = "Group Corporate Structure";

  /// PNG file extension.
  static const String pngExtension = ".png";

  /// JPG file extension.
  static const String jpgExtension = ".jpg";

  /// JPEG file extension.
  static const String jpegExtension = ".jpeg";

  /// TIFF file extension.
  static const String bmpExtension = ".tiff";

  /// TIF file extension.
  static const String webpExtension = ".tif";

  /// XLSX file extension.
  static const String xlsxExtension = ".xlsx";

  /// XLS file extension.
  static const String xlsExtension = ".xls";

  /// PDF document type.
  static const String pdf = "PDF";

  /// Word document type.
  static const String word = "Word";

  /// Map appendix search hint.
  static const String mapHint = "map";

  /// Government appendix search hint.
  static const String govHint = "gov";

  /// Government keyword hint.
  static const String governmentHint = "government";

  /// Rating search hint.
  static const String ratingHint = "rating";

  /// Funded facility type.
  static const String funded = "FUNDED";

  /// Non-funded facility type.
  static const String nonFunded = "NON FUNDED";

  /// Individual customer type code.
  static const String indi = "INDI";

  /// Create new request ///

  /// Isolated memo request type ID.
  ///
  /// 102
  static const int isolatedMemoId = 102;

  /// Isolated memo request type code.
  ///
  /// 102
  static const String isolatedMemo = "MEMO";

  /// FI country customer type ID.
  static const int countryIDFI = 14487;

  /// FI country customer type name.
  static const String countryNameFI = "country";

  /// FI country class code.
  static const String countryClassCode = "7018";

  /// Create Security ///

  /// Entity customer type.
  static const String entity = "Entity";

  /// Natural person customer type.
  static const String naturalPerson = "Natural Person";

  /// Sub-segment validation reference value.
  static const String subSegmentValidationRefId = "Y";

  /// Default business segment.
  static const String defaultSegment = "Corporate";

  /// Default branch name.
  static const String defaultBranch = "Al Qouz Branch";

  /// Default region name.
  static const String defaultRegion = "Jumeirah";

  /// Bank guarantee security type ID.
  static const int bankGuaranteeId = 79;

  /// Corporate guarantee security type ID.
  static const int corporateGuaranteeId = 85;

  /// Personal guarantee security type ID.
  static const int personalGuaranteeId = 76;

  /// Financial guarantee security type ID.
  static const int financialGuranteeID = 14217;

  /// Personal customer type.
  static const String personal = "Personal";

  /// Default branch number.
  static const int defaultBranchNo = 17;

  /// Customer Party Status Check ///

  /// Closed party status value.
  static const String partyStatusClosed = "Closed";

  /// National ID identification type.
  static const String nationalID = "NationalID";

  /// Emirates identification type.
  static const String emirates = "Emirates";

  /// Resident status value.
  static const String residentValue = "R";

  /// Resident yes indicator.
  static const String residentYes = "y";

  /// Resident no indicator.
  static const String residentNo = "n";

  /// Admin Reference Data ///

  /// Sub-segment validation reference type ID.
  static const int subSegmentValidationReftType = 2329;

  /// Reference data type ID used for ESG section headings.
  static const int esgSectionReferenceTypeId = 2096;

  /// Reference data type name used for ESG section headings.
  static const String esgSectionReferenceTypeName = "ESG_SECTION_NAME";

  /// Reference data IDs for ESG section records whose status remains
  /// read-only in the update dialog.
  static const Set<int> esgSectionLockedReferenceIds = {
    8636,
    8637,
    8638,
    8639,
    8640,
    8641,
  };

  /// Reference Data ID column title.
  static const String referenceDataIdTitle = "Reference Data ID";

  /// Reference name column title.
  static const String referenceNameTitle = "Name";

  /// Reference description column title.
  static const String referenceDescriptionTitle = "Description";

  /// Reference 1 column title.
  static const String reference1Title = "Reference 1";

  /// Reference 2 column title.
  static const String reference2Title = "Reference 2";

  /// Reference 3 column title.
  static const String reference3Title = "Reference 3";

  /// Reference 4 column title.
  static const String reference4Title = "Reference 4";

  /// Reference 5 column title.
  static const String reference5Title = "Reference 5";

  /// Reference status column title.
  static const String referenceStatusTitle = "Status";

  /// Admin Access Rights ///

  /// Access right code for update operations.
  static const String accessRightUpdate = "NW";

  /// Access right code for save operations.
  static const String accessRightSave = "AM";

  /// AED currency code.
  static const String aedCurrency = "AED";

  /// AED currency description.
  static const String aedDescription = "United Arab Emirates";

  /// Admin Role Rights ///

  /// Financial Pool Maker role ID.
  static const int financialPoolMaker = 132;

  /// Financial Pool Checker role ID.
  static const int financialPoolChecker = 133;

  /// Financial Pool Coordinator role ID.
  static const int financialPoolCoordinator = 131;

  /// Credit Application document type ID.
  static const int creditApplicationDocumentType = 14182;

  /// Approval delegation reference name.
  static const String approvalDelegation = "Approval Delegation";

  /// Dashboard ///

  /// Dashboard filter ID for segment or region.
  static const int bySegmentOrRegionId = 4269;

  /// Dashboard filter ID for group.
  static const int groupId = 4263;

  /// Dashboard filter ID for advanced request type.
  static const int advancedRequestTypeId = 4266;

  /// Dashboard filter ID for customer RIM number.
  static const int customerRIMNumberId = 4262;

  /// Dashboard filter ID for application reference number.
  static const int applicationReferenceNumberId = 4261;

  /// Security Perfection ///

  /// Comment type ID for security perfection strategy comments.
  static const int securityStrategyCommentsType = 4255;

  /// Application strategy comments ID for security perfection.
  static const int securityAppStrategyCommentsId = 451974;

  /// Category ID for security perfection.
  static const int securityCategoryID = 4256;

  /// Category type for security perfection.
  static const String securityCategoryType = "Security Perfection";

  /// Sample application reference number.
  static const String appRefNo = "201902APNAR000039";

  /// Reference data ID for RM name.
  static const int rmNameId = 4264;

  /// Reference data ID for pending-with user.
  static const int pendingWithId = 4265;

  /// Reference value for cash collateral security.
  static const String cashCollateralReference = "Y";

  /// Reference value for tangible security.
  static const String tangibleSecurityReference = "T";

  /// Create Security ///

  /// Security provider category ID for an entity.
  static const int securityProviderCategoryEntityId = 8392;

  /// Security provider category ID for a natural person.
  static const int securityProviderCategoryNaturalPersonId = 8391;

  /// FI other security group ID.
  static const int fiOtherSecurityGroupId = 14574;

  /// Commitment account number prefix value 100.
  static const int commitmentAccountNumberStartWith100 = 100;

  /// Commitment account number prefix value 400.
  static const int commitmentAccountNumberStartWith400 = 400;

  /// Present Request ///

  /// Comment type ID for present request strategy comments.
  static const int presentRequestStrategyCommentsType = 1158;

  /// Application strategy comments ID for present requests.
  static const int presentRequestAppStrategyCommentsId = 451974;

  /// Category ID for present requests.
  static const int presentRequestCategoryID = 1177;

  /// Category type for present requests.
  static const String presentRequestCategoryType = "PRESENT REQUEST";

  /// Request Information Application Details Strategy Details ///

  /// Category ID for request application information.
  static const int requestApplicationInfoCategoryID = 7342;

  /// Category type for request application information.
  static const String requestApplicationInfoCategoryType =
      "PURPOSE OF APPLICATION DETAILED";

  /// Strategy comments type ID for request application information.
  static const int requestApplicationInfoStrategyCommentsType = 7342;

  /// Strategy comments ID for request application information.
  static const int requestApplicationInfoStrategyCommentsId = 7342;

  /// Policy Deviation ///

  /// Policy deviation type for financial institutions.
  static const String policyDeviationFI = "fi";

  /// Policy deviation type for corporate customers.
  static const String policyDeviationCorporate = "corporate";

  /// Policy deviation corporate code.
  static const String policyDeviationCorporateC = "c";

  /// Project Contract Application Details Strategy Details ///

  /// Contract category ID.
  static const int contractCategoryID = 16257;

  /// Contract strategy category.
  static const String strategyCategoryContract = "CONTRACT";

  /// ESG dynamic section strategy category.
  static const String strategyCategoryESGDynamicSection = "ESG_SECTION";

  /// ESG section 1 ID.
  static const int esgSection1Id = 8636;

  /// ESG section 2 ID.
  static const int esgSection2Id = 8637;

  /// ESG section 3 ID.
  static const int esgSection3Id = 8638;

  /// ESG section 4 ID.
  static const int esgSection4Id = 8639;

  /// ESG part 1 ID.
  static const int esgPart1Id = 8640;

  /// ESG part 2 ID.
  static const int esgPart2Id = 8641;

  /// ESG Certification - Excluded Activity API Values ///

  /// ESG excluded activity value for Yes.
  static const String esgExcludedActivityYes = "YES";

  /// ESG excluded activity value for No.
  static const String esgExcludedActivityNo = "NO";

  /// ESG excluded activity value for Not Applicable.
  static const String esgExcludedActivityNa = "NA";

  /// CCSYS ///

  /// CCSYS application reference ID.
  static const int ccsysAppReferenceId = 11618;

  /// CCSYS application reference name.
  static const String ccsysAppReferenceName = "CCSYS";

  /// CCSYS application reference value 1.
  static const String ccsysAppReference1 = "CS";

  /// CCSYS application reference value 2.
  static const String ccsysAppReference2 = "APN";

  /// CCSYS application reference value 3.
  static const String ccsysAppReference3 = "C";

  /// CCSYS application reference value 4.
  static const String ccsysAppReference4 = "NA";

  /// CCSYS application reference value 5.
  static const String ccsysAppReference5 = "";

  /// Legal status code for Natural Person.
  static const String legalStatusNP = "NP";

  /// Legal status code for Juridical Person.
  static const String legalStatusJP = "JP";

  /// Residence code for Resident.
  static const String residenceRE = "RE";

  /// Residence code for Non-Resident.
  static const String residenceNR = "NR";

  /// Indicates that a LEI is available.
  static const String psLeiYes = "Y";

  /// Indicates that a LEI is not available.
  static const String psLeiNo = "N";

  /// Lifecycle status value for waiting.
  static const String lifeCycleStatusWaiting = "waiting";

  /// Lifecycle status value for assigned.
  static const String lifeCycleStatusAssigned = "assigned";

  /// Lifecycle statuses that are read-only.
  static const Set<int> lifeCycleReadOnlyStatuses = {
    121, // Approved
    122, // Declined
    123, // Cancelled
    1779, // Terminated
    1907, // Completed
  };

  /// User Action Type ///
  ///
  /// User Action Id  Reference Dat _id  User Action  Reference Data Key  USER_ACTION_TYPE

  /// User action ID for return.
  static const int userActionReturn = 3192;

  /// User action ID for approval.
  static const int userActionApproved = 1908;

  /// User action ID for decline or cancel.
  static const int userActionDeclineCancel = 1909;

  /// User action ID for recommendation.
  static const int userActionRecommend = 1910;

  /// User action ID for return for clarification.
  static const int returnForClarification = 15397;

  /// User action ID for return for query.
  static const int returnForQuery = 15398;

  /// User action ID for sending to Document Maker.
  static const int sendToDocumentMaker = 13859;

  /// User action ID for sending to Document Checker.
  static const int sendToDocumentChecker = 13861;

  /// User action ID for sending to RO/RM.
  static const int sendToRORM = 13860;

  /// User action ID for returning to CCU Maker.
  static const int returnToCCUmaker = 3192;

  /// User action ID for accepting and closing an application.
  static const int acceptCloseApplication = 13853;

  /// User action ID for assigning to a user.
  static const int assignToUser = 3193;

  /// User action ID for initiating Final FOL.
  static const int initiateFinalFOL = 3194;

  /// User action ID for Final FOL generation.
  static const int finalFOLGenerated = 3198;

  // 1908        23        Approved
  // 1909        23        Declined
  // 1910        23        Recommended

  /// Search Project ///

  /// Project entity type.
  static const String project = "Project";

  /// Contract entity type.
  static const String contract = "Contract";

  /// Main contractor reference ID.
  static const int mainContractorId = 14825;

  /// Main contractor label.
  static const String mainContractor = "Main Contractor";

  /// Percentage Calculation Constants ///

  /// String representation of 100 with a decimal point.
  static const String dot_100 = "100.";

  /// String representation of 100.
  static const String max_100 = "100";

  /// Integer value of 100.
  static const int int_100 = 100;

  /// Others Limit Dialog Facility Summary ///

  /// Excluded limit reference ID.
  static const int excludedLimit = 11330;

  /// Excluded limit cap reference ID.
  static const int excludedLimitCap = 11337;

  /// Facility Security Linkage ///

  /// Facility linkage limit caps ID.
  static const int facilityLinkageLimitCaps = 935;

  /// Product code for PSBL.
  static const String productCodePsbl = "PSBL";

  /// Product code for PSPL.
  static const String productCodePspl = "PSPL";

  /// Facility type reference ID.
  static const facilityTypeReferenceID = 4;

  /// Facility type ID for Others.
  static const int facilityTypeOthersID = 15771;

  /// FI facility type ID for Others.
  static const int fiFacilityTypeOthersID = 15705;

  /// Product code for new products.
  static const String newProductCode = "NEW_PRODUCT";

  /// Letter of Credit reference IDs.
  static const Set<int> kLcIds = {
    // LC (Conventional)
    43, 44, 45, 46, 47, 48,
    // LC (Islamic)
    62, 63, 64, 65, 66,
    // LC - All types
    11573, 11574,
  };

  /// Letter of Guarantee reference IDs.
  static const Set<int> kLgIds = {
    // LG (Conventional)
    49, 50, 51, 52, 53, 54,
    // LG (Islamic)
    67, 68, 69, 70, 71, 72,
    // LG - All types
    11572, 11575,
  };

  /// Ratings (Country) ///

  /// Supported country rating values.
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

  /// Covenant Condition ///

  /// General condition ID.
  static const int conditionGeneralId = 14214;

  /// Specific condition ID.
  static const int conditionSpecificId = 14215;

  /// Standard condition ID.
  static const int conditionStandardId = 13945;

  /// Custom condition ID.
  static const int conditionCustomId = 13946;

  /// Create action ID for conditions.
  static const int conditionActionCreateId = 13936; 

  /// New status ID for conditions.
  static const int conditionStatusNewId = 13933;

  /// Reference value for financial covenants.
  static const String financialCovenantReference2 = "11144";

  /// Initial financial covenant subtype IDs.
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

  /// Covenant ///

  /// Default status for newly created covenants.
  static const String defaultNewStatus = "New";

  /// General covenant ID.
  static const int covenantGeneralId = 13851;

  /// Specific covenant ID.
  static const int covenantSpecificId = 13852;

  /// Standard covenant description ID.
  static const int standardDescriptionId = 11095;

  /// Custom covenant description ID.
  static const int customDescriptionId = 11096;

  /// Unqualified audit status ID.
  static const int auditStatusUnqualified = 11086;

  /// Covenant subtype ID used for frequency filtering.
  static const int covenantSubTypeIdForFrequencyFilter = 11126;

  /// Frequency IDs excluded from selection.
  static const List<int> excludedFrequencyIds = [
    11614, // Semiannual
    11615, // Fortnightly
  ];

  /// Non-financial covenant type ID.
  static const int covenantTypeIdNonFinancial = 11145;

  /// Financial covenant type ID.
  static const int covenantTypeIdFinancial = 11144;

  /// Information covenant type ID.
  static const int covenantTypeIdInformation = 11143;

  /// First non-financial covenant subtype ID.
  static const int nonFinancialSubTypefirstItem = 11141;

  /// Second non-financial covenant subtype ID.
  static const int nonFinancialSubTypeSecondItem = 11142;

  /// Covenant name used for SpreadSmart testing.
  static const int covenantToBeTestedName = 9999;

  /// Default facility list used for initialization.
  static List<FacilityNew> defaultFacilityList = [
    FacilityNew(limitNo: "ODA0012"),
  ];

  /// Facility Screen ///

  /// Product codes that make the Fee Default Rate table mandatory.
  static const Set<String> mandatoryFeeProductCodes = {
    "LCM",
    "LST",
    "B-SCF",
    "S-SCF",
  };

  /// Maps index LC/LG commission IDs to option keys.
  static const Map<String, String> dfIndexLcLgCommisionIdToOptionKey = {
    "15748": "fixedCommision",
    "15749": "linkedToTd",
    "15750": "standardTariff",
  };

  /// Dynamic dropdown key for index LC/LG commission.
  static const String dfIndexLcLgCommisionKey = "indexLcLGCommision";

  /// Yes value.
  static const String yesText = "yes";

  /// No value.
  static const String noText = "no";

  /// AED currency code used for facilities.
  static const String facilityAedCurrency = "AED";

  /// Product code for Limit Caps.
  static const String productCodeClt = "CLT";

  /// Limit Caps description ID as a string.
  static const String limitCapsDescriptionIdString = "935";

  /// Label for new records.
  static const String labelNew = "NEW";

  /// Default project name.
  static const String projectNameGeneral = "General";

  /// Product code for IJRF.
  static const String productCodeIjrf = "IJRF";

  /// Advance type for non-revolving facilities.
  static const String advanceTypeNonRevolving = "Non- Revolving";

  /// Reference ID for non-revolving advance type.
  static const int advanceTypeNonRevolvingId = 232;

  /// Facility Limit Labels ///

  /// Label for the main limit.
  static const String mainLimitLabel = "Main Limit";

  /// Label for the sub-limit.
  static const String subLimitLabel = "Sub Limit";

  /// Facility Corporate/FI Group IDs ///

  /// Term loan group ID.
  static const int termLoanGroupId = 11313;

  /// General limit group ID.
  static const int generalLimitGroupId = 11312;

  /// Project-specific limits group ID.
  static const int projectSpecificLimitsID = 11315;

  /// Project standby limit group ID.
  static const int projectStandByLimitID = 11317;

  /// PFE limit group ID.
  static const int pfeLimitGroupId = 11314;

  /// General trade group ID.
  static const int generalTradeGroup = 14504;

  /// Sovereign group ID.
  static const int sovergianGroup = 14505;

  /// DCM group ID.
  static const int dcmGroup = 14506;

  /// Bilateral loan group ID.
  static const int bilateralLoanGroup = 14507;

  /// Treasury group ID.
  static const int treasuryGroup = 14508;

  /// Fixed income group ID.
  static const int fixedIncomeGroup = 14509;

  /// Corporate cross-border group ID.
  static const int corporateCrossBorderGroup = 14510;

  /// Covenant Threshold Type IDs ///

  /// Minimum threshold type ID.
  static const int thresholdTypeMin = 11073;

  /// Maximum threshold type ID.
  static const int thresholdTypeMax = 11074;

  /// Create action ID.
  static const int covenantCreateActionId = 14216;

  /// Covenant Subtype ID Groups ///

  /// Covenant subtype IDs that use a minimum threshold.
  static const List<int> minThresholdSubtypeIds = [11137, 11139];

  /// Covenant subtype IDs that use a maximum threshold.
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

  /// Description Templates ///

  /// Maps financial covenant subtype IDs to their description templates.
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

  /// Terminate/Withdraw ///

  /// Terminate or withdraw category ID.
  static const int terminateCategoryID = 1842;

  /// Certificate Request ///

  /// Sample customer name used for certificate requests.
  static const String customerName = "RIM 50";

  /// Sample group name used for certificate requests.
  static const String groupName = "DCMM MM";

  /// Sample request name used for certificate requests.
  static const String requestName = "Isolate CRPR";

  /// Certificate Attachments ///

  /// Attachment identifier for WCAS certificates.
  static const String attachmentCertificatesID = "WCAS";

  /// Attachment identifier for Mark Forward certificates.
  static const String markForwardCertificatesID = "MF";

  /// Facilities with CBD Request ///

  /// Strategy comments type ID for group information.
  static const int groupStrategyCommentsType = 3139;

  /// Application strategy comments ID for group information.
  static const int groupAppStrategyCommentsId = 28;

  /// Group information category ID.
  static const int groupCategoryID = 937;

  /// Group information category type.
  static const String groupCategoryType = "Group Information";

  /// Facilities with Other Bank Request ///

  /// Strategy comments type ID for facilities with other banks.
  static const int otherBankStrategyCommentsType = 3132;

  /// Application strategy comments ID for facilities with other banks.
  static const int otherBankAppStrategyCommentsId = 451916;

  /// Facilities with other banks category ID.
  static const int otherBankCategoryID = 938;

  /// Facilities with other banks category type.
  static const String otherBankCategoryType = "Facilities with Other Bank";

  /// Central Bank Risk Bureau Data ///

  /// Strategy comments type ID for CBRB data.
  static const int cbrbStrategyCommentsType = 3132;

  /// Application strategy comments ID for CBRB data.
  static const int cbrbAppStrategyCommentsId = 451916;

  /// CBRB category ID.
  static const int cbrbCategoryID = 936;

  /// CBRB category type.
  static const String cbrbCategoryType = "Central Bank Risk Bureau Data";

  /// FI Credit Risk ///

  /// FI credit risk identifier.
  static const int fiCreditRisk = 1;

  /// FI credit risk type.
  static const String fiCreditRiskType = "FI Credit Application";

  /// YES/NO/NA ///

  /// Reference ID for Yes.
  static const int yesRefId = 1904;

  /// Reference ID for No.
  static const int noRefId = 1905;

  /// Reference ID for Not Applicable.
  static const int naRefId = 1906;

  /// Policy Deviation - Large Exposure Breach ///

  /// Large exposure breach reference ID.
  static const int largeExposureBreachId = 8393;

  /// Large exposure breach reference name.
  static const String largeExposureBreachName = "large exposure breach";

  /// Remarks ///

  /// Income statement analysis section name.
  static const String incomeStatementAnalysis = "Income statement Analysis";

  /// Cash flow statement analysis section name.
  static const String cashFlowAnalysis = "Cash Flow statement Analysis";

  /// Balance sheet analysis section name.
  static const String balanceSheetAnalysis = "Balance Sheet Analysis";

  /// Unqualified audit status value.
  static const String unqualified = "Unqualif'd";

  /// Value displayed when data is unavailable.
  static const String dataNotAvailable = "data not available";

  /// Financial metrics displayed in remarks.
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

  /// Financial projection sub-sub-type ID.
  static const int subSubTypeFinancialProjection = 14191;

  /// Credit application approval decision sub-sub-sub-type ID.
  static const int subSubSubTypeCreditApplicationApprovalDecision = 14202;

  /// Credit application approval communication sub-sub-sub-type ID.
  static const int subSubSubTypeCreditApplicationApprovalCommunication = 14203;

  /// English language ID.
  static const int languageEnglish = 14192;

  /// Arabic language ID.
  static const int languageArabic = 14193;

  /// SIC Code Review ///

  /// Strategy category for SIC code review.
  static const String strategyCategorySICCodeReview = "SIC_CODE_REVIEW";

  /// Dynamic Form8 ///

  /// Dynamic form ID for Security.
  static const int dynamicFormSecurityID = 15;

  /// Dynamic form ID for Facility.
  static const int dynamicFormFacilityID = 14;

  /// Option representing all facility product types.
  static const String allFacilityProductType = "All";

  /// Main limit label used in facility forms.
  static const String facilityMainLimit = "Main Limit ";

  /// Sub-limit label used in facility forms.
  static const String facilitySubLimit = "Sub Limit ";

  /// Supported guarantor document types.
  static const List<String> guarantorDocumentTypes = <String>[
    "Emirates ID",
    "Passport",
  ];

  /// Request Information ///

  /// Product type code representing both Conventional and Islamic products.
  static const String productTypeBoth = "B";

  /// Product type code representing Islamic products.
  static const String productTypeIslamic = "I";

  /// Product type code representing Conventional products.
  static const String productTypeConventional = "C";

  /// Profitability and Account Conduct

  /// Account Statistics comment category ID.
  static const int accountStatsCommentCategoryId = 1784;

  /// Account Statistics comment category type.
  static const String accountStatsCommentCategoryType = "Account Statistics";

  /// Relationship Strategy comment category ID.
  static const int relationshipStrategyCommentCategoryId = 1160;

  /// Relationship Strategy comment category type.
  static const String relationshipStrategyCommentCategoryType =
      "Relationship Strategy";

  /// Deposit Strategy comment category ID.
  static const int depositsStrategyCommentCategoryId = 1161;

  /// Deposit Strategy comment category type.
  static const String depositsStrategyCommentCategoryType = "Deposit Strategy";

  /// Transaction Banking comment category ID.
  static const int transactionalBankingCommentCategoryId = 1162;

  /// Transaction Banking comment category type.
  static const String transactionalBankingCommentCategoryType =
      "Transaction Banking Comments";

  /// Trade Finance comment category ID.
  static const int tradeFinanceCommentCategoryId = 1163;

  /// Trade Finance comment category type.
  static const String tradeFinanceCommentCategoryType =
      "Trade Finance Comments";

  /// Treasury comment category ID.
  static const int treasuryCommentCategoryId = 1164;

  /// Treasury comment category type.
  static const String treasuryFinanceCommentCategoryType = "Treasury Comments";

  /// Share of Wallet comment category ID.
  static const int shareWalletCommentCategoryId = 936;

  /// Share of Wallet comment category type.
  static const String shareWalletCommentCategoryType = "share of Wallet";

  /// ESG comments category ID.
  static const int esgCommentsCategoryId = 13932;

  /// ESG comments category type.
  static const String esgCommentCategoryType = "ESG Comments";

  /// ERM comments category ID.
  static const int ermCommentsCategoryId = 13931;

  /// ERM comments category type.
  static const String ermCommentCategoryType = "ERM Comments";

  /// Relationship Profitability Detailed comment category ID.
  static const int relationshipProfitabilityDetailedCommentCategoryId = 1160;

  /// Relationship Profitability Detailed comment category type.
  static const String relationshipProfitabilityDetailedCommentCategoryType =
      "Relationship Strategy";

  /// RAROC comment category ID.
  static const int rAROCCommentCategoryId = 15437;

  /// RAROC comment category type.
  static const String rAROCCommentCategoryType = "RAROC Comments";

  /// Appendix comment category ID.
  static const int appendixCommentCategoryId = 15175;

  /// Appendix comment category type.
  static const String appendixCommentCategoryType = "Group Corporate Structure";

  /// Hide indicator value.
  static const String hide = "HIDE";

  /// Assign-to-me action ID for Documentation Maker.
  static const int assignToMeActionDM = 3199;

  /// Assign-to-me action ID for Credit Analyst.
  static const int assignToMeActionCA = 13854;

  /// CFO BPM role name.
  static const String cfoBpmRole = "Chief Financial Officer-WCAS";

  /// Manual entry value.
  static const String manualEntry = "Manual Entry";

  /// User Roles ///

  /// Maps user roles to their corresponding role codes.
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
    UserRole.icsAdmin: "IAMADM",
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

  /// Maps role codes to their corresponding user roles.
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
    "IAMADM": UserRole.icsAdmin,
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

  /// Certification Types ///

  /// Maps certification types to their corresponding role codes.
  static const Map<CertificationType, String> certificationtypeCode = {
    CertificationType.rm: "RM",
    CertificationType.limitInput: "LIT",
    CertificationType.documentation: "DC",
  };

  /// Business Segments ///

  /// Maps business segments to their corresponding IDs.
  static const Map<BusinessSegment, int> businessSegmentId = {
    BusinessSegment.corporate: 14485,
    BusinessSegment.financialInstitution: 14486,
  };

  /// Maps business segments to their display names.
  static const Map<BusinessSegment, String> businessSegmentType = {
    BusinessSegment.corporate: "Corporate",
    BusinessSegment.financialInstitution: "Financial Institution",
  };

  /// Request Types ///

  /// Maps request types to their corresponding IDs.
  static const Map<RequestType, int> requestTypeId = {
    RequestType.fullCA: 100,
    RequestType.isolated: 102,
  };

  /// Application Categories ///

  /// Ordered list of application category names.
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

  /// Ordered list of workflow stage names.
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

  /// Custom Application Types ///

  /// Maps application types to custom application type IDs.
  static const Map<ApplicationType, int> applicationTypeIdCustom = {
    ApplicationType.newToBank: 15809,
    ApplicationType.annualReview: 15810,
    ApplicationType.interimAmendment: 15811,
    ApplicationType.reconsideration: 15813,
    ApplicationType.markForward: 15817,
    ApplicationType.riskRatingChange: 15819,
    ApplicationType.documentationDeferral: 15820,
    ApplicationType.oneOffLimit: 15818,
    ApplicationType.cancellation: 15814,
    ApplicationType.isolatedOther: 15815,
    ApplicationType.isolatedProjectAllocation: 15816,
    ApplicationType.isolatedExcessType: 15812,
    ApplicationType.isolatedAllocation: 15821,
  };

  /// Maps application types to application subtype codes.
  static const Map<ApplicationType, String> applicationSubTypeCode = {
    ApplicationType.newToBank: "NW",
    ApplicationType.annualReview: "AR",
    ApplicationType.interimAmendment: "AM",
    ApplicationType.reconsideration: "R",
    ApplicationType.markForward: "MF",
    ApplicationType.riskRatingChange: "RR",
    ApplicationType.documentationDeferral: "DD",
    ApplicationType.oneOffLimit: "CM",
    ApplicationType.cancellation: "CA",
    ApplicationType.isolatedOther: "IO",
    ApplicationType.isolatedProjectAllocation: "IP",
    ApplicationType.isolatedExcessType: "IE",
    ApplicationType.isolatedAllocation: "IA",
  };

  /// Maps application types to application type IDs.
  static const Map<ApplicationType, int> applicationTypeId = {
    ApplicationType.newToBank: 103,
    ApplicationType.annualReview: 104,
    ApplicationType.interimAmendment: 105,
    ApplicationType.reconsideration: 107,
    ApplicationType.markForward: 11388,
    ApplicationType.riskRatingChange: 11390,
    ApplicationType.documentationDeferral: 11391,
    ApplicationType.oneOffLimit: 11389,
    ApplicationType.cancellation: 108,
    ApplicationType.isolatedOther: 11387,
    ApplicationType.isolatedProjectAllocation: 11386,
    ApplicationType.isolatedExcessType: 106,
    ApplicationType.isolatedAllocation: 11392,
  };

  /// Custom application type ID for Annual Review.
  static const int annualReview = 15810;

  /// Document Types ///

  /// Maps document types to their corresponding IDs.
  static const Map<DocumentType, int> documentTypeId = {
    DocumentType.constitutionalDocument: 14179,
    DocumentType.creditLensDocument: 14180,
    DocumentType.financialStatements: 14181,
    DocumentType.creditApplication: 14182,
    DocumentType.externalOpinions: 14183,
    DocumentType.facilityDocuments: 14184,
    DocumentType.valuationReports: 14185,
    DocumentType.other: 14186,
    DocumentType.legacy: 14999,
  };

  /// Facility Valuation References

  /// Reference definitions used for facility and valuation documents.
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

  static Map<int, Reference> legacyUncategorizedRefs = {
    14999: Reference(
      id: 14999,
      name: "Legacy Credit Application",
      description: "File Attachement - Legacy Credit Application",
      isActive: true,
    ),
  };

  /// Customer Types ///

  /// Maps customer types to their corresponding IDs.
  static const Map<CustomerType, int> customerTypeId = {
    CustomerType.country: 1,
    CustomerType.belowInvestmentGradeBanks: 2,
    CustomerType.investmentGradeBanks: 3,
  };

  /// UAE country code.
  static const uaeCountryCode = "AE";

  /// Remarks Tabs ///
  /// Income Statement Analysis category identifier.
  static const int incomeFinancialCategory = 234;

  /// Maps remarks tabs to their corresponding IDs.
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

  /// Application Types ///

  /// Application type ID for Cancellation.
  static const int applicationTypeCancelId = 108;

  /// Application type ID for Reconsideration.
  static const int applicationTypeReconsiderationId = 15813;

  /// Comment Types ///

  /// Maps comment types to their corresponding IDs.
  static const Map<CommentsType, int> commentTypeId = {
    CommentsType.requestApplicationDetailed: 7342,
    CommentsType.security: 123,
    CommentsType.approval: 939,
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
    CommentsType.contract: 16257,
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

  /// Comment Categories ///

  /// Maps comment categories to their corresponding IDs.
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
    CommentsCategory.contract: 16257,
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

  /// Approval Categories ///

  /// Maps approval categories to their corresponding IDs.
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

  /// Maps approval categories to their display names.
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

  /// Entity Identifiers ///

  /// Maps entity identifiers to their corresponding IDs.
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
    EntityIdentifier.contract: 16257,
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

  /// Covenant Category IDs ///

  /// Maps covenant types to their corresponding IDs.
  static const Map<CovenantType, int> covenantTypeId = {
    CovenantType.information: 11143,
    CovenantType.financial: 11144,
    CovenantType.nonFinancial: 11145,
    CovenantType.none: 0,
  };

  /// Default facility IDs
  static const List<String> defaultFacilityIds = <String>[
    "GPM0002",
    "GPM0001",
    "LCM0001",
    "PFE0001",
  ];

  /// Covenant Sub-Type IDs //

  /// Maps covenant subtypes to their corresponding IDs.
  static const Map<CovenantSubType, int> covenantSubTypeId = {
    CovenantSubType.financialStatements: 11126,
    CovenantSubType.projectProgressReport: 11127,
    CovenantSubType.debtorsAndStockAgeing: 11128,
    CovenantSubType.personalNetWorthIncomeStatement: 11129,
    CovenantSubType.operatingBudget: 11130,
    CovenantSubType.other: 11613,
    CovenantSubType.none: 0,
  };

  /// Request Statuses ///

  /// Maps request statuses to their corresponding IDs.
  static const Map<RequestStatus, int> requestStatusId = {
    RequestStatus.initiated: 117,
    RequestStatus.pendingForApproval: 120,
    RequestStatus.approved: 121,
    RequestStatus.declined: 122,
    RequestStatus.requestWithdrawnCancelled: 123,
    RequestStatus.pendingFolIssuance: 124,
    RequestStatus.terminated: 1779,
    RequestStatus.completed: 1907,
    RequestStatus.folIssuedPendingSignOff: 11623,
    RequestStatus.folSignOffCompletedPendingFitToLend: 11624,
    RequestStatus.fitToLendCompletedPendingLimitRelease: 11625,
    RequestStatus.pendingLimitRelease: 11626,
    RequestStatus.folNotRequired: 11627,
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

  /// Request Statuses ///

  /// Maps request statuses to their display titles.
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

  /// Application Subtypes ///

  /// Maps application subtypes to their corresponding codes.
  static const Map<ApplicationSubType, String> applicationSubType = {
    ApplicationSubType.riskRating: "RR",
    ApplicationSubType.cashMargin: "CM",
  };

  /// Security Types ///

  /// Maps security types to their corresponding reference data IDs.
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

  /// Facility Types ///

  /// Maps facility types to their corresponding reference data IDs.
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

  /// User Actions ///

  /// Maps user actions to their display names.
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

  /// FOL Type Actions ///

  /// Maps FOL type actions to their display names.
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

  /// Workflow Configuration START ///

  /// Active status value.
  static const String active = "Active";

  /// Inactive status value.
  static const String inactive = "Inactive";

  /// Available workflow status options.
  static const List<String> statusOptions = [active, inactive];

  /// Request Type Codes ///

  /// Request type code for Full CA.
  static const String requestTypeCodeFull = "FULL";

  /// Request type code for Memo.
  static const String requestTypeCodeMemo = "MEMO";

  /// Request type label for Full CA.
  static const String requestTypeLabelFull = "Full CA";

  /// Request type label for Memo.
  static const String requestTypeLabelMemo = "Memo";

  /// Maps request type codes to their labels.
  static const Map<String, String> requestTypeCodeToLabel = {
    requestTypeCodeFull: requestTypeLabelFull,
    requestTypeCodeMemo: requestTypeLabelMemo,
  };

  /// Maps request type labels to their codes.
  static const Map<String, String> requestTypeLabelToCode = {
    requestTypeLabelFull: requestTypeCodeFull,
    requestTypeLabelMemo: requestTypeCodeMemo,
  };

  /// Segment Codes ///

  /// Segment code for Corporate.
  static const String segmentCodeCorporate = "C";

  /// Segment code for Financial Institution.
  static const String segmentCodeFI = "F";

  /// Segment label for Corporate.
  static const String segmentLabelCorporate = "Corporate";

  /// Segment label for Financial Institution.
  static const String segmentLabelFI = "FI";

  /// Maps segment codes to their labels.
  static const Map<String, String> segmentCodeToLabel = {
    segmentCodeCorporate: segmentLabelCorporate,
    segmentCodeFI: segmentLabelFI,
  };

  /// Maps segment labels to their codes.
  static const Map<String, String> segmentLabelToCode = {
    segmentLabelCorporate: segmentCodeCorporate,
    segmentLabelFI: segmentCodeFI,
  };

  /// Workflow Configuration END ///
}

/// Returns server constants used for testing and code coverage.
List<dynamic> testServerConstants() {
  return [
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
