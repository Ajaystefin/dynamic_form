import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart";

/// FieldListTable stateless widget
class FieldListTable extends StatelessWidget {
  // true => strengths, false => threats
  /// Creates [FieldListTable] instance

  const FieldListTable({
    required this.viewModel,
    required this.label,
    super.key,
    this.useStrengths = true,
  });

  /// DigitalEfilingViewModel view model to handle actions

  final AppendixViewModel viewModel;

  /// Label
  final String label;

  /// use strengths flag
  final bool useStrengths;

  @override
  Widget build(BuildContext context) {
    final fieldValues = useStrengths
        ? viewModel.appendix.strengths
        : viewModel.appendix.threats;

    return LabelWidget(
      label: label,
      isRequired: true,
      child: CustomRawTable(
        key: UniqueKey(),
        autoFitWidth: false,
        columns: _getTableColumns(),
        headerFontSize: AppStyle.columnName,
        rows: List.generate(fieldValues.length, (index) {
          return [
            CustomTextField(
              maxLength: 200,
              initialValue: fieldValues[index],
              validator: (finalValue) {
                final String value = finalValue?.trim() ?? "";
                if (value.isEmpty) {
                  // Use localization key if you have one for this field
                  return "common.validation.required".tr();
                }
                return null;
              },
              onChanged: (value) {
                // just update the list in-place; no emit
                if (useStrengths) {
                  // direct write avoids a rebuild
                  viewModel.appendix.strengths[index] = value;
                } else {
                  viewModel.appendix.threats[index] = value;
                }
              },
              onSubmitted: (value) => viewModel.setFieldListItem(
                useStrengths: useStrengths,
                index: index,
                value: value,
              ),
            ),
            IconButton(
              alignment: Alignment.center,
              onPressed: () async {
                if (useStrengths) {
                  await viewModel.deleteFetchedStrengthAt(index);
                } else {
                  await viewModel.deleteFetchedThreatAt(index);
                }
              },
              icon: const Icon(Icons.delete),
            ),
          ];
        }),
      ),
    );
  }

  List<TableColumn> _getTableColumns() {
    return [
      TableColumn(
        forcedWidth: 353.w,
        label: Text(key: UniqueKey(), label),
      ),
      TableColumn(
        label: Text(
          key: UniqueKey(),
          "customerInformation.customerInformation.delete".tr(),
        ),
      ),
    ];
  }
}
