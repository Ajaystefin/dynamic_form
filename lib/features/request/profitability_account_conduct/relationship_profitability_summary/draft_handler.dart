import "package:wcas_frontend/core/services/draft/draft_handler_base.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/model.dart";
import "package:wcas_frontend/models/request/profitability/profitability_summary/profitability_data.dart";
import "package:wcas_frontend/models/request/profitability/profitability_summary/raroc_info.dart";
import "package:wcas_frontend/models/request/profitability/profitability_summary/realtionship_profitability.dart";

class RelationshipProfitabilitySummaryDraftHandler
    extends DraftHandler<RelationshipProfitabilitySummaryViewModel> {
  static const String _summaryCommentsKey = "summaryComments";
  static const String _relationshipProfitabilityKey =
      "relationshipProfitability";
  static const String _rarocInformationKey = "rarocInformation";

  @override
  Map<String, dynamic> buildDraftData(
    RelationshipProfitabilitySummaryViewModel vm,
  ) {
    vm.formKey.currentState?.save();

    final List<RelationshipProfitability> profitabilityRows =
        vm.relationshipProfitabilitySummaryData?.relationshipProfitability ??
            [];

    final List<RarocInformation> rarocRows =
        vm.relationshipProfitabilitySummaryData?.rarocInformation ?? [];

    final List<Map<String, dynamic>> relationshipProfitabilityDraft =
        <Map<String, dynamic>>[];

    for (int i = 0; i < profitabilityRows.length; i++) {
      final RelationshipProfitability row = profitabilityRows[i];

      relationshipProfitabilityDraft.add(<String, dynamic>{
        "comments": _stringValue(row.comments),
        "projectedNext12Months": <String, dynamic>{
          "nii": vm.getTextController("proj_nii_$i").text.trim(),
          "nfi": vm.getTextController("proj_nfi_$i").text.trim(),
          "expectedNetIncome": vm.getTextController("proj_exp_$i").text.trim(),
          "avgCasa": vm.getTextController("proj_casa_$i").text.trim(),
          "rwa": vm.getTextController("proj_rwa_$i").text.trim(),
        },
        "realizedLastYear": <String, dynamic>{
          "nii": vm.getTextController("real_nii_$i").text.trim(),
          "nfi": vm.getTextController("real_nfi_$i").text.trim(),
          "expectedNetIncome": vm.getTextController("real_exp_$i").text.trim(),
          "avgCasa": vm.getTextController("real_casa_$i").text.trim(),
          "rwa": vm.getTextController("real_rwa_$i").text.trim(),
        },
      });
    }

    final List<Map<String, dynamic>> rarocDraft = <Map<String, dynamic>>[];

    for (int i = 0; i < rarocRows.length; i++) {
      rarocDraft.add(<String, dynamic>{
        "existingRealizedRarocPercent":
            _ctrlTextAt(vm.realizedRarocControllers, i),
        "proposedRarocPercentProposedByCoverage":
            _ctrlTextAt(vm.proposedRarocControllers, i),
        "proposedFinalRarocPercentExAnteRaroc":
            _ctrlTextAt(vm.finalRarocControllers, i),
        "comments": _ctrlTextAt(vm.commentsControllers, i),
      });
    }

    return <String, dynamic>{
      _summaryCommentsKey: vm.summaryCommentsController.text.trim(),
      _relationshipProfitabilityKey: relationshipProfitabilityDraft,
      _rarocInformationKey: rarocDraft,
    };
  }

  @override
  void applyDraft(
    RelationshipProfitabilitySummaryViewModel vm,
    Map<String, dynamic> data,
  ) {
    // Restore RM comments textarea
    vm.summaryComments = _stringValue(data[_summaryCommentsKey]);
    vm.summaryCommentsController.text = vm.summaryComments ?? "";

    // Restore profitability rows + row comments
    final List<RelationshipProfitability> profitabilityRows =
        vm.relationshipProfitabilitySummaryData?.relationshipProfitability ??
            [];

    final dynamic rawProfitability = data[_relationshipProfitabilityKey];
    if (rawProfitability is List && profitabilityRows.isNotEmpty) {
      final int count = rawProfitability.length < profitabilityRows.length
          ? rawProfitability.length
          : profitabilityRows.length;

      for (int i = 0; i < count; i++) {
        final dynamic rawRow = rawProfitability[i];
        if (rawRow is! Map) continue;

        final Map<String, dynamic> row =
            rawRow.map((k, v) => MapEntry(k.toString(), v));

        final Map<String, dynamic> proj =
            _asStringDynamicMap(row["projectedNext12Months"]);
        final Map<String, dynamic> real =
            _asStringDynamicMap(row["realizedLastYear"]);

        profitabilityRows[i]
          ..projectedNext12Months ??= ProfitabilityData()
          ..realizedLastYear ??= ProfitabilityData()
          ..comments = _stringValue(row["comments"])
          ..projectedNext12Months!.nii = _stringValue(proj["nii"])
          ..projectedNext12Months!.nfi = _stringValue(proj["nfi"])
          ..projectedNext12Months!.expectedNetIncome =
              _stringValue(proj["expectedNetIncome"])
          ..projectedNext12Months!.avgCasa = _stringValue(proj["avgCasa"])
          ..projectedNext12Months!.rwa = _stringValue(proj["rwa"])
          ..realizedLastYear!.nii = _stringValue(real["nii"])
          ..realizedLastYear!.nfi = _stringValue(real["nfi"])
          ..realizedLastYear!.expectedNetIncome =
              _stringValue(real["expectedNetIncome"])
          ..realizedLastYear!.avgCasa = _stringValue(real["avgCasa"])
          ..realizedLastYear!.rwa = _stringValue(real["rwa"]);

        vm.getTextController("proj_nii_$i").text = _stringValue(proj["nii"]);
        vm.getTextController("proj_nfi_$i").text = _stringValue(proj["nfi"]);
        vm.getTextController("proj_exp_$i").text =
            _stringValue(proj["expectedNetIncome"]);
        vm.getTextController("proj_casa_$i").text =
            _stringValue(proj["avgCasa"]);
        vm.getTextController("proj_rwa_$i").text = _stringValue(proj["rwa"]);

        vm.getTextController("real_nii_$i").text = _stringValue(real["nii"]);
        vm.getTextController("real_nfi_$i").text = _stringValue(real["nfi"]);
        vm.getTextController("real_exp_$i").text =
            _stringValue(real["expectedNetIncome"]);
        vm.getTextController("real_casa_$i").text =
            _stringValue(real["avgCasa"]);
        vm.getTextController("real_rwa_$i").text = _stringValue(real["rwa"]);
      }
    }

    // Restore RAROC rows + comments
    final List<RarocInformation> rarocRows =
        vm.relationshipProfitabilitySummaryData?.rarocInformation ?? [];

    final dynamic rawRaroc = data[_rarocInformationKey];
    if (rawRaroc is List && rarocRows.isNotEmpty) {
      final int count = rawRaroc.length < rarocRows.length
          ? rawRaroc.length
          : rarocRows.length;

      for (int i = 0; i < count; i++) {
        final dynamic rawRow = rawRaroc[i];
        if (rawRow is! Map) continue;

        final Map<String, dynamic> row =
            rawRow.map((k, v) => MapEntry(k.toString(), v));

        final String realized =
            _stringValue(row["existingRealizedRarocPercent"]);
        final String proposed =
            _stringValue(row["proposedRarocPercentProposedByCoverage"]);
        final String finalRaroc =
            _stringValue(row["proposedFinalRarocPercentExAnteRaroc"]);
        final String comments = _stringValue(row["comments"]);

        rarocRows[i]
          ..existingRealizedRarocPercent = realized
          ..proposedRarocPercentProposedByCoverage = proposed
          ..proposedFinalRarocPercentExAnteRaroc = finalRaroc
          ..comments = comments;

        if (vm.realizedRarocControllers != null &&
            i < vm.realizedRarocControllers!.length) {
          vm.realizedRarocControllers![i].text = realized;
        }
        if (vm.proposedRarocControllers != null &&
            i < vm.proposedRarocControllers!.length) {
          vm.proposedRarocControllers![i].text = proposed;
        }
        if (vm.finalRarocControllers != null &&
            i < vm.finalRarocControllers!.length) {
          vm.finalRarocControllers![i].text = finalRaroc;
        }
        if (vm.commentsControllers != null &&
            i < vm.commentsControllers!.length) {
          vm.commentsControllers![i].text = comments;
        }
      }
    }

    vm
      ..computeTotalProfitability()
      ..emit(vm.state.copyWith());
  }

  String _ctrlTextAt(List<dynamic>? ctrls, int index) {
    if (ctrls == null || index < 0 || index >= ctrls.length) return "";
    final dynamic c = ctrls[index];
    try {
      return c.text?.toString() ?? "";
    } catch (_) {
      return "";
    }
  }

  Map<String, dynamic> _asStringDynamicMap(dynamic value) {
    if (value is! Map) return <String, dynamic>{};
    return value.map((k, v) => MapEntry(k.toString(), v));
  }

  String _stringValue(dynamic value) {
    if (value == null) return "";
    final String s = value.toString();
    return s.toLowerCase() == "null" ? "" : s;
  }
}
