import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/request/customer.dart";

void main() {
  group("Enums coverage", () {
    test("BusinessVolumeAccountStatsTabs enum coverage", () {
      expect(BusinessVolumeAccountStatsTabs.values, hasLength(2));
      expect(
        BusinessVolumeAccountStatsTabs.values.map((e) => e.name),
        containsAll(<String>[
          "businessVolume",
          "accountStats",
        ]),
      );
    });

    test("ApplicationFilterType enum coverage", () {
      expect(ApplicationFilterType.values, hasLength(6));
      expect(
        ApplicationFilterType.values.map((e) => e.name),
        containsAll(<String>[
          "applicationOverdue",
          "dueForReview",
          "recentApplication",
          "applicationSegment",
          "closedRequest",
          "ccsys",
        ]),
      );
    });

    test("RevenueCrossSellTabs enum coverage", () {
      expect(RevenueCrossSellTabs.values, hasLength(5));
      expect(
        RevenueCrossSellTabs.values.map((e) => e.name),
        containsAll(<String>[
          "relationshipUtilization",
          "relationshipProfitabilitySummary",
          "relationshipProfitabilityDetailed",
          "incomeSummary",
          "strategiesAndComments",
        ]),
      );
    });

    test("RecommendationTabs enum coverage", () {
      expect(RecommendationTabs.values, hasLength(8));
      expect(
        RecommendationTabs.values.map((e) => e.name),
        containsAll(<String>[
          "proposedFacilities",
          "groupPosition",
          "limitCaps",
          "guarantorsExposure",
          "queriesAndResponses",
          "previousCreditApproval",
          "recommendationCurrentApproval",
          "comments",
        ]),
      );
    });

    test("GroupSummaryTabs enum coverage", () {
      expect(GroupSummaryTabs.values, hasLength(4));
      expect(
        GroupSummaryTabs.values.map((e) => e.name),
        containsAll(<String>[
          "ownershipCorporateStructure",
          "groupManagementTeam",
          "successsionkeyManRisk",
          "relationshipFutureStrategy",
        ]),
      );
    });

    test("CountrySummaryTabs enum coverage", () {
      expect(CountrySummaryTabs.values, hasLength(5));
      expect(
        CountrySummaryTabs.values.map((e) => e.name),
        containsAll(<String>[
          "request",
          "rational",
          "summaryOfLatestDev",
          "bankingSector",
          "fiRecommend",
        ]),
      );
    });

    test("RemarksTabs enum coverage", () {
      expect(RemarksTabs.values, hasLength(30));
      expect(
        RemarksTabs.values.map((e) => e.name),
        containsAll(<String>[
          "requestSummary",
          "relationshipHistory",
          "businessRisk",
          "industryRisk",
          "financialRatiosAndAnalysis",
          "security",
          "ownershipStructure",
          "managementRisk",
          "facilityJustification",
          "covenants",
          "conditions",
          "guarantorFinancials",
          "keyRisksAndMitigants",
          "otherFacilityRelatedAnalysis",
          "existingAndProposedCollateral",
          "settlementLimits",
          "cashflowProjectionAnalysis",
          "feeStructure",
          "businessExperience",
          "background",
          "ownership",
          "analysisCapital",
          "analysisAssets",
          "analysisManagement",
          "analysisEarnings",
          "analysisLiquidity",
          "analysisOtherComments",
          "otherComments",
          "bankOverview",
          "financialHighlights",
        ]),
      );
    });
  });

  group("Static constant maps coverage", () {
    test("businessVolumeAccountStatsRoutes covers all keys and values", () {
      const map = TabConstants.businessVolumeAccountStatsRoutes;
      expect(map.keys.toSet(), BusinessVolumeAccountStatsTabs.values.toSet());

      for (final value in map.values) {
        expect(value, isA<String>());
        expect(value, isNotEmpty);
      }
    });

    test("businessVolumeAccountStatsTitles covers all keys and values", () {
      const map = TabConstants.businessVolumeAccountStatsTitles;
      expect(map.keys.toSet(), BusinessVolumeAccountStatsTabs.values.toSet());

      for (final value in map.values) {
        expect(value, isA<String>());
        expect(value, isNotEmpty);
      }
    });

    test("revenueCrossSellRoutes covers all keys and values", () {
      const map = TabConstants.revenueCrossSellRoutes;
      expect(map.keys.toSet(), RevenueCrossSellTabs.values.toSet());

      for (final value in map.values) {
        expect(value, isA<String>());
        expect(value, isNotEmpty);
      }
    });

    test("revenueCrossSellTitles covers all keys and values", () {
      const map = TabConstants.revenueCrossSellTitles;
      expect(map.keys.toSet(), RevenueCrossSellTabs.values.toSet());

      for (final value in map.values) {
        expect(value, isA<String>());
        expect(value, isNotEmpty);
      }
    });

    test("recommendationRoutes covers all keys and values", () {
      const map = TabConstants.recommendationRoutes;
      expect(map.keys.toSet(), RecommendationTabs.values.toSet());

      for (final value in map.values) {
        expect(value, isA<String>());
        expect(value, isNotEmpty);
      }
    });

    test("recommendationTitles covers all keys and values", () {
      const map = TabConstants.recommendationTitles;
      expect(map.keys.toSet(), RecommendationTabs.values.toSet());

      for (final value in map.values) {
        expect(value, isA<String>());
        expect(value, isNotEmpty);
      }
    });

    test("countrySumaryRoutes covers all keys and values", () {
      const map = TabConstants.countrySumaryRoutes;
      expect(map.keys.toSet(), CountrySummaryTabs.values.toSet());

      for (final value in map.values) {
        expect(value, isA<String>());
        expect(value, isNotEmpty);
      }
    });

    test("countrySummaryTitles covers all keys and values", () {
      const map = TabConstants.countrySummaryTitles;
      expect(map.keys.toSet(), CountrySummaryTabs.values.toSet());

      for (final value in map.values) {
        expect(value, isA<String>());
        expect(value, isNotEmpty);
      }
    });

    test("groupSumaryRoutes covers all keys and values", () {
      const map = TabConstants.groupSumaryRoutes;
      expect(map.keys.toSet(), GroupSummaryTabs.values.toSet());

      for (final value in map.values) {
        expect(value, isA<String>());
        expect(value, isNotEmpty);
      }
    });

    test("groupSummaryTitles covers all keys and values", () {
      const map = TabConstants.groupSummaryTitles;
      expect(map.keys.toSet(), GroupSummaryTabs.values.toSet());

      for (final value in map.values) {
        expect(value, isA<String>());
        expect(value, isNotEmpty);
      }
    });

    test("remarksRoutes covers all keys and values", () {
      const map = TabConstants.remarksRoutes;
      expect(map.keys.toSet(), RemarksTabs.values.toSet());

      for (final value in map.values) {
        expect(value, isA<String>());
        expect(value, isNotEmpty);
      }
    });

    test("remarksTitles covers all keys and naming format", () {
      const map = TabConstants.remarksTitles;
      expect(map.keys.toSet(), RemarksTabs.values.toSet());

      for (final tab in RemarksTabs.values) {
        final value = map[tab]!;
        expect(value, startsWith("remarks."));
        expect(value, endsWith(".tabTitle"));
      }
    });

    test("remarksTooltipContent covers all keys and naming format", () {
      const map = TabConstants.remarksTooltipContent;
      expect(map.keys.toSet(), RemarksTabs.values.toSet());

      for (final tab in RemarksTabs.values) {
        final value = map[tab]!;
        expect(value, startsWith("remarks."));
        expect(value, endsWith(".tooltipContent"));
      }
    });

    test("fiCollapsedTabs contains the expected tabs only", () {
      const collapsed = TabConstants.fiCollapsedTabs;

      expect(
        collapsed,
        equals(<RemarksTabs>{
          RemarksTabs.businessExperience,
          RemarksTabs.background,
          RemarksTabs.ownership,
          RemarksTabs.analysisOtherComments,
          RemarksTabs.analysisCapital,
          RemarksTabs.analysisAssets,
          RemarksTabs.analysisManagement,
          RemarksTabs.analysisEarnings,
          RemarksTabs.analysisLiquidity,
          RemarksTabs.otherComments,
          RemarksTabs.bankOverview,
          RemarksTabs.financialHighlights,
        }),
      );

      expect(collapsed.length, 12);
      expect(collapsed.contains(RemarksTabs.businessExperience), isTrue);
      expect(collapsed.contains(RemarksTabs.requestSummary), isFalse);
    });
  });

  group("getRemarksRoutes()", () {
    test("returns all expected FI-specific remark tabs", () {
      final map = TabConstants.getRemarksRoutes(
        Customer(type: CustomerType.country),
      );

      expect(
        map.keys.toSet(),
        equals(<RemarksTabs>{
          RemarksTabs.businessExperience,
          RemarksTabs.background,
          RemarksTabs.ownership,
          RemarksTabs.analysisOtherComments,
          RemarksTabs.analysisCapital,
          RemarksTabs.analysisAssets,
          RemarksTabs.analysisManagement,
          RemarksTabs.analysisEarnings,
          RemarksTabs.analysisLiquidity,
          RemarksTabs.otherComments,
          RemarksTabs.bankOverview,
          RemarksTabs.financialHighlights,
        }),
      );
    });

    test("returns false for all closures when customer is non-FI", () {
      final map = TabConstants.getRemarksRoutes(
        Customer(type: CustomerType.country),
      );

      final evaluated = map.map((key, value) => MapEntry(key, value()));

      expect(
        evaluated,
        equals(<RemarksTabs, bool>{
          RemarksTabs.businessExperience: false,
          RemarksTabs.background: false,
          RemarksTabs.ownership: false,
          RemarksTabs.analysisOtherComments: false,
          RemarksTabs.analysisCapital: false,
          RemarksTabs.analysisAssets: false,
          RemarksTabs.analysisManagement: false,
          RemarksTabs.analysisEarnings: false,
          RemarksTabs.analysisLiquidity: false,
          RemarksTabs.otherComments: false,
          RemarksTabs.bankOverview: false,
          RemarksTabs.financialHighlights: false,
        }),
      );
    });

    test("returns true for all closures when customer is investment grade FI",
        () {
      final map = TabConstants.getRemarksRoutes(
        Customer(type: CustomerType.investmentGradeBanks),
      );

      for (final fn in map.values) {
        expect(fn(), isTrue);
      }
    });

    test(
        "returns true for all closures when customer"
        " is below investment grade FI", () {
      final map = TabConstants.getRemarksRoutes(
        Customer(type: CustomerType.belowInvestmentGradeBanks),
      );

      for (final fn in map.values) {
        expect(fn(), isTrue);
      }
    });
  });

  group("getRecommendationRoutes()", () {
    test("returns all expected recommendation route keys", () {
      final map = TabConstants.getRecommendationRoutes();

      expect(
        map.keys.toSet(),
        equals(<RecommendationTabs>{
          RecommendationTabs.proposedFacilities,
          RecommendationTabs.groupPosition,
          RecommendationTabs.limitCaps,
          RecommendationTabs.guarantorsExposure,
          RecommendationTabs.queriesAndResponses,
          RecommendationTabs.previousCreditApproval,
          RecommendationTabs.recommendationCurrentApproval,
          RecommendationTabs.comments,
        }),
      );
    });

    test("all recommendation closures are callable", () {
      final map = TabConstants.getRecommendationRoutes();

      for (final entry in map.entries) {
        expect(entry.value, isA<bool Function()>());
      }
    });

    test("evaluating recommendation closures does not throw", () {
      final map = TabConstants.getRecommendationRoutes();

      for (final fn in map.values) {
        expect(fn, returnsNormally);
      }
    });
  });

  group("getBusinessAccountRoutes()", () {
    test("returns all expected business account route keys", () {
      final map = TabConstants.getBusinessAccountRoutes();

      expect(
        map.keys.toSet(),
        equals(<BusinessVolumeAccountStatsTabs>{
          BusinessVolumeAccountStatsTabs.businessVolume,
          BusinessVolumeAccountStatsTabs.accountStats,
        }),
      );
    });

    test("all business account closures are callable", () {
      final map = TabConstants.getBusinessAccountRoutes();

      for (final entry in map.entries) {
        expect(entry.value, isA<bool Function()>());
      }
    });

    test("evaluating business account closures does not throw", () {
      final map = TabConstants.getBusinessAccountRoutes();

      for (final fn in map.values) {
        expect(fn, returnsNormally);
      }
    });
  });
}
