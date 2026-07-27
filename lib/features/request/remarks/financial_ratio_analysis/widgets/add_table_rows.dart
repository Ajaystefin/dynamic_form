import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/model.dart";

/// Types of financial statement tables supported by the screen.
enum StatementType {
  /// Income Statement Analysis table.
  income,

  /// Cash Flow Statement Analysis table.
  cashflow,

  /// Balance Sheet Analysis table.
  balance,
}

/// Displays a button for adding rows to a financial statement table.
class AddTableRows extends StatelessWidget {
  /// Creates an add-row action widget.
  const AddTableRows({
    required this.viewModel,
    required this.type,
    required this.text,
    super.key,
  });

  /// Financial Ratio Analysis view model.
  final FinancialRatioAnalysisViewModel viewModel;

  /// Statement table type.
  final StatementType type;

  /// Button label text.
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
