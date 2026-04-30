import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/model.dart";

/// Which statement table we’re rendering
enum StatementType { income, balance }

class AddTableRows extends StatelessWidget {
  // NEW

  const AddTableRows({
    required this.viewModel,
    required this.type,
    required this.text,
    required this.entityId,
    super.key, //, super.key,, super.key,
  });
  final GuarantorFinancialViewModel viewModel;
  final StatementType type;
  final String text;
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
