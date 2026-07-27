import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";

void main() {
  group("ReferenceDataKeys", () {
    test("All ReferenceDataKeys have expected string values", () {
      testReferenceKeys(); // Ensures all keys are accessed

      expect(ReferenceDataKeys.requestStatus, "REQUEST_STATUS");
      expect(ReferenceDataKeys.requestType, "REQUEST_TYPE");
      expect(ReferenceDataKeys.applicationType, "APPLICATION_TYPE");
      expect(ReferenceDataKeys.transactionType, "TRANSACTION_TYPE");
      expect(ReferenceDataKeys.roleType, "ROLE_TYPE");
      expect(ReferenceDataKeys.auditEntityList, "AUDIT_ENTITY_LIST");
      expect(ReferenceDataKeys.searchCriteria, "SEARCH_CRITERIA");
      expect(ReferenceDataKeys.advanceRequestType, "ADVANCE REQUEST TYPE");
      expect(ReferenceDataKeys.segmentType, "SEGMENT_TYPE");
      expect(ReferenceDataKeys.regionList, "REGION_LIST");
      expect(ReferenceDataKeys.customerType, "FI_CUSTOMER_TYPE");
      expect(ReferenceDataKeys.applicationSegment, "APPLICATION_SEGMENT");
      expect(ReferenceDataKeys.certificateType, "CERTIFICATE_TYPE");
      expect(ReferenceDataKeys.yesNoNa, "YES/NO/NA");
      expect(ReferenceDataKeys.healthCode, "HEALTH_CODE");
      expect(ReferenceDataKeys.advancePurposeCode, "ADVANCE_PURPOSE_CODE");
      expect(ReferenceDataKeys.sicCodeList, "SIC_CODE_LIST");
      expect(
        ReferenceDataKeys.tlIssuingAuthorityList,
        "TL_ISSUING_AUTHORITY_LIST",
      );
      expect(ReferenceDataKeys.cccStatus, "CCC_STATUS");
      expect(
        ReferenceDataKeys.customerIdentificationList,
        "CUSTOMER_IDENTIFICATION_LIST",
      );
      expect(ReferenceDataKeys.terminationReason, "TERMINATION_REASON");
      expect(ReferenceDataKeys.esgSectionTitles, "ESG_SECTION_NAME");
      expect(
        ReferenceDataKeys.esgAdittionalGuidance,
        "ADDITIONAL_GUIDANCE_INSTRUCTION",
      );
      expect(ReferenceDataKeys.esgSffCategory, "SUSTAINABLE_FINANCE_CATEGORY");
      expect(ReferenceDataKeys.covenantType, "COVENANTS_TYPE");
      expect(ReferenceDataKeys.covenantConditionStatus, "COVENANTS_STATUS");
      expect(ReferenceDataKeys.covenantFrequency, "COVENANTS_FREQUENCY");
      expect(ReferenceDataKeys.covenantConditionAction, "COVENANTS_ACTION");
      expect(
        ReferenceDataKeys.covenantDescriptionTemplate,
        "COVENANT_DESCRIPTION_TEMPLATE",
      );
      expect(ReferenceDataKeys.facilityTypes, "FACILITY_TYPE");
      expect(ReferenceDataKeys.covenantSubtype, "COVENANTS_SUB_TYPE");
      expect(ReferenceDataKeys.covenantPeriod, "COVENANTS_PERIOD");
      expect(
        ReferenceDataKeys.covenantBasicSeperation,
        "COVENANTS_BASIS_OF_PREPARATION",
      );
      expect(
        ReferenceDataKeys.covenantSubmissionTime,
        "COVENANTS_TIME_FOR_SUBMISSION",
      );
      expect(ReferenceDataKeys.covenantAuditStatus, "COVENANTS_AUDIT_STATUS");
      expect(
        ReferenceDataKeys.conditionDescriptionTemplate,
        "CONDITIONS_SUB_TYPE",
      );
      expect(ReferenceDataKeys.sAndP, "SP_RATING");
      expect(ReferenceDataKeys.moodys, "MOODY_RATING");
      expect(ReferenceDataKeys.fitch, "FITCH_RATING");
      expect(ReferenceDataKeys.bankList, "BANK_LIST");
      expect(ReferenceDataKeys.advanceType, "ADVANCE_TYPE");
      expect(ReferenceDataKeys.securityType, "SECURITY_TYPE");
      expect(ReferenceDataKeys.securityStatus, "SECURITY_STATUS");
      expect(ReferenceDataKeys.securityHeldAs, "SECURITY_HELD_AS");
      expect(ReferenceDataKeys.projectType, "PROJECT_TYPE");
      expect(ReferenceDataKeys.contractType, "CONTRACT_TYPE");
      expect(
        ReferenceDataKeys.regulatorySpecialisedLendingFinanceType,
        "REGULATORY_SPECIALISED_LENDING_FINANCE_TYPE",
      );
      expect(ReferenceDataKeys.limitType, "LIMIT_TYPE");
      expect(ReferenceDataKeys.ifrsStaging, "IFRS_STAGING");
      expect(ReferenceDataKeys.policyDeviation, "POLICY_DEVIATIONS");
      expect(
        ReferenceDataKeys.restructuredRescheduled,
        "RESTRUCTURED_RESCHEDULED",
      );
      expect(ReferenceDataKeys.exposureStrategy, "EXPOSURE_STRATEGY");
      expect(ReferenceDataKeys.productType, "PRODUCT_TYPE");
      expect(ReferenceDataKeys.cancellationReason, "CANCELLATION_REASON");
      expect(ReferenceDataKeys.conditionGeneral, "CONDITIONS_GENERAL_SPECIFIC");
      expect(ReferenceDataKeys.conditionStandard, "CONDITIONS_DESCRIPTION");
      expect(
        ReferenceDataKeys.financialCovenantSubtype,
        "FINANCIAL_COVENANT_SUBTYPE",
      );
      expect(ReferenceDataKeys.thresholdType, "COVENANTS_THRESHOLD_TYPE");
      expect(ReferenceDataKeys.borrowerRole, "CONTRACT_BORROWER_ROLE");
    });
  });
}
