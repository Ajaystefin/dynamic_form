import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/model.dart";

/// Which statement table we’re rendering
enum StatementType { income, cashflow, balance }

class AddTableRows extends StatelessWidget {
  const AddTableRows({
    required this.viewModel,
    required this.type,
    required this.text,
    super.key,
  });
  final FinancialRatioAnalysisViewModel viewModel;
  final StatementType type;
  final String text;

  @override
  Widget build(BuildContext context) {
    VoidCallback? onAdd;

    switch (type) {
      case StatementType.income:
        onAdd = viewModel.addIncomeRow;
      case StatementType.cashflow:
        onAdd = viewModel.addCashflowRow;
      case StatementType.balance:
        onAdd = viewModel.addBalanceRow;
    }

    return AddItemButton(
      onTap: onAdd,
      isLeftSided: true,
      child: Text(
        text,
        semanticsLabel: "remarks.financialRatiosAnalysis.addFinancials".tr(),
        style: const TextStyle(fontSize: AppStyle.fontSizeSmall),
      ),
    );
  }
}
