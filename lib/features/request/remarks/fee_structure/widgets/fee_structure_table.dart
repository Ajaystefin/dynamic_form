import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/add_item_button.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/text_utils.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/remarks/fee_structure/model.dart';
import 'package:wcas_frontend/features/request/remarks/fee_structure/state.dart';

class FeeStructureTableTab extends StatelessWidget {
  final FeeStructureViewModel viewModel;
  final FeeStructureState state;

  const FeeStructureTableTab({
    super.key,
    required this.viewModel,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final combinedRows = viewModel.combinedRows;
    final showAction = combinedRows.any(
      (r) => !viewModel.defaultFeeTypes.contains(r.feeType),
    );
    final isReady = combinedRows.length == viewModel.amountControllers.length &&
        combinedRows.length == viewModel.commentsControllers.length;

    if (!isReady || state.tableLoader == LoadingStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final columns = <TableColumn>[
      TableColumn(
        forcedWidth: 170.w,
        label: Text('remarks.feeStructure.feeType'.tr()),
      ),
      TableColumn(
        forcedWidth: 80.w,
        label: Text('remarks.feeStructure.amountPercentage'.tr()),
      ),
      TableColumn(
        forcedWidth: 350.w,
        label: Text('remarks.feeStructure.comments'.tr()),
      ),
      if (showAction) const TableColumn(label: SizedBox.shrink()),
    ];

    final rows = List.generate(combinedRows.length, (index) {
      final row = combinedRows[index];
      final isDefault = viewModel.defaultFeeTypes.contains(row.feeType);

      return <Widget>[
        isDefault
            ? Text(row.feeType)
            : CustomTextField(
                key: ValueKey('feeType_$index'),
                initialValue: row.feeType.capitalizeFirstLetter(),
                readOnly: viewModel.isReadOnlyMode,
                maxLength: 50,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    row.feeType = '';
                    return 'common.validation.emptyField'.tr();
                  }
                  return null;
                },
                onChanged: (value) => row.feeType = value,
              ),
        CustomTextField(
          key: ValueKey('amount_$index'),
          controller: viewModel.amountControllers[index],
          readOnly: viewModel.isReadOnlyMode,
          // validator: (value) {
          //   if (value == null || value.trim().isEmpty) {
          //     viewModel.onAmountFieldChanged(index, '');
          //     return 'common.validation.emptyField'.tr();
          //   }
          //   return null;
          // },
          validator: CustomValidator.requiredField,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d\.Nn/Aa]')),
            CustomValidator.naOrNumberUpTo100Formatter(),
          ],
          onChanged: (value) => viewModel.onAmountFieldChanged(index, value),
        ),
        CustomTextField(
          key: ValueKey('comments_$index'),
          controller: viewModel.commentsControllers[index],
          readOnly: viewModel.isReadOnlyMode,
          // validator: (value) {
          //   if (value == null || value.trim().isEmpty) {
          //     row.comments = '';
          //     return 'common.validation.emptyField'.tr();
          //   }
          //   return null;
          // },
          validator: CustomValidator.requiredField,
          onChanged: (value) => row.comments = value,
        ),
        if (showAction)
          isDefault
              ? const SizedBox.shrink()
              : Center(
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => viewModel.isReadOnlyMode
                        ? null
                        : viewModel.deleteRow(row),
                  ),
                ),
      ];
    });

    switch (state.tableLoader) {
      case LoadingStatus.loading:
        return const Center(child: CircularProgressIndicator());
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomRawTable(
              key: UniqueKey(),
              columns: columns,
              autoFitWidth: true,
              rows: rows,
            ),
            const Gap(size: GapSize.medium),
            AddItemButton(
              onTap: () => viewModel.isReadOnlyMode ? null : viewModel.addRow(),
              isLeftSided: true,
              child: Text("remarks.feeStructure.addFeeStructure".tr()),
            ),
            const Gap(size: GapSize.medium),
          ],
        );
    }
  }
}
