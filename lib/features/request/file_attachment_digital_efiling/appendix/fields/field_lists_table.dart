import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart';

class FieldListTable extends StatelessWidget {
  final AppendixViewModel viewModel;
  final String label;
  final void Function(int index) onRemove;
  final void Function(int index, String value) onUpdate;

  const FieldListTable({
    super.key,
    required this.viewModel,
    required this.label,
    required this.onRemove,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final fieldValues = viewModel.fieldValues;

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
              readOnly: false,
              filled: false,
              maxLength: 50,
              counterText: '',
              initialValue: fieldValues[index],
              onSubmitted: (value) => onUpdate(index, value),
            ),
            IconButton(alignment: Alignment.center,
              onPressed: () => onRemove(index),
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
        label: Text(
          key: UniqueKey(),
          label,
        ),
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
