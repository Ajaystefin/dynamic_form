import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/remarks/fee_structure/model.dart";
import "package:wcas_frontend/features/request/remarks/fee_structure/state.dart";
import "package:wcas_frontend/models/request/remarks/fee_structure.dart";

/// Displays the Fee Structure table and related actions.
class FeeStructureTableTab extends StatelessWidget {
  /// Creates a fee structure table tab.
  const FeeStructureTableTab({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// Fee Structure view model.
  final FeeStructureViewModel viewModel;

  /// Current Fee Structure state.
  final FeeStructureState state;

  @override
  Widget build(BuildContext context) {
    final List<FeeStructure> combinedRows = viewModel.combinedRows;
    final bool showAction = combinedRows.any(
      (r) => !viewModel.defaultFeeTypes.contains(r.feeType),
    );
    final bool isReady =
        combinedRows.length == viewModel.amountControllers.length &&
            combinedRows.length == viewModel.commentsControllers.length;

    if (!isReady || state.tableLoader == LoadingStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<TableColumn> columns = <TableColumn>[
      TableColumn(
        forcedWidth: 170.w,
        label: Text("remarks.feeStructure.feeType".tr()),
      ),
      TableColumn(
        forcedWidth: 80.w,
        label: _asterisk("remarks.feeStructure.amountPercentage".tr()),
      ),
      TableColumn(
        forcedWidth: 350.w,
        label: _asterisk("remarks.feeStructure.comments".tr()),
      ),
      if (showAction) const TableColumn(label: SizedBox.shrink()),
    ];

    final List<List<Widget>> rows = List.generate(combinedRows.length, (index) {
      final FeeStructure row = combinedRows[index];
      final bool isDefault = viewModel.defaultFeeTypes.contains(row.feeType);

      return <Widget>[
        if (isDefault)
          Text(row.feeType)
        else
          CustomTextField(
            key: ValueKey("feeType_$index"),
            initialValue: row.feeType,
            readOnly: viewModel.isReadOnlyMode,
            inputFormatters: [AlphanumericOrTwoDecimalInputFormatter()],
            maxLength: 50,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                row.feeType = "";
                return "common.validation.emptyField".tr();
              }
              return null;
            },
            onChanged: (value) => row.feeType = value,
          ),
        CustomTextField(
          key: ValueKey("amount_$index"),
          controller: viewModel.amountControllers[index],
          readOnly: viewModel.isReadOnlyMode,
          //validator: viewModel.isFI ? null : CustomValidator.requiredField,
          inputFormatters: [
            LengthLimitingTextInputFormatter(100),
          ],
          onChanged: (value) => viewModel.onAmountFieldChanged(index, value),
        ),
        CustomTextField(
          key: ValueKey("comments_$index"),
          controller: viewModel.commentsControllers[index],
          readOnly: viewModel.isReadOnlyMode,
          maxLength: 2000,
          //validator: viewModel.isFI ? null : CustomValidator.requiredField,
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
              rows: rows,
            ),
            const Gap(),
            AddItemButton(
              onTap: () => viewModel.isReadOnlyMode ? null : viewModel.addRow(),
              isLeftSided: true,
              child: Text("remarks.feeStructure.addFeeStructure".tr()),
            ),
            const Gap(),
          ],
        );
    }
  }

  Widget _asterisk(String text) {
    return Text(text);
    //   return viewModel.isFI
    //       ? Text(text)
    //       : Text.rich(
    //           TextSpan(
    //             text: text,
    //             children: const [
    //               TextSpan(
    //                 text: " *",
    //                 style: TextStyle(color: AppColors.failure),
    //               ),
    //             ],
    //           ),
    //         );
  }
}
