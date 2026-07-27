import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/model.dart";

/// Types of financial statement tables supported by the screen.
enum StatementType {
  /// Income statement analysis table.
  income,

  /// Balance sheet analysis table.
  balance,
}

/// Displays a button for adding rows to a financial statement table.
class AddTableRows extends StatelessWidget {
  /// Creates an add-row action widget.
  const AddTableRows({
    required this.viewModel,
    required this.type,
    required this.text,
    required this.entityId,
    super.key,
  });

  /// Guarantor financial view model.
  final GuarantorFinancialViewModel viewModel;

  /// Statement table type.
  final StatementType type;

  /// Button label text.
  final String text;

  /// Entity identifier associated with the table.
  final int entityId;

  @override
  Widget build(BuildContext context) {
    VoidCallback onAdd;
    switch (type) {
      case StatementType.income:
        onAdd = () => viewModel.addIncomeRowForEntity(entityId); //  NEW
      case StatementType.balance:
        onAdd = viewModel.addBalanceRow; // balance not entity-bound in UI yet
    }

    return AddItemButton(
      onTap: viewModel.isFI
          ? null
          : viewModel.isReadOnlyMode
              ? null
              : onAdd,
      isLeftSided: true,
      child: Text(
        text,
        semanticsLabel: text,
        style: const TextStyle(fontSize: AppStyle.fontSizeSmall),
      ),
    );
  }
}
