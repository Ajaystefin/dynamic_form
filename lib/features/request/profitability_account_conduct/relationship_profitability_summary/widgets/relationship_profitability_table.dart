import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/state.dart";
import "package:wcas_frontend/models/request/profitability/profitability_summary/profitability_data.dart";
import "package:wcas_frontend/models/request/profitability/profitability_summary/realtionship_profitability.dart";

class RelationshipProfitabilityTable extends StatelessWidget {
  const RelationshipProfitabilityTable({
    required this.viewModel,
    required this.index,
    super.key,
  });
  final RelationshipProfitabilitySummaryViewModel viewModel;
  final int index;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RelationshipProfitabilitySummaryViewModel,
        RelationshipProfitabilitySummaryState>(
      buildWhen: (prev, next) =>
          prev.tableLoaderStatus != next.tableLoaderStatus ||
          prev.loaderStatus != next.loaderStatus,
      builder: (context, state) {
        return CustomRawTable(
          key: UniqueKey(),
          autoFitWidth: true,
          showPagination: true,
          rowsPerPage: viewModel.rowsPerPage,
          columns: _columns(),
          rows: _rows(
            viewModel.relationshipProfitabilitySummaryData
                ?.relationshipProfitability?[index],
            index,
          ),
        );
      },
    );
  }

  List<TableColumn> _columns() {
    return [
      TableColumn(
        width: 120.w,
        label: Text(
          "profitabilityAccountConduct.relationshipProfitabilitySummary.aedMn"
              .tr(),
        ),
      ),
      TableColumn(
        width: 100.w,
        label: Text(
          "profitabilityAccountConduct.relationshipProfitabilitySummary.nii"
              .tr(),
        ),
      ),
      TableColumn(
        width: 100.w,
        label: Text(
          "profitabilityAccountConduct.relationshipProfitabilitySummary.nfi"
              .tr(),
        ),
      ),
      TableColumn(
        width: 100.w,
        label: Text(
          "profitabilityAccountConduct."
                  "relationshipProfitabilitySummary.expectedNetIncome"
              .tr(),
        ),
      ),
      TableColumn(
        width: 100.w,
        label: Text(
          "profitabilityAccountConduct.relationshipProfitabilitySummary.avgCASA"
              .tr(),
        ),
      ),
      TableColumn(
        width: 100.w,
        label: Text(
          "profitabilityAccountConduct.relationshipProfitabilitySummary.rwa"
              .tr(),
        ),
      ),
    ];
  }

  List<List<Widget>> _rows(RelationshipProfitability? entry, int rimIndex) {
    final List<List<Widget>> widgets = [];
    entry?.projectedNext12Months ??= ProfitabilityData();
    entry?.realizedLastYear ??= ProfitabilityData();

    final numberFormatter = DecimalInputFormatter(
      // up to 21 digits before decimal and up to 6 after; allow negative, no
      // commas
      regEx: RegExp(r"^-?\d{0,15}(\.\d{0,6})?$"),
    );

    // -------- Projected for next 12 months --------
    final projectedRow = <Widget>[
      Text(
        "profitabilityAccountConduct."
                "relationshipProfitabilitySummary.projectedForNext12Month"
            .tr(),
      ),

      // Projected NII
      CustomTextField(
        controller: viewModel.getTextController(
          "proj_nii_$rimIndex",
          entry?.projectedNext12Months?.nii?.toString() ?? "",
        ),
        focusNode: viewModel.getFocusedNode("proj_nii_$rimIndex"),
        inputFormatters: [numberFormatter],
        onSubmitted: (value) {
          entry?.projectedNext12Months?.nii = value;
          viewModel.calculateExpNetIncome(rimIndex, 0);
          viewModel.debouncedTotals();
        },
        onSaved: (value) {
          entry?.projectedNext12Months?.nii = value;
          viewModel.calculateExpNetIncome(rimIndex, 0);
          viewModel.debouncedTotals();
        },
      ),

      // Projected NFI
      CustomTextField(
        controller: viewModel.getTextController(
          "proj_nfi_$rimIndex",
          entry?.projectedNext12Months?.nfi?.toString() ?? "",
        ),
        focusNode: viewModel.getFocusedNode("proj_nfi_$rimIndex"),
        inputFormatters: [numberFormatter],
        onSubmitted: (value) {
          entry?.projectedNext12Months?.nfi = value;
          viewModel.calculateExpNetIncome(rimIndex, 0);
          viewModel.debouncedTotals();
        },
        onSaved: (value) {
          entry?.projectedNext12Months?.nfi = value;
          viewModel.calculateExpNetIncome(rimIndex, 0);
          viewModel.debouncedTotals();
        },
      ),

      // Projected Expected Net Income (read-only)
      CustomTextField(
        controller: viewModel.getTextController(
          "proj_exp_$rimIndex",
          entry?.projectedNext12Months?.expectedNetIncome?.toString() ?? "",
        ),
        readOnly: true,
        filled: true,
      ),

      // Projected Avg. CASA
      CustomTextField(
        controller: viewModel.getTextController(
          "proj_casa_$rimIndex",
          entry?.projectedNext12Months?.avgCasa?.toString() ?? "",
        ),
        focusNode: viewModel.getFocusedNode("proj_casa_$rimIndex"),
        validator:
            viewModel.isFIApplication ? CustomValidator.requiredField : null,
        inputFormatters: [numberFormatter],
        onSubmitted: (value) {
          entry?.projectedNext12Months?.avgCasa = value;
          viewModel.debouncedTotals();
        },
        onSaved: (value) {
          entry?.projectedNext12Months?.avgCasa = value;
          viewModel.debouncedTotals();
        },
      ),

      // Projected RWA
      CustomTextField(
        controller: viewModel.getTextController(
          "proj_rwa_$rimIndex",
          entry?.projectedNext12Months?.rwa?.toString() ?? "",
        ),
        focusNode: viewModel.getFocusedNode("proj_rwa_$rimIndex"),
        validator:
            viewModel.isFIApplication ? CustomValidator.requiredField : null,
        inputFormatters: [numberFormatter],
        onSubmitted: (value) {
          entry?.projectedNext12Months?.rwa = value;
          viewModel.debouncedTotals();
        },
        onSaved: (value) {
          entry?.projectedNext12Months?.rwa = value;
          viewModel.debouncedTotals();
        },
      ),
    ];

    // -------- Realized [Last Year] --------
    final realizedRow = <Widget>[
      Text(
        "profitabilityAccountConduct."
                "relationshipProfitabilitySummary.realizedLastYer"
            .tr(),
      ),

      // Realized NII
      CustomTextField(
        controller: viewModel.getTextController(
          "real_nii_$rimIndex",
          entry?.realizedLastYear?.nii?.toString() ?? "",
        ),
        focusNode: viewModel.getFocusedNode("real_nii_$rimIndex"),
        validator:
            viewModel.isFIApplication ? CustomValidator.requiredField : null,
        inputFormatters: [numberFormatter],
        onSubmitted: (value) {
          entry?.realizedLastYear?.nii = value;
          viewModel.calculateExpNetIncome(rimIndex, 1);
          viewModel.debouncedTotals();
        },
        onSaved: (value) {
          entry?.realizedLastYear?.nii = value;
          viewModel.calculateExpNetIncome(rimIndex, 1);
          viewModel.debouncedTotals();
        },
      ),

      // Realized NFI
      CustomTextField(
        controller: viewModel.getTextController(
          "real_nfi_$rimIndex",
          entry?.realizedLastYear?.nfi?.toString() ?? "",
        ),
        focusNode: viewModel.getFocusedNode("real_nfi_$rimIndex"),
        validator:
            viewModel.isFIApplication ? CustomValidator.requiredField : null,
        inputFormatters: [numberFormatter],
        onSubmitted: (value) {
          entry?.realizedLastYear?.nfi = value;
          viewModel.calculateExpNetIncome(rimIndex, 1);
          viewModel.debouncedTotals();
        },
        onSaved: (value) {
          entry?.realizedLastYear?.nfi = value;
          viewModel.calculateExpNetIncome(rimIndex, 1);
          viewModel.debouncedTotals();
        },
      ),

      // Realized Expected Net Income (read-only)
      CustomTextField(
        controller: viewModel.getTextController(
          "real_exp_$rimIndex",
          entry?.realizedLastYear?.expectedNetIncome?.toString() ?? "",
        ),
        validator:
            viewModel.isFIApplication ? CustomValidator.requiredField : null,
        readOnly: true,
        filled: true,
      ),

      // Realized Avg. CASA
      CustomTextField(
        controller: viewModel.getTextController(
          "real_casa_$rimIndex",
          entry?.realizedLastYear?.avgCasa?.toString() ?? "",
        ),
        focusNode: viewModel.getFocusedNode("real_casa_$rimIndex"),
        validator:
            viewModel.isFIApplication ? CustomValidator.requiredField : null,
        inputFormatters: [numberFormatter],
        onSubmitted: (value) {
          entry?.realizedLastYear?.avgCasa = value;
          viewModel.debouncedTotals();
        },
        onSaved: (value) {
          entry?.realizedLastYear?.avgCasa = value;
          viewModel.debouncedTotals();
        },
      ),

      // Realized RWA
      CustomTextField(
        controller: viewModel.getTextController(
          "real_rwa_$rimIndex",
          entry?.realizedLastYear?.rwa?.toString() ?? "",
        ),
        focusNode: viewModel.getFocusedNode("real_rwa_$rimIndex"),
        validator:
            viewModel.isFIApplication ? CustomValidator.requiredField : null,
        inputFormatters: [numberFormatter],
        onSubmitted: (value) {
          entry?.realizedLastYear?.rwa = value;
          viewModel.debouncedTotals();
        },
        onSaved: (value) {
          entry?.realizedLastYear?.rwa = value;
          viewModel.debouncedTotals();
        },
      ),
    ];

    widgets.addAll([projectedRow, realizedRow]);
    return widgets;
  }
}
