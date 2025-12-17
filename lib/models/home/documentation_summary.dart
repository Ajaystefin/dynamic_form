import 'package:wcas_frontend/core/utils/utils.dart';

class DocumentationSummary {
  final DocumentationStage folDraftUnderPreparation;
  final DocumentationStage folDraftUnderRmRoReview;
  final DocumentationStage folDraftUnderDcReview;
  final DocumentationStage folDraftUnderFinalization;
  final DocumentationStage folUnderClientSignOff;
  final DocumentationStage executedDocumentsUnderReview;
  final DocumentationStage discrepanciesAdvisedToRm;
  final DocumentationStage finalFitToLendChecks;
  final DocumentationStage finalFitToLendChecksReviewWithDc;
  final DocumentationStage fitToLendChecksCompleted;
  final DocumentationStage folNotRequired;
  final DocumentationStage limitReleaseInstructionsWithMaker;
  final DocumentationStage limitReleaseInstructionsWithChecker;
  final DocumentationStage limitReleaseQueriesWithRORM;
  final DocumentationStage limitReleaseQueriesWithCredit;
  final DocumentationStage limitReleaseQueriesWithCDU;

  DocumentationSummary({
    required this.folDraftUnderPreparation,
    required this.folDraftUnderRmRoReview,
    required this.folDraftUnderDcReview,
    required this.folDraftUnderFinalization,
    required this.folUnderClientSignOff,
    required this.executedDocumentsUnderReview,
    required this.discrepanciesAdvisedToRm,
    required this.finalFitToLendChecks,
    required this.finalFitToLendChecksReviewWithDc,
    required this.fitToLendChecksCompleted,
    required this.folNotRequired,
    required this.limitReleaseInstructionsWithMaker,
    required this.limitReleaseInstructionsWithChecker,
    required this.limitReleaseQueriesWithRORM,
    required this.limitReleaseQueriesWithCredit,
    required this.limitReleaseQueriesWithCDU,
  });

  factory DocumentationSummary.fromJson(Map<String, dynamic> json) {
    return DocumentationSummary(
      folDraftUnderPreparation:
          DocumentationStage.fromJson(json['folDraftUnderPreparation']),
      folDraftUnderRmRoReview:
          DocumentationStage.fromJson(json['folDraftUnderRmRoReview']),
      folDraftUnderDcReview:
          DocumentationStage.fromJson(json['folDraftUnderDcReview']),
      folDraftUnderFinalization:
          DocumentationStage.fromJson(json['folDraftUnderFinalization']),
      folUnderClientSignOff:
          DocumentationStage.fromJson(json['folUnderClientSignOff']),
      executedDocumentsUnderReview:
          DocumentationStage.fromJson(json['executedDocumentsUnderReview']),
      discrepanciesAdvisedToRm:
          DocumentationStage.fromJson(json['discrepanciesAdvisedToRm']),
      finalFitToLendChecks:
          DocumentationStage.fromJson(json['finalFitToLendChecks']),
      finalFitToLendChecksReviewWithDc:
          DocumentationStage.fromJson(json['finalFitToLendChecksReviewWithDc']),
      fitToLendChecksCompleted:
          DocumentationStage.fromJson(json['fitToLendChecksCompleted']),
      folNotRequired: DocumentationStage.fromJson(json['folNotRequired']),
      limitReleaseInstructionsWithMaker: DocumentationStage.fromJson(
          json['limitReleaseInstructionsWithMaker']),
      limitReleaseInstructionsWithChecker: DocumentationStage.fromJson(
          json['limitReleaseInstructionsWithChecker']),
      limitReleaseQueriesWithRORM:
          DocumentationStage.fromJson(json['limitReleaseQueriesWithRORM']),
      limitReleaseQueriesWithCredit:
          DocumentationStage.fromJson(json['limitReleaseQueriesWithCredit']),
      limitReleaseQueriesWithCDU:
          DocumentationStage.fromJson(json['limitReleaseQueriesWithCDU']),
    );
  }
}

class DocumentationStage {
  final int totalCount;
  final Map<BarGraphHelper, int> newToBank;
  final Map<BarGraphHelper, int> annualReviewSameLevel;
  final Map<BarGraphHelper, int> annualReviewIncrease;
  final Map<BarGraphHelper, int> annualReviewDecrease;
  final Map<BarGraphHelper, int> interimReviewSameLevel;
  final Map<BarGraphHelper, int> interimReviewIncrease;
  final Map<BarGraphHelper, int> interimReviewDecrease;
  final Map<BarGraphHelper, int> reconsiderationSameLevel;
  final Map<BarGraphHelper, int> reconsiderationIncrease;
  final Map<BarGraphHelper, int> reconsiderationDecrease;
  final Map<BarGraphHelper, int> facilityCancelation;
  final Map<BarGraphHelper, int> isolatedMemo;
  final Map<BarGraphHelper, int> cancellation;

  DocumentationStage({
    required this.totalCount,
    required this.newToBank,
    required this.annualReviewSameLevel,
    required this.annualReviewIncrease,
    required this.annualReviewDecrease,
    required this.interimReviewSameLevel,
    required this.interimReviewIncrease,
    required this.interimReviewDecrease,
    required this.reconsiderationSameLevel,
    required this.reconsiderationIncrease,
    required this.reconsiderationDecrease,
    required this.facilityCancelation,
    required this.isolatedMemo,
    required this.cancellation,
  });

  factory DocumentationStage.fromJson(Map<String, dynamic> json) {
    return DocumentationStage(
      totalCount: json['totalCount'] ?? 0,
      newToBank: {BarGraphHelper.newToBank: json['newtoBank'] ?? 0},
      annualReviewSameLevel: {
        BarGraphHelper.annualReviewSameLevel: json['annualReviewSameLevel'] ?? 0
      },
      annualReviewIncrease: {
        BarGraphHelper.annualReviewIncrease: json['annualReviewIncrease'] ?? 0
      },
      annualReviewDecrease: {
        BarGraphHelper.annualReviewDecrease: json['annualReviewDecrease'] ?? 0
      },
      interimReviewSameLevel: {
        BarGraphHelper.interimReviewSameLevel:
            json['interimReviewSameLevel'] ?? 0
      },
      interimReviewIncrease: {
        BarGraphHelper.interimReviewIncrease: json['interimReviewIncrease'] ?? 0
      },
      interimReviewDecrease: {
        BarGraphHelper.interimReviewDecrease: json['interimReviewDecrease'] ?? 0
      },
      reconsiderationSameLevel: {
        BarGraphHelper.reconsiderationSameLevel:
            json['reconsiderationSameLevel'] ?? 0
      },
      reconsiderationIncrease: {
        BarGraphHelper.reconsiderationIncrease:
            json['reconsiderationIncrease'] ?? 0
      },
      reconsiderationDecrease: {
        BarGraphHelper.reconsiderationDecrease:
            json['reconsiderationDecrease'] ?? 0
      },
      facilityCancelation: {
        BarGraphHelper.facilityCancelation: json['facilityCancelation'] ?? 0
      },
      isolatedMemo: {BarGraphHelper.isolatedMemo: json['isolatedMemo'] ?? 0},
      cancellation: {BarGraphHelper.cancellation: json['cancellation'] ?? 0},
    );
  }

  /// Convert all maps into a list
  List<Map<BarGraphHelper, int>> toMapList() {
    return [
      newToBank,
      annualReviewSameLevel,
      annualReviewIncrease,
      annualReviewDecrease,
      interimReviewSameLevel,
      interimReviewIncrease,
      interimReviewDecrease,
      reconsiderationSameLevel,
      reconsiderationIncrease,
      reconsiderationDecrease,
      facilityCancelation,
      isolatedMemo,
      cancellation,
    ];
  }
}
