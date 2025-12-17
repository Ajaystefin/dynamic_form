import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/model.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_summary/state.dart';
import 'package:wcas_frontend/models/request/profitability/profitability_summary/realtionship_profitability.dart';

class RelationshipProfitabilityTable extends StatelessWidget {
  final RelationshipProfitabilitySummaryViewModel viewModel;
  final int index;

  const RelationshipProfitabilityTable({
    super.key,
    required this.viewModel,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RelationshipProfitabilitySummaryViewModel,
        RelationshipProfitabilitySummaryState>(builder: (context, state) {
      return CustomRawTable(
        key: UniqueKey(),
        autoFitWidth: true,
        showPagination: true,
        rowsPerPage: viewModel.rowsPerPage,
        columns: getRelationshipProfitColumns(),
        rows: getRelationshipProfitRows(
          viewModel.relationshipProfitabilitySummaryData
              ?.relationshipProfitability?[index],
          index,
        ),
      );
    });
  }

  List<TableColumn> getRelationshipProfitColumns() {
    List<TableColumn> columns = [
      TableColumn(
        width: 120.w,
        label: Text(
            "profitabilityAccountConduct.relationshipProfitabilitySummary.aedMn"
                .tr()),
      ),
      TableColumn(
        width: 100.w,
        label: Text(
            "profitabilityAccountConduct.relationshipProfitabilitySummary.nii"
                .tr()),
      ),
      TableColumn(
        width: 100.w,
        label: Text(
            "profitabilityAccountConduct.relationshipProfitabilitySummary.nfi"
                .tr()),
      ),
      TableColumn(
        width: 100.w,
        label: Text(
            "profitabilityAccountConduct.relationshipProfitabilitySummary.expectedNetIncome"
                .tr()),
      ),
      TableColumn(
        width: 100.w,
        label: Text(
            "profitabilityAccountConduct.relationshipProfitabilitySummary.avgCASA"
                .tr()),
      ),
      TableColumn(
        width: 100.w,
        label: Text(
            "profitabilityAccountConduct.relationshipProfitabilitySummary.rwa"
                .tr()),
      ),
    ];

    return columns;
  }

  List<List<Widget>> getRelationshipProfitRows(
      RelationshipProfitability? relationshipProfitability, int rimIndex) {
    List<List<Widget>> widgets = [];

    List<Widget> row1 = [
      Text(
          "profitabilityAccountConduct.relationshipProfitabilitySummary.projectedForNext12Month"
              .tr()),
      CustomTextField(
        initialValue:
            relationshipProfitability?.projectedNext12Months?.nii?.toString() ??
                '',
        validator:
            (relationshipProfitability?.projectedNext12Months?.nii == null ||
                    !viewModel.isFIApplication)
                ? CustomValidator.requiredField
                : null,
        inputFormatters: [DecimalInputFormatter()],
        onChanged: (value) {
          relationshipProfitability?.projectedNext12Months?.nii =
              int.tryParse(value);
          viewModel.calculateExpNetIncome(rimIndex, 0);
          viewModel.computeTotalProfitability();
        },
      ),
      CustomTextField(
        initialValue:
            relationshipProfitability?.projectedNext12Months?.nfi?.toString() ??
                '',
        validator:
            (relationshipProfitability?.projectedNext12Months?.nfi == null ||
                    !viewModel.isFIApplication)
                ? CustomValidator.requiredField
                : null,
        inputFormatters: [DecimalInputFormatter()],
        onChanged: (value) {
          relationshipProfitability?.projectedNext12Months?.nfi =
              int.tryParse(value);
          viewModel.calculateExpNetIncome(rimIndex, 0);
          viewModel.computeTotalProfitability();
        },
      ),
      CustomTextField(
        hintText: relationshipProfitability
                ?.projectedNext12Months?.expectedNetIncome
                .toString() ??
            '',
        validator: (relationshipProfitability
                        ?.projectedNext12Months?.expectedNetIncome ==
                    null ||
                !viewModel.isFIApplication)
            ? CustomValidator.requiredField
            : null,
        inputFormatters: [DecimalInputFormatter()],
        readOnly: true,
        filled: true,
      ),
      CustomTextField(
        initialValue: relationshipProfitability?.projectedNext12Months?.avgCasa
                .toString() ??
            '',
        validator: (relationshipProfitability?.projectedNext12Months?.avgCasa ==
                    null ||
                !viewModel.isFIApplication)
            ? CustomValidator.requiredField
            : null,
        inputFormatters: [DecimalInputFormatter()],
        onChanged: (value) {
          relationshipProfitability?.projectedNext12Months?.avgCasa =
              int.tryParse(value);
        },
      ),
      CustomTextField(
        initialValue:
            relationshipProfitability?.projectedNext12Months?.rwa?.toString() ??
                '',
        validator:
            (relationshipProfitability?.projectedNext12Months?.rwa == null ||
                    !viewModel.isFIApplication)
                ? CustomValidator.requiredField
                : null,
        inputFormatters: [DecimalInputFormatter()],
        onChanged: (value) {
          relationshipProfitability?.projectedNext12Months?.rwa =
              int.tryParse(value);
        },
      ),
    ];
    List<Widget> row2 = [
      Text(
          "profitabilityAccountConduct.relationshipProfitabilitySummary.realizedLastYer"
              .tr()),
      CustomTextField(
        initialValue:
            relationshipProfitability?.realizedLastYear?.nii?.toString() ?? '',
        validator: (relationshipProfitability?.realizedLastYear?.nii == null ||
                !viewModel.isFIApplication)
            ? CustomValidator.requiredField
            : null,
        inputFormatters: [DecimalInputFormatter()],
        onChanged: (value) {
          relationshipProfitability?.realizedLastYear?.nii =
              int.tryParse(value);
          viewModel.calculateExpNetIncome(rimIndex, 1);
          viewModel.computeTotalProfitability();
        },
      ),
      CustomTextField(
        initialValue:
            relationshipProfitability?.realizedLastYear?.nfi?.toString() ?? '',
        validator: (relationshipProfitability?.realizedLastYear?.nfi == null ||
                !viewModel.isFIApplication)
            ? CustomValidator.requiredField
            : null,
        inputFormatters: [DecimalInputFormatter()],
        onChanged: (value) {
          relationshipProfitability?.realizedLastYear?.nfi =
              int.tryParse(value);
          viewModel.calculateExpNetIncome(rimIndex, 1);
          viewModel.computeTotalProfitability();
        },
      ),
      CustomTextField(
        hintText: relationshipProfitability?.realizedLastYear?.expectedNetIncome
                .toString() ??
            '',
        validator:
            (relationshipProfitability?.realizedLastYear?.expectedNetIncome ==
                        null ||
                    !viewModel.isFIApplication)
                ? CustomValidator.requiredField
                : null,
        inputFormatters: [DecimalInputFormatter()],
        readOnly: true,
        filled: true,
      ),
      CustomTextField(
        initialValue:
            relationshipProfitability?.realizedLastYear?.avgCasa?.toString() ??
                '',
        validator:
            (relationshipProfitability?.realizedLastYear?.avgCasa == null ||
                    !viewModel.isFIApplication)
                ? CustomValidator.requiredField
                : null,
        inputFormatters: [DecimalInputFormatter()],
        onChanged: (value) {
          relationshipProfitability?.realizedLastYear?.avgCasa =
              int.tryParse(value);
        },
      ),
      CustomTextField(
        initialValue:
            relationshipProfitability?.realizedLastYear?.rwa?.toString() ?? '',
        validator: (relationshipProfitability?.realizedLastYear?.rwa == null ||
                !viewModel.isFIApplication)
            ? CustomValidator.requiredField
            : null,
        inputFormatters: [DecimalInputFormatter()],
        onChanged: (value) {
          relationshipProfitability?.realizedLastYear?.rwa =
              int.tryParse(value);
        },
      ),
    ];

    widgets.addAll([row1, row2]);
    return widgets;
  }
}
