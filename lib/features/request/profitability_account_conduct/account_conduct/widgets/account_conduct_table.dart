import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/account_conduct/model.dart';
import 'package:wcas_frontend/models/request/profitability/account_stat.dart';

Widget accountConductTable(AccountConductViewModel viewModel, int index) {
  return CustomRawTable(
    key: UniqueKey(),
    // headerColor: AppColors.tableHeadingColor,
    autoFitWidth: true,
    // columnSpacing: 150.w,
    columnHeaderHeight: 30.w,
    columns: getAccountConductColumns(),
    rows: getAccountConductRows(viewModel.accountStat[index].accountConduct),
  );
}

List<TableColumn> getAccountConductColumns() {
  final int currentYear = DateTime.now().year;
  List<TableColumn> columns = [
    const TableColumn(
      label: Text(''),
    ),
    TableColumn(
      label: Text(
          "${"profitabilityAccountConduct.accountConduct.previousYear".tr()} (Jan - ${currentYear - 1} to Dec - ${currentYear - 1})"),
    ),
    TableColumn(
      label: Text(
          "${"profitabilityAccountConduct.accountConduct.currentYear".tr()} (Jan - $currentYear to YTD)"),
    ),
  ];

  return columns;
}

List<List<Widget>> getAccountConductRows(AccountStat? accountConduct) {
  return [
    [
      Text("profitabilityAccountConduct.accountConduct.odHardcore".tr()),
      Text(
        accountConduct?.odHardcorePreviousYear?.toStringAsFixed(2)??"",
        style: const TextStyle(color: AppColors.primary),
      ),
      Text(
        accountConduct?.odHardcoreCurrentYearYtd?.toStringAsFixed(2)??"",
        style: const TextStyle(color: AppColors.primary),
      ),
    ],
    [
      Text("profitabilityAccountConduct.accountConduct.chequeReturnsInward"
          .tr()),
      Text(
        accountConduct?.chequeReturnsInwardPreviousYear?.toStringAsFixed(2)??"",
        style: const TextStyle(color: AppColors.primary),
      ),
      Text(
        accountConduct?.chequeReturnsInwardCurrentYearYtd?.toStringAsFixed(2)??"",
        style: const TextStyle(color: AppColors.primary),
      ),
    ],
    [
      Text("profitabilityAccountConduct.accountConduct.chequeReturnsOutward"
          .tr()),
      Text(
        accountConduct?.chequeReturnsOutwardPreviousYear?.toStringAsFixed(2)??"",
        style: const TextStyle(color: AppColors.primary),
      ),
      Text(
        accountConduct?.chequeReturnsOutwardCurrentYearYtd?.toStringAsFixed(2)??"",
        style: const TextStyle(color: AppColors.primary),
      ),
    ],
    [
      Text("profitabilityAccountConduct.accountConduct.lbdReturns".tr()),
      Text(
        accountConduct?.lbdReturnsPreviousYear?.toStringAsFixed(2)??"",
        style: const TextStyle(color: AppColors.primary),
      ),
      Text(
        accountConduct?.lbdReturnsCurrentYearYtd?.toStringAsFixed(2)??"",
        style: const TextStyle(color: AppColors.primary),
      ),
    ],
  ];
}

Widget accountTransactionTable(AccountConductViewModel viewModel, int index) {
  return CustomRawTable(
    key: UniqueKey(),
    autoFitWidth: true,
    columnHeaderHeight: 0.w,
    rowHeight: 30.w,
    // headerColor: AppColors.tableHeadingColor,
    columns: getAccountTransactionColumns(),
    rows: getAccountTransactionRows(
        viewModel, viewModel.accountStat[index].accountConduct),
  );
}

List<TableColumn> getAccountTransactionColumns() {
  List<TableColumn> columns = [
    TableColumn(
      width: 120.w,
      label: const Text(''),
    ),
    TableColumn(
      width: 180.w,
      label: const Text(''),
    ),
  ];

  return columns;
}

List<List<Widget>> getAccountTransactionRows(
    AccountConductViewModel viewModel, AccountStat? accountConduct) {
  return [
    [
      Text(
        "profitabilityAccountConduct.accountConduct.pastDueOrExcesses".tr(),
      ),
      CustomTextField(
        maxLength: 1000,
        initialValue: accountConduct?.passDueOrExcesses.toString(),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        // inputFormatters: [DecimalInputFormatter()],
        validator:
            !viewModel.isFIApplication ? CustomValidator.requiredField : null,
        onChanged: (String value) {
          accountConduct?.passDueOrExcesses = double.tryParse(value) ?? 0.0;
        },
      )
    ],
    [
      Text(
        "profitabilityAccountConduct.accountConduct.chequeReturns".tr(),
      ),
      CustomTextField(
        maxLength: 1000,
        initialValue: accountConduct?.chequeReturns.toString(),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        // inputFormatters: [DecimalInputFormatter()],
        validator:
            !viewModel.isFIApplication ? CustomValidator.requiredField : null,
        onChanged: (String? value) {
          accountConduct?.chequeReturns = (value as num).toDouble();
        },
      )
    ],
    [
      Text("profitabilityAccountConduct.accountConduct.turnoverInTheAccount"
          .tr()),
      CustomTextField(
        maxLength: 1000,
        initialValue: accountConduct?.turnoverInTheAccount.toString(),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        // inputFormatters: [DecimalInputFormatter()],
        validator:
            !viewModel.isFIApplication ? CustomValidator.requiredField : null,
        onChanged: (String? value) {
          accountConduct?.turnoverInTheAccount = (value as num).toDouble();
        },
      )
    ],
    [
      Text(
        "profitabilityAccountConduct.accountConduct.odHardcore".tr(),
      ),
      CustomTextField(
        maxLength: 1000,
        initialValue: accountConduct?.odHardcore.toString(),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        // inputFormatters: [DecimalInputFormatter()],
        validator:
            !viewModel.isFIApplication ? CustomValidator.requiredField : null,
        onChanged: (String? value) {
          accountConduct?.odHardcore = (value as num).toDouble();
        },
      )
    ],
    [
      Text(
        "profitabilityAccountConduct.accountConduct.unusualTransactions".tr(),
      ),
      CustomTextField(
        maxLength: 1000,
        initialValue: accountConduct?.unusualTransactions.toString(),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        // inputFormatters: [DecimalInputFormatter()],
        validator:
            !viewModel.isFIApplication ? CustomValidator.requiredField : null,
        onChanged: (String? value) {
          accountConduct?.unusualTransactions = (value as num).toDouble();
        },
      )
    ],
    [
      Text(
          "profitabilityAccountConduct.accountConduct.transparencyAndDisclosureLevels"
              .tr()),
      CustomTextField(
        maxLength: 1000,
        initialValue:
            accountConduct?.transparencyAndDisclosureLevels.toString(),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        // inputFormatters: [DecimalInputFormatter()],
        validator:
            !viewModel.isFIApplication ? CustomValidator.requiredField : null,
        onChanged: (String? value) {
          accountConduct?.transparencyAndDisclosureLevels =
              (value as num).toDouble();
        },
      )
    ],
  ];
}
