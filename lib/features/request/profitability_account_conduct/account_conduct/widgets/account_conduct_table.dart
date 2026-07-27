import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/textarea.dart";
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
    columnHeaderHeight: 30.w,
    columns: getAccountConductColumns(viewModel),
    rows: getAccountConductRows(dto),
  );
}

/// Returns account conduct table columns.
List<TableColumn> getAccountConductColumns(AccountConductViewModel vm) {
  return [
    const TableColumn(label: Text("")),
    TableColumn(label: Text(vm.previousYearHeader)),
    TableColumn(label: Text(vm.currentYearHeader)),
  ];
}

/// Returns account conduct table rows.
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
    columnHeaderHeight: 30.w,
    rowHeight: 42.w,
    columns: getAccountTransactionColumns(),
    rows: getAccountTransactionRows(viewModel, dto, index),
  );
}

/// Returns account transaction table columns.
List<TableColumn> getAccountTransactionColumns() {
  return [
    TableColumn(forcedWidth: 180.w, label: const Text("")),
    TableColumn(forcedWidth: 250.w, label: const Text("")),
  ];
}

/// Returns editable account transaction rows.
List<List<Widget>> getAccountTransactionRows(
  AccountConductViewModel viewModel,
  AccountConductDto dto,
  int index,
) {
  final bool isRequired = !viewModel.isFIApplication;

  return [
    // Past Due or Excesses
    [
      Text("profitabilityAccountConduct.accountConduct.pastDueOrExcesses".tr()),
      CustomTextArea(
        key: ValueKey("passDueOrExcesses_$index"),
        maxLength: 200,
        controller: viewModel.controllerFor("passDueOrExcesses", index),
        maxLines: 4,
        minLines: 4,
        // keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
      CustomTextArea(
        key: ValueKey("chequeReturns_$index"),
        controller: viewModel.controllerFor("chequeReturns", index),
        // keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLength: 200,
        maxLines: 4,
        minLines: 4,
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
      CustomTextArea(
        key: ValueKey("turnoverInAcc_$index"),
        controller: viewModel.controllerFor("turnoverInAcc", index),
        // keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLength: 200,
        maxLines: 4,
        minLines: 4,
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
      CustomTextArea(
        key: ValueKey("odHardcore_$index"),
        controller: viewModel.controllerFor("odHardcore", index),
        // keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLength: 200,
        maxLines: 4,
        minLines: 4,
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
      CustomTextArea(
        key: ValueKey("unusualTransactions_$index"),
        controller: viewModel.controllerFor("unusualTransactions", index),
        // keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLength: 200,
        maxLines: 4,
        minLines: 4,
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
      CustomTextArea(
        key: ValueKey("transparencyDisclosureLevels_$index"),
        controller:
            viewModel.controllerFor("transparencyDisclosureLevels", index),
        // keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLength: 200,
        maxLines: 4,
        minLines: 4,
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
