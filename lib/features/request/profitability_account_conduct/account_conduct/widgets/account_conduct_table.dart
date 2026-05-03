import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/account_conduct/model.dart";
import "package:wcas_frontend/models/request/profitability/account_conduct.dart";

/// ---------------------------------------------------------------------------
/// Wrapper section: renders Read-only table + Editable table within a Form.
/// ---------------------------------------------------------------------------
Widget accountConductSection(AccountConductViewModel viewModel, int index) {
  return Form(
    key: viewModel.formKey,
    child: Column(
      children: [
        accountConductTable(viewModel, index),
        const SizedBox(height: 8),
        accountTransactionTable(viewModel, index),
      ],
    ),
  );
}

/// ---------- Read-only conduct details ----------

Widget accountConductTable(AccountConductViewModel viewModel, int index) {
  final dto = viewModel.customers[index];

  return CustomRawTable(
    // IMPORTANT: do not use UniqueKey to avoid losing TextField state on
    // rebuilds
    autoFitWidth: true,
    columnHeaderHeight: 30.w,
    columns: getAccountConductColumns(viewModel),
    rows: getAccountConductRows(dto),
  );
}

List<TableColumn> getAccountConductColumns(AccountConductViewModel vm) {
  return [
    const TableColumn(label: Text("")),
    TableColumn(label: Text(vm.previousYearHeader)),
    TableColumn(label: Text(vm.currentYearHeader)),
  ];
}

List<List<Widget>> getAccountConductRows(AccountConductDto dto) {
  return dto.accountConductDetailsList.map((detail) {
    return [
      Text(detail.name ?? ""),
      Text(
        detail.previousYear ?? "",
        style: const TextStyle(color: AppColors.primary),
      ),
      Text(
        detail.currentYear ?? "",
        style: const TextStyle(color: AppColors.primary),
      ),
    ];
  }).toList();
}

/// ---------- Editable transaction / summary metrics ----------

Widget accountTransactionTable(AccountConductViewModel viewModel, int index) {
  final dto = viewModel.customers[index];

  return CustomRawTable(
    // No UniqueKey here—keeps TextField state stable.
    autoFitWidth: true,
    columnHeaderHeight: 30.w,
    rowHeight: 30.w,
    columns: getAccountTransactionColumns(),
    rows: getAccountTransactionRows(viewModel, dto, index),
  );
}

List<TableColumn> getAccountTransactionColumns() {
  return [
    TableColumn(forcedWidth: 180.w, label: const Text("")),
    TableColumn(forcedWidth: 250.w, label: const Text("")),
  ];
}

List<List<Widget>> getAccountTransactionRows(
  AccountConductViewModel viewModel,
  AccountConductDto dto,
  int index,
) {
  final List<TextInputFormatter> numFormatters = [
    // DecimalInputFormatter(regEx: RegExp(r'^[0-9,]{0,15}(\.\d{0,6})?$')),
    LengthLimitingTextInputFormatter(200),
  ];

  final bool isRequired = !viewModel.isFIApplication;

  return [
    // Past Due or Excesses
    [
      Text("profitabilityAccountConduct.accountConduct.pastDueOrExcesses".tr()),
      CustomTextField(
        key: ValueKey("passDueOrExcesses_$index"),
        maxLength: 200,
        controller: viewModel.controllerFor("passDueOrExcesses", index),
        // keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: numFormatters,
        validator: isRequired ? CustomValidator.requiredField : null,
        onChanged: (String value) {
          //final parsed = double.tryParse(value.trim());
          viewModel.updateCustomer(
            index,
            dto.copyWith(passDueOrExcesses: value),
          );
        },
        onSaved: (String? value) {
          //final parsed = double.tryParse((value ?? '').trim());
          viewModel.updateCustomer(
            index,
            dto.copyWith(passDueOrExcesses: value),
          );
        },
      ),
    ],

    // Cheque Returns
    [
      Text("profitabilityAccountConduct.accountConduct.chequeReturns".tr()),
      CustomTextField(
        key: ValueKey("chequeReturns_$index"),
        controller: viewModel.controllerFor("chequeReturns", index),
        // keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLength: 200,
        inputFormatters: numFormatters,
        validator: isRequired ? CustomValidator.requiredField : null,
        onChanged: (String value) {
          // final parsed = double.tryParse(value.trim());
          viewModel.updateCustomer(index, dto.copyWith(chequeReturns: value));
        },
        onSaved: (String? value) {
          // final parsed = double.tryParse((value ?? '').trim());
          viewModel.updateCustomer(index, dto.copyWith(chequeReturns: value));
        },
      ),
    ],

    // Turnover in the Account
    [
      Text(
        "profitabilityAccountConduct.accountConduct.turnoverInTheAccount".tr(),
      ),
      CustomTextField(
        key: ValueKey("turnoverInAcc_$index"),
        controller: viewModel.controllerFor("turnoverInAcc", index),
        // keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLength: 200,
        inputFormatters: numFormatters,
        validator: isRequired ? CustomValidator.requiredField : null,
        onChanged: (String value) {
          // final parsed = double.tryParse(value.trim());
          viewModel.updateCustomer(index, dto.copyWith(turnoverInAcc: value));
        },
        onSaved: (String? value) {
          // final parsed = double.tryParse((value ?? '').trim());
          viewModel.updateCustomer(index, dto.copyWith(turnoverInAcc: value));
        },
      ),
    ],

    // OD Hardcore
    [
      Text("profitabilityAccountConduct.accountConduct.odHardcore".tr()),
      CustomTextField(
        key: ValueKey("odHardcore_$index"),
        controller: viewModel.controllerFor("odHardcore", index),
        // keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLength: 200,
        inputFormatters: numFormatters,
        validator: isRequired ? CustomValidator.requiredField : null,
        onChanged: (String value) {
          // final parsed = double.tryParse(value.trim());
          viewModel.updateCustomer(index, dto.copyWith(odHardcore: value));
        },
        onSaved: (String? value) {
          // final parsed = double.tryParse((value ?? '').trim());
          viewModel.updateCustomer(index, dto.copyWith(odHardcore: value));
        },
      ),
    ],

    // Unusual Transactions
    [
      Text(
        "profitabilityAccountConduct.accountConduct.unusualTransactions".tr(),
      ),
      CustomTextField(
        key: ValueKey("unusualTransactions_$index"),
        controller: viewModel.controllerFor("unusualTransactions", index),
        // keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLength: 200,
        inputFormatters: numFormatters,
        validator: isRequired ? CustomValidator.requiredField : null,
        onChanged: (String value) {
          // final parsed = double.tryParse(value.trim());
          viewModel.updateCustomer(
            index,
            dto.copyWith(unusualTransactions: value),
          );
        },
        onSaved: (String? value) {
          // final parsed = double.tryParse((value ?? '').trim());
          viewModel.updateCustomer(
            index,
            dto.copyWith(unusualTransactions: value),
          );
        },
      ),
    ],

    // Transparency & Disclosure Levels
    [
      Text(
        "profitabilityAccountConduct.accountConduct."
                "transparencyAndDisclosureLevels"
            .tr(),
      ),
      CustomTextField(
        key: ValueKey("transparencyDisclosureLevels_$index"),
        controller:
            viewModel.controllerFor("transparencyDisclosureLevels", index),
        // keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLength: 200,
        inputFormatters: numFormatters,
        validator: isRequired ? CustomValidator.requiredField : null,
        onChanged: (String value) {
          // final parsed = double.tryParse(value.trim());
          viewModel.updateCustomer(
            index,
            dto.copyWith(transparencyDisclosureLevels: value),
          );
        },
        onSaved: (String? value) {
          // final parsed = double.tryParse((value ?? '').trim());
          viewModel.updateCustomer(
            index,
            dto.copyWith(transparencyDisclosureLevels: value),
          );
        },
      ),
    ],
  ];
}
