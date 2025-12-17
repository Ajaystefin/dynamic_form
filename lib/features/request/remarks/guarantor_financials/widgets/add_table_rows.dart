import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/add_item_button.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/remarks/guarantor_financials/model.dart';

/// Which statement table we’re rendering
enum StatementType { income, balance }

class AddTableRows extends StatelessWidget {
  final GuarantorFinancialViewModel viewModel;
  final StatementType type;
  final String text;

  const AddTableRows(
      {super.key,
      required this.viewModel,
      required this.type,
      required this.text});

  @override
  Widget build(BuildContext context) {
    VoidCallback onAdd;
    switch (type) {
      case StatementType.income:
        onAdd = viewModel.addIncomeRow;
        break;
      case StatementType.balance:
        onAdd = viewModel.addBalanceRow;
        break;
    }

    return AddItemButton(
        onTap:  onAdd,
        isLeftSided: true,
        child: Text(
          text,
          semanticsLabel: text,
          style: const TextStyle(fontSize: AppStyle.fontSizeSmall),
        ));
  }
}
