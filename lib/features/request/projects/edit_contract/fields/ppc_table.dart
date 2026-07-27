import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/state.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/utils/project_contract_numeric_helper.dart";

/// One widget class that can render PPC table in two modes:
/// - Display-only: PpcTable(viewModel, editable: false)
/// - Editable:     PpcTable(viewModel, editable: true, onFieldChanged: ...)
class PpcTable extends StatelessWidget {
  /// Creates a PPC table.
  const PpcTable(
    this.viewModel,
    this.state, {
    super.key,
    this.editable = false,
  });

  /// Edit contract view model.
  final EditContractViewModel viewModel;

  /// Edit contract state.
  final EditContractState state;

  /// Indicates whether the PPC table is editable.
  final bool editable;

  @override
  Widget build(BuildContext context) {
    final List<TextInputFormatter> textInputFormatter = [
      // Allow only digits, comma, and dot (no anchors!)
      FilteringTextInputFormatter.allow(RegExp(r"[0-9,\.]")),
      NumericDecimalTextInputFormatter(
        maxIntegerDigits: 15, // ← your requirement
        maxDecimalDigits: 6, // ← your requirement
      ),
    ];

    return CustomRawTable(
      key: ValueKey(
        state.refreshKey,
      ), // THIS FIXES UI REFRESH // ValueKey(viewModel.ppcControllerGeneration),
      columns: [
        TableColumn(
          forcedWidth: 40.w,
          label: Text("project.viewEditContractDetails.ppc_hash".tr()),
        ),
        TableColumn(
          forcedWidth: 90.w,
          label: Text("project.viewEditContractDetails.ppcDate".tr()),
        ),
        TableColumn(
          forcedWidth: 40.w,
          label: Text("project.viewEditContractDetails.grossPPCValue".tr()),
        ),
        TableColumn(
          forcedWidth: 40.w,
          label: Text(
            "project.viewEditContractDetails.cumulativePPCValue".tr(),
          ),
        ),
        TableColumn(
          forcedWidth: 30.w,
          label: Text("project.viewEditContractDetails.workDone".tr()),
        ),
        TableColumn(
          forcedWidth: 50.w,
          label: Text(
            "project.viewEditContractDetails.cumulativeWorkDone".tr(),
          ),
        ),
        TableColumn(
          forcedWidth: 70.w,
          label: Text(
            "project.viewEditContractDetails.advancedPaymentDeduction".tr(),
          ),
        ),
        TableColumn(
          forcedWidth: 40.w,
          label: Text(
            "project.viewEditContractDetails.retentionDeduction".tr(),
          ),
        ),
        TableColumn(
          forcedWidth: 60.w,
          label: Text("project.viewEditContractDetails.netPPCValue".tr()),
        ),
        TableColumn(
          forcedWidth: 40.w,
          label: Text("project.viewEditContractDetails.vatAmount".tr()),
        ),
        TableColumn(
          forcedWidth: 40.w,
          label: Text("project.viewEditContractDetails.otherPayment".tr()),
        ),
        TableColumn(
          forcedWidth: 60.w,
          label: Text(
            "project.viewEditContractDetails.netCertifiedAmountWithVat".tr(),
          ),
        ),
        TableColumn(
          forcedWidth: 60.w,
          label: Text(
            "project.viewEditContractDetails.actualPaymentReceived".tr(),
          ),
        ),
        TableColumn(
          forcedWidth: 90.w,
          label: Text(
            "project.viewEditContractDetails.datePaymentReceived".tr(),
          ),
        ),
        if (editable)
          TableColumn(
            label: Text("project.viewEditContractDetails.action".tr()),
          ),
        if (!editable) TableColumn(width: 1.w, label: const Text("")),
      ],

      rows: List.generate(viewModel.ppcList.length, (index) {
        final c = viewModel.ppcControllerss[index];
        final row = viewModel.ppcList[index];

        return [
          // PPC #
          CustomTextField(
            controller: c.ppcCtrl,
            readOnly: !viewModel.isNewRow[index] && c.ppcCtrl.text.isNotEmpty,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r"[0-9,\.]")),
            ],
            keyboardType: TextInputType.number,
            onChanged: (_) => viewModel.onChanged(index),
            onSubmitted: (_) => viewModel.onSubmitted(index),
            validator: (val) {
              if (viewModel.rowHasAnyInput(c)) {
                if (val == null || val.trim().isEmpty) {
                  return "PPC # is required";
                }
              }
              return null;
            },
          ),

          // PPC DATE
          CustomDatePicker(
            initialDateTime: DateTimeUtils.intToDateTime(c.ppcDateCtrl.text),
            onSubmit2: (val) {
              final String formatted =
                  val == null ? "" : DateFormat("dd/MM/yyyy").format(val);

              row.ppcDate = formatted;
              c.ppcDateCtrl.text = formatted;
              viewModel.onSubmitted(index, date: formatted);
              FocusScope.of(context).unfocus(); // closes keyboard
            },
            validator: (val) => viewModel.mandatoryDateIfOther(
              c: c,
              value: val,
              fieldLabel: "PPC Date",
            ),
          ),
          // GROSS PPC VALUE
          CustomTextField(
            controller: c.grossPPCValueCtrl,
            inputFormatters: [
              // "Total of Gross PPC Value is exceeding the Contract Value($cap)",
              TextInputFormatter.withFunction((oldValue, newValue) {
                final String text = newValue.text;
                if (text.isEmpty) {
                  return newValue;
                }

                final double? currentValue = double.tryParse(text);
                if (currentValue == null) {
                  return oldValue;
                }

                final double cap = double.tryParse(
                      viewModel.contractorValueController.text
                          .replaceAll(",", ""),
                    ) ??
                    viewModel.contractValue;

                // Calculate total including current edit
                final double totalExcludingCurrent =
                    viewModel.getTotalGrossPPC(ignoreIndex: index);

                final double newTotal = totalExcludingCurrent + currentValue;
                // final String alertNewTotal =
                //     ProjectContractNumericHelper.fmt6(newTotal) ;
                // final String alertcap = ProjectContractNumericHelper.fmt6(cap);
                if (newTotal > cap) {
                  AlertManager().showFailureToast(
                    "project.viewEditContractDetails.exceedingContractValue"
                        .tr(),
                    // "Total Gross PPC ($alertNewTotal) exceeds Contract Value ($alertcap)",
                  );
                  return newValue;
                  // return oldValue;
                }

                return newValue;
              }),
            ],
            onChanged: (_) => viewModel.onChanged(index),
            onSubmitted: (_) => viewModel.onSubmitted(index),
            validator: (val) => viewModel.mandatoryNumericIfOther(
              c: c,
              value: val,
              fieldLabel: "Gross PPC Value",
            ),
            // validator:  (value) => validateGross(value, index),
          ),

          // CUMULATIVE PPC VALUE (READ ONLY)
          BlocBuilder<EditContractViewModel, EditContractState>(
            bloc: viewModel,
            builder: (context, state) =>
                Text(ProjectContractNumericHelper.fmt6(row.cumulativeValue)),
          ),

          // % WORK DONE (READ ONLY)
          BlocBuilder<EditContractViewModel, EditContractState>(
            bloc: viewModel,
            builder: (context, state) =>
                Text(ProjectContractNumericHelper.fmtPercent(row.workDone)),
          ),

          // % CUMULATIVE WORK DONE
          BlocBuilder<EditContractViewModel, EditContractState>(
            bloc: viewModel,
            builder: (context, state) => Text(
              ProjectContractNumericHelper.fmtPercent(row.cumulativeWorkDone),
            ),
          ),

          // ADVANCE PAYMENT DEDUCTION
          CustomTextField(
            inputFormatters: textInputFormatter,
            controller: c.advancePaymentDeductionCtrl,
            onChanged: (_) => viewModel.onChanged(index),
            onSubmitted: (_) => viewModel.onSubmitted(index),
            validator: (val) => viewModel.mandatoryNumericIfOther(
              c: c,
              value: val,
              fieldLabel: "Advance Deduction",
            ),
          ),

          // RETENTION DEDUCTION
          CustomTextField(
            controller: c.retentionDeductionCtrl,
            inputFormatters: textInputFormatter,
            onChanged: (_) => viewModel.onChanged(index),
            onSubmitted: (_) => viewModel.onSubmitted(index),
            validator: (val) => viewModel.mandatoryNumericIfOther(
              c: c,
              value: val,
              fieldLabel: "Retention Deduction",
            ),
          ),

          // NET PPC VALUE (READ ONLY)
          BlocBuilder<EditContractViewModel, EditContractState>(
            bloc: viewModel,
            builder: (context, state) =>
                Text(ProjectContractNumericHelper.fmt6(row.netValue)),
          ),

          // VAT
          CustomTextField(
            controller: c.vatAmountCtrl,
            inputFormatters: textInputFormatter,
            onChanged: (_) => viewModel.onChanged(index),
            onSubmitted: (_) => viewModel.onSubmitted(index),
            validator: (val) => viewModel.mandatoryNumericIfOther(
              c: c,
              value: val,
              fieldLabel: "VAT Amount",
            ),
          ),

          // OTHER PAYMENT
          CustomTextField(
            inputFormatters: textInputFormatter,
            controller: c.otherPaymentCtrl,
            onChanged: (_) => viewModel.onChanged(index),
            onSubmitted: (_) => viewModel.onSubmitted(index),
            validator: (val) => viewModel.mandatoryNumericIfOther(
              c: c,
              value: val,
              fieldLabel: "Other Payment",
            ),
          ),

          // NET CERTIFIED + VAT
          BlocBuilder<EditContractViewModel, EditContractState>(
            bloc: viewModel,
            builder: (context, state) =>
                Text(ProjectContractNumericHelper.fmt6(row.totalWithVat)),
          ),

          // ACTUAL PAYMENT RECEIVED
          CustomTextField(
            inputFormatters: textInputFormatter,
            controller: c.actualPaymentReceivedCtrl,
            onChanged: (_) => viewModel.onChanged(index),
            onSubmitted: (_) => viewModel.onSubmitted(index),
            // validator: (val) => viewModel.mandatoryNumericIfOther(
            //   c: c,
            //   value: val,
            //   fieldLabel: "Actual Payment",
            // ),
          ),

          // DATE PAYMENT RECEIVED
          CustomDatePicker(
            initialDateTime:
                DateTimeUtils.intToDateTime(c.datePaymentReceivedCtrl.text),
            onSubmit2: (val) {
              final String formatted =
                  val == null ? "" : DateFormat("dd/MM/yyyy").format(val);

              row.datePaymentReceived = formatted;
              c.datePaymentReceivedCtrl.text = formatted;
              viewModel.onSubmitted(index, fmt: formatted);
              FocusScope.of(context).unfocus(); // closes keyboard
            },
            // validator: (val) => viewModel.mandatoryDateIfOther(
            //   c: c,
            //   value: val,
            //   fieldLabel: "Date Payment Received",
            // ),
          ),

          // ACTION COLUMN
          if (row.ppcId == null || row.ppcId! < 0)
            IconButton(
              key: ValueKey("ppc_${index}_delete"),
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: viewModel.canEdit
                  ? () => viewModel.removePPCRow(index)
                  : null,
            )
          else
            SizedBox(
              width: 35.w,
            ),
        ];
      }),
    );
  }

  /// Validates gross PPC value.
  String? validateGross(String? value, int index) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter gross value";
    }

    final parsedValue = double.tryParse(value);
    if (parsedValue == null) {
      return "Invalid number";
    }

    final cap = double.tryParse(
          viewModel.contractorValueController.text.replaceAll(",", ""),
        ) ??
        viewModel.contractValue;

    final totalExcludingCurrent =
        viewModel.getTotalGrossPPC(ignoreIndex: index);

    final newTotal = totalExcludingCurrent + parsedValue;

    if (newTotal > cap) {
      return "project.viewEditContractDetails.exceedingContractValue".tr();
      //"Total Gross PPC exceeds Contract Value ($cap)";
    }

    return null;
  }
}
