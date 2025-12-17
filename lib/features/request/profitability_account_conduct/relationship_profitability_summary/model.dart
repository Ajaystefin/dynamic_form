import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/models/request/comment.dart';
import 'package:wcas_frontend/models/request/profitability/profitability_summary/profitability_data.dart';
import 'package:wcas_frontend/models/request/profitability/relationship_profitability_summary.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/repositories/common_repository.dart';
import 'package:wcas_frontend/repositories/profitability_repository.dart';
import 'state.dart';

/// Enum for identifying which RORAC field is being updated.
enum RoracFieldType { realizedRaroc, proposedRaroc, finalRaroc, comments }

/// ViewModel for managing and summarizing relationship profitability data.
///
/// Extends Cubit to handle loading, error, and loaded states while fetching,
/// computing, updating, and saving summary data and RORAC information.
class RelationshipProfitabilitySummaryViewModel
    extends Cubit<RelationshipProfitabilitySummaryState> {
  /// Initializes the state with a loading indicator.
  RelationshipProfitabilitySummaryViewModel()
      : super(RelationshipProfitabilitySummaryState(
            loaderStatus: LoadingStatus.loading));

  /// Repository for fetching and posting profitability and comment data.
  late ProfitabilityRepository repository;

  /// Form key for validating and saving form data.
  late GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Holds the main summary data fetched from the repository.
  RelationshipProfitabilitySummary? relationshipProfitabilitySummaryData =
      RelationshipProfitabilitySummary();

  /// Flutter BuildContext, assigned during initialization if needed.
  BuildContext? context;

  /// Request object from global state, set during initialization.
  Request? request;

  /// User-entered comments for the summary, bound to the form.
  String summaryComments = '';

  // Comments
  List<Comment> comments = [];
  Comment? comment;
  bool isFIApplication = false;

  /// Number of rows per page.
  final int rowsPerPage = 5;

  /// When computed, holds the summed profitability data.
  /// When no data is available, an instance is assigned with all fields as null.
  ProfitabilityData? sumProfitabilityData;

  // Controller lists for RORAC fields.
  List<TextEditingController>? realizedRarocControllers;
  List<TextEditingController>? proposedRarocControllers;
  List<TextEditingController>? finalRarocControllers;
  List<TextEditingController>? commentsControllers;

  /// Initializes the ViewModel by fetching data from the repository.
  Future<void> init(context) async {
    logger.i('Initializing RelationshipProfitabilitySummaryViewModel');
    repository = ProfitabilityRepository.instance;
    try {
      relationshipProfitabilitySummaryData =
          await repository.getRelationshipProfitabilitySummaryData();
      emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
    } catch (e) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
    await initializeControllers();
    await computeTotalProfitability();
    isFIApplication =
        Utils.checkBusinessSegment(BusinessSegment.financialInstitution);
    request = Globals.request;
  }

  String currentGroupName() {
    // this is the same `request` you passed into TopSectionDetails
    final grp = Globals.request?.groupName;
    return (grp != null && grp.isNotEmpty) ? grp : '';
  }

  /// Calculates the expected net income based on the given [rimIndex] and [rowIndex].
  /// For rowIndex 0 it processes projectedNext12Months; otherwise, realizedLastYear.
  /// Expected net income is calculated as (nii + nfi).
  void calculateExpNetIncome(int rimIndex, int rowIndex) {
    ProfitabilityData? data;
    if (rowIndex == 0) {
      data = relationshipProfitabilitySummaryData
          ?.relationshipProfitability?[rimIndex].projectedNext12Months;
    } else {
      data = relationshipProfitabilitySummaryData
          ?.relationshipProfitability?[rimIndex].realizedLastYear;
    }
    final double nii = double.tryParse(data?.nii.toString() ?? '0') ?? 0.0;
    final double nfi = double.tryParse(data?.nfi.toString() ?? '0') ?? 0.0;
    final double computedExpected = nii + nfi;
    if (rowIndex == 0) {
      relationshipProfitabilitySummaryData?.relationshipProfitability?[rimIndex]
          .projectedNext12Months?.expectedNetIncome = computedExpected.toInt();
    } else {
      relationshipProfitabilitySummaryData?.relationshipProfitability?[rimIndex]
          .realizedLastYear?.expectedNetIncome = computedExpected.toInt();
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Saves relationship profitability summary data.
  /// Validates the form, posts the data via the repository, then shows a success toast.
  /// On failure, shows a failure toast and updates loaderStatus to error.
  Future<void> saveRelationProfitDetailSumData() async {
    try {
      if (formKey.currentState!.validate()) {
        formKey.currentState?.save();
        await repository.postRelationshipProfitabilitySummaryData(
            relationshipProfitabilitySummaryData);
      }
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
    }
  }

  /// Saves user comments and updates the ViewModel state.
  /// Calls the repository method to persist the comment text.
  /// On success, shows a success toast; on failure, updates loaderStatus to error.
  Future<void> onSaveAndContinue(
    String comments,
    bool isContinue, {
    required BuildContext context,
  }) async {
    try {
      if (formKey.currentState!.validate()) {
        formKey.currentState?.save();
        await saveRelationProfitDetailSumData();
        emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
        AlertManager().showSuccessToast(
            "profitabilityAccountConduct.relationshipProfitabilitySummary.savedSuccessfully"
                .tr());
        if (isContinue) {
          LayoutViewModel().goToNextRoute();
        }
      }
    } catch (error) {
      emit(state.copyWith(loaderStatus: LoadingStatus.error));
      AlertManager().showFailureToast(error.toString());
    }
  }

  /// Validates and saves comments, then navigates to the next screen.
  ///
  /// Shows a success toast on successful save or an error toast on failure.
  /// Navigates to the relationship profitability screen if the context is still mounted
  Future<void> saveComment(String summaryComments) async {
    emit(state.copyWith(loaderStatus: LoadingStatus.loading));
    try {
      comment?.commentId = "2";
      comment?.applicationRefNo = Globals.request?.applicationRefNo;
      comment?.draft = false;
      comment?.userId = Globals.user?.id;
      comment?.userRole = Globals.user?.currentRole?.roleId;
      comment?.reviewCommentId = "345";
      comment?.type = CommentsType.incomeSummary;
      comment?.entityType = EntityIdentifier.incomeSummary;
      comment?.comment = summaryComments;

      String responseMessage =
          await CommonRepository.instance.saveComment(comment!);
      AlertManager().showSuccessToast(responseMessage);
    } catch (e) {
      AlertManager().showFailureToast(e.toString());
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Computes the total profitability by summing values across relationship entries.
  /// If there are no entries, sumProfitabilityData is set to an instance with all fields null.
  Future<void> computeTotalProfitability() async {
    final entries =
        relationshipProfitabilitySummaryData?.relationshipProfitability;
    if (entries == null || entries.isEmpty) {
      sumProfitabilityData = ProfitabilityData(
        nii: null,
        nfi: null,
        expectedNetIncome: null,
        avgCasa: null,
        rwa: null,
        realizedNii: null,
        realizedNfi: null,
        realizedExpectedNetIncome: null,
        realizedAvgCasa: null,
        realizedRwa: null,
      );
      return;
    }

    int totalProjectedNii = 0,
        totalProjectedNfi = 0,
        totalProjectedExpNetIncome = 0,
        totalProjectedAvgCasa = 0,
        totalProjectedRwa = 0;
    int totalRealizedNii = 0,
        totalRealizedNfi = 0,
        totalRealizedExpNetIncome = 0,
        totalRealizedAvgCasa = 0,
        totalRealizedRwa = 0;

    await Future.delayed(const Duration(milliseconds: 100));

    for (var rimData in entries) {
      totalProjectedNii += rimData.projectedNext12Months?.nii ?? 0;
      totalProjectedNfi += rimData.projectedNext12Months?.nfi ?? 0;
      totalProjectedExpNetIncome +=
          rimData.projectedNext12Months?.expectedNetIncome ?? 0;
      totalProjectedAvgCasa += rimData.projectedNext12Months?.avgCasa ?? 0;
      totalProjectedRwa += rimData.projectedNext12Months?.rwa ?? 0;

      totalRealizedNii += rimData.realizedLastYear?.nii ?? 0;
      totalRealizedNfi += rimData.realizedLastYear?.nfi ?? 0;
      totalRealizedExpNetIncome +=
          rimData.realizedLastYear?.expectedNetIncome ?? 0;
      totalRealizedAvgCasa += rimData.realizedLastYear?.avgCasa ?? 0;
      totalRealizedRwa += rimData.realizedLastYear?.rwa ?? 0;
    }

    sumProfitabilityData = ProfitabilityData(
      nii: totalProjectedNii,
      nfi: totalProjectedNfi,
      expectedNetIncome: totalProjectedExpNetIncome,
      avgCasa: totalProjectedAvgCasa,
      rwa: totalProjectedRwa,
      realizedNii: totalRealizedNii,
      realizedNfi: totalRealizedNfi,
      realizedExpectedNetIncome: totalRealizedExpNetIncome,
      realizedAvgCasa: totalRealizedAvgCasa,
      realizedRwa: totalRealizedRwa,
    );

    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Initializes the text controllers for the RORAC fields.
  /// If no rarocInformation is present, the controller lists are empty.
  Future<void> initializeControllers() async {
    final dataList =
        relationshipProfitabilitySummaryData?.rarocInformation ?? [];
    if (dataList.isEmpty) {
      logger.w("No RORAC data available, skipping controller initialization.");
      realizedRarocControllers = [];
      proposedRarocControllers = [];
      finalRarocControllers = [];
      commentsControllers = [];
      return;
    }
    realizedRarocControllers = List.generate(
        dataList.length,
        (index) => TextEditingController(
            text: dataList[index].existingRealizedRarocPercent?.toString() ??
                ""));
    proposedRarocControllers = List.generate(
        dataList.length,
        (index) => TextEditingController(
            text: dataList[index]
                    .proposedRarocPercentProposedByCoverage
                    ?.toString() ??
                ""));
    finalRarocControllers = List.generate(
        dataList.length,
        (index) => TextEditingController(
            text: dataList[index]
                    .proposedFinalRarocPercentExAnteRaroc
                    ?.toString() ??
                ""));
    commentsControllers = List.generate(dataList.length,
        (index) => TextEditingController(text: dataList[index].comments ?? ""));
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }

  /// Updates a RORAC field at [index] with [newValue] based on [fieldType].
  /// If the index is invalid, logs an error and ignores the update.
  Future<void> updateRoracField(
      int index, String newValue, RoracFieldType fieldType) async {
    if (relationshipProfitabilitySummaryData?.rarocInformation == null ||
        index >=
            relationshipProfitabilitySummaryData!.rarocInformation!.length) {
      logger.e("Invalid index access in updateRoracField: $index");
      return;
    }
    var data = relationshipProfitabilitySummaryData!.rarocInformation![index];
    await Future.delayed(const Duration(milliseconds: 50));
    switch (fieldType) {
      case RoracFieldType.realizedRaroc:
        data.existingRealizedRarocPercent = double.tryParse(newValue) ?? 0.0;
        break;
      case RoracFieldType.proposedRaroc:
        data.proposedRarocPercentProposedByCoverage =
            double.tryParse(newValue) ?? 0.0;
        break;
      case RoracFieldType.finalRaroc:
        data.proposedFinalRarocPercentExAnteRaroc =
            double.tryParse(newValue) ?? 0.0;
        break;
      case RoracFieldType.comments:
        data.comments = newValue;
        break;
    }
    emit(state.copyWith(loaderStatus: LoadingStatus.loaded));
  }
}
