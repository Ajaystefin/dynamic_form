import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/utils/project_contract_numeric_helper.dart";

/// One widget class that can render PPC table in two modes:
/// - Display-only: PpcTable(viewModel, editable: false)
/// - Editable:     PpcTable(viewModel, editable: true, onFieldChanged: ...)
class PpcTable extends StatelessWidget {
  const PpcTable(
    this.viewModel, {
    super.key,
    this.editable = false,
    this.onFieldChanged,
  });
  final EditContractViewModel viewModel;
  final bool editable;

  /// Optional callback to trigger UI refresh or side-effects on field changes.
  /// Typically you might call setState / Bloc emit after recomputation.
  final void Function(int rowIndex)? onFieldChanged;

  @override
  Widget build(BuildContext context) {
    // Helper: read-only field bound via a fresh controller so it reflects on
    // every rebuild.
    // CustomTextField roCtrlField(String value) => CustomTextField(
    //       controller: TextEditingController(
    //           text: value), // <-- controller, not initialValue
    //       readOnly: true,
    //       filled: true,
    //       onSaved: (p0) {},
    //     );

    final List<TextInputFormatter> textInputFormatter = [
      // Allow only digits, comma, and dot (no anchors!)
      FilteringTextInputFormatter.allow(RegExp(r"[0-9,\.]")),
      NumericDecimalTextInputFormatter(
        maxIntegerDigits: 15, // ← your requirement
        maxDecimalDigits: 6, // ← your requirement
      ),
    ];

    return CustomRawTable(
      // key: ValueKey((viewModel.ppc.length)),
      key: ValueKey(viewModel.ppcControllerGeneration),
      autoFitWidth: true,
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
      rows: List.generate(viewModel.ppc.length, (index) {
        final dataPPCItem = viewModel.ppc[index];

        final bool isRowEditable = editable &&
            (index < viewModel.isNewRow.length) &&
            viewModel.isNewRow[index];

        // Widget roField(String value) => Text(value);

        // --- Editable rows (newly added) --- (UNCHANGED)
        if (isRowEditable) {
          final ppcCntrlr = viewModel.ppcControllers[index];

          void onAnyFieldChanged() {
            viewModel.syncRowFromControllers(
              index,
            ); // recomputeDerived() + emitPpcSoft()
            onFieldChanged?.call(index);
            viewModel.emitPpcSoft();
          }

          const numType = TextInputType.numberWithOptions(decimal: true);

          final bool isBlankNewRow = isRowEditable &&
              (ppcCntrlr.ppcCtrl.text.trim().isEmpty) &&
              (ppcCntrlr.grossPPCValueCtrl.text.trim().isEmpty) &&
              (ppcCntrlr.advancePaymentDeductionCtrl.text.trim().isEmpty) &&
              (ppcCntrlr.retentionDeductionCtrl.text.trim().isEmpty) &&
              (ppcCntrlr.vatAmountCtrl.text.trim().isEmpty) &&
              (ppcCntrlr.otherPaymentCtrl.text.trim().isEmpty) &&
              (ppcCntrlr.actualPaymentReceivedCtrl.text.trim().isEmpty);

          final String cumPpcDisplay = isBlankNewRow
              ? ""
              : ProjectContractNumericHelper.fmt6(
                  dataPPCItem.cumulativePpcResolved,
                );
          final String pctWorkDoneDisplay = isBlankNewRow
              ? ""
              : ProjectContractNumericHelper.fmtPercent(
                  dataPPCItem.workDonePercentResolved,
                );
          final String pctCumWorkDoneDisplay = isBlankNewRow
              ? ""
              : ProjectContractNumericHelper.fmtPercent(
                  dataPPCItem.cumulativeWorkDonePercentResolved,
                );
          final String netPpcDisplay = isBlankNewRow
              ? ""
              : ProjectContractNumericHelper.fmt6(dataPPCItem.netPpcResolved);
          final String netCertPlusVatDisplay = isBlankNewRow
              ? ""
              : ProjectContractNumericHelper.fmt6(
                  dataPPCItem.netCertifiedAmountVat,
                );

          return [
            // 1) PPC (numeric) — validator
            CustomTextField(
              key: ValueKey("ppc_${index}_ppc"),
              controller: ppcCntrlr.ppcCtrl,
              filled: (viewModel.canEdit) ? false : true,
              readOnly: (viewModel.canEdit) ? false : true,
              keyboardType: numType,
              inputFormatters: textInputFormatter,
              validator: (val) => viewModel.mandatoryNumericIfOther(
                c: ppcCntrlr,
                value: val,
                fieldLabel: "PPC",
              ),
              onSubmitted: (_) => viewModel.handleSubmitForRow(
                context,
                ppcCntrlr,
                index,
                onAnyFieldChanged,
              ),
            ),

            // 2) PPC Date (DD/MM/YYYY) — validator
            CustomDatePicker(
              isEnabled: (viewModel.canEdit) ? true : false,
              key: ValueKey("ppc_${index}_ppcDate"),
              initialDateTime:
                  DateTimeUtils.intToDateTime(ppcCntrlr.ppcDateCtrl.text),
              onSubmit2: (DateTime? dt) {
                ppcCntrlr.ppcDateCtrl.text =
                    dt == null ? "" : DateFormat("dd/MM/yyyy").format(dt);
                onAnyFieldChanged();
              },
              validator: (val) => viewModel.mandatoryDateIfOther(
                c: ppcCntrlr,
                value: val,
                fieldLabel: "PPC Date",
              ),
            ),

            // 3) Gross PPC Value (numeric) — validator
            CustomTextField(
              key: ValueKey("ppc_${index}_gross"),
              filled: (viewModel.canEdit) ? false : true,
              readOnly: (viewModel.canEdit) ? false : true,
              controller: ppcCntrlr.grossPPCValueCtrl,
              keyboardType: numType,
              inputFormatters: textInputFormatter,
              // For GrossPay validation with Contract Value
              // TextInputFormatter.withFunction((oldValue, newValue) {
              //   final text = newValue.text;
              //   if (text.isEmpty) return newValue;

              //   if (text == viewModel.contractorValueController.text ||
              //       text == viewModel.contractValue.toString()) {
              //     return newValue;
              //   }

              //   final value = double.tryParse(text);
              //   if (value == null) return oldValue;

              //   final cap = (double.tryParse(viewModel
              //           .contractorValueController.text
              //           .toString()) ??
              //       viewModel.contractValue);
              //   if (value > cap) return oldValue;

              //   return newValue;
              // }),

              validator: (val) => viewModel.mandatoryNumericIfOther(
                c: ppcCntrlr,
                value: val,
                fieldLabel: "Gross PPC Value",
              ),
              onSubmitted: (_) => viewModel.handleSubmitForRow(
                context,
                ppcCntrlr,
                index,
                onAnyFieldChanged,
              ),
            ),

            // ---- Derived (read-only) ----
            CustomTextField(
              key: ValueKey("ppc_${index}_cumPpc"),
              controller: TextEditingController(text: cumPpcDisplay),
              readOnly: true,
              filled: true,
              onSaved: (p0) {},
              inputFormatters: textInputFormatter,
            ), // (1)
            CustomTextField(
              key: ValueKey("ppc_${index}_pctWorkDone"),
              controller: TextEditingController(text: pctWorkDoneDisplay),
              readOnly: true,
              filled: true,
              onSaved: (p0) {},
              inputFormatters: textInputFormatter,
            ), // (2)
            CustomTextField(
              key: ValueKey("ppc_${index}_pctCumWorkDone"),
              controller: TextEditingController(text: pctCumWorkDoneDisplay),
              readOnly: true,
              filled: true,
              onSaved: (p0) {},
              inputFormatters: textInputFormatter,
            ), // (3)

            // 4) Advance Payment Deduction (numeric) — validator
            CustomTextField(
              key: ValueKey("ppc_${index}_adv"),
              filled: (viewModel.canEdit) ? false : true,
              readOnly: (viewModel.canEdit) ? false : true,
              controller: ppcCntrlr.advancePaymentDeductionCtrl,
              keyboardType: numType,
              validator: (val) => viewModel.mandatoryNumericIfOther(
                c: ppcCntrlr,
                value: val,
                fieldLabel: "Advance Payment Deduction",
              ),
              onSubmitted: (_) => viewModel.handleSubmitForRow(
                context,
                ppcCntrlr,
                index,
                onAnyFieldChanged,
              ),
              inputFormatters: textInputFormatter,
            ),

            // 5) Retention Deduction (numeric) — validator
            CustomTextField(
              key: ValueKey("ppc_${index}_ret"),
              controller: ppcCntrlr.retentionDeductionCtrl,
              filled: (viewModel.canEdit) ? false : true,
              readOnly: (viewModel.canEdit) ? false : true,
              keyboardType: numType,
              validator: (val) => viewModel.mandatoryNumericIfOther(
                c: ppcCntrlr,
                value: val,
                fieldLabel: "Retention Deduction",
              ),
              onSubmitted: (_) => onAnyFieldChanged(),
              inputFormatters: textInputFormatter,
            ),

            // ---- Derived (read-only) ----
            CustomTextField(
              key: ValueKey("ppc_${index}_netPpc"),
              controller: TextEditingController(text: netPpcDisplay),
              readOnly: true,
              filled: true,
              onSaved: (p0) {},
              inputFormatters: textInputFormatter,
            ), // (4)

            // 6) VAT Amount (numeric) — validator
            CustomTextField(
              key: ValueKey("ppc_${index}_vat"),
              controller: ppcCntrlr.vatAmountCtrl,
              filled: (viewModel.canEdit) ? false : true,
              readOnly: (viewModel.canEdit) ? false : true,
              keyboardType: numType,
              validator: (val) => viewModel.mandatoryNumericIfOther(
                c: ppcCntrlr,
                value: val,
                fieldLabel: "VAT Amount",
              ),
              onSubmitted: (_) => viewModel.handleSubmitForRow(
                context,
                ppcCntrlr,
                index,
                onAnyFieldChanged,
              ),
              inputFormatters: textInputFormatter,
            ),

            // 7) Other Payment (numeric) — validator
            CustomTextField(
              key: ValueKey("ppc_${index}_other"),
              controller: ppcCntrlr.otherPaymentCtrl,
              keyboardType: numType,
              filled: (viewModel.canEdit) ? false : true,
              readOnly: (viewModel.canEdit) ? false : true,
              validator: (val) => viewModel.mandatoryNumericIfOther(
                c: ppcCntrlr,
                value: val,
                fieldLabel: "Other Payment",
              ),
              onSubmitted: (_) => viewModel.handleSubmitForRow(
                context,
                ppcCntrlr,
                index,
                onAnyFieldChanged,
              ),
              inputFormatters: textInputFormatter,
            ),

            // ---- Derived (read-only) ----
            CustomTextField(
              key: ValueKey("ppc_${index}_netCertVat"),
              controller: TextEditingController(text: netCertPlusVatDisplay),
              readOnly: true,
              filled: true,
              onSaved: (p0) {},
              inputFormatters: textInputFormatter,
            ), // (5)

            // 8) Actual Payment Received (numeric) — validator
            CustomTextField(
              key: ValueKey("ppc_${index}_actual"),
              controller: ppcCntrlr.actualPaymentReceivedCtrl,
              filled: (viewModel.canEdit) ? false : true,
              readOnly: (viewModel.canEdit) ? false : true,
              keyboardType: numType,
              validator: (val) => viewModel.mandatoryNumericIfOther(
                c: ppcCntrlr,
                value: val,
                fieldLabel: "Actual Payment Received",
              ),
              onSubmitted: (_) => viewModel.handleSubmitForRow(
                context,
                ppcCntrlr,
                index,
                onAnyFieldChanged,
              ),
              inputFormatters: textInputFormatter,
            ),

            // 9) Date Payment Received (DD/MM/YYYY) — validator
            CustomDatePicker(
              key: ValueKey("ppc_${index}_dateReceived"),
              isEnabled: (viewModel.canEdit) ? true : false,
              initialDateTime: DateTimeUtils.intToDateTime(
                ppcCntrlr.datePaymentReceivedCtrl.text,
              ),
              onSubmit2: (DateTime? dt) {
                ppcCntrlr.datePaymentReceivedCtrl.text =
                    dt == null ? "" : DateFormat("dd/MM/yyyy").format(dt);
                onAnyFieldChanged();
              },
              validator: (val) => viewModel.mandatoryDateIfOther(
                c: ppcCntrlr,
                value: val,
                fieldLabel: "Date Payment Received",
              ),
            ),

            // 10) Delete action
            IconButton(
              key: ValueKey("ppc_${index}_delete"),
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: viewModel.canEdit
                  ? () => viewModel.removePpcRow(index)
                  : null,
            ),
          ];
        }

// --- Display-only rows (API-loaded) BUT editable for cells 2..10 ---
        final ppcCntrlr = viewModel.ppcControllers[index];

// Keep your prefill
        viewModel.prefillPpcControllersFromModel(index, dataPPCItem);

        void onAnyFieldChanged() {
          viewModel.syncRowFromControllers(
            index,
          ); // recomputeDerived() + emitPpcSoft()
          onFieldChanged?.call(index);
          viewModel.emitPpcSoft();
        }

// Use resolved getters for derived values so API payload keys work
        final String cumPpcDisplay = ProjectContractNumericHelper.fmt6(
          dataPPCItem.cumulativePpcResolved,
        );
        final String pctWorkDoneDisplay =
            ProjectContractNumericHelper.fmtPercent(
          dataPPCItem.workDonePercentResolved,
        );
        final String pctCumWorkDoneDisplay =
            ProjectContractNumericHelper.fmtPercent(
          dataPPCItem.cumulativeWorkDonePercentResolved,
        );
        final String netPpcDisplay =
            ProjectContractNumericHelper.fmt6(dataPPCItem.netPpcResolved);
        final String netCertPlusVatDisplay = ProjectContractNumericHelper.fmt6(
          dataPPCItem.netCertifiedAmountVat,
        );

// Cell 1: PPC # read-only from unified display getter
// roField(dataPPCItem.ppcDisplayNo),

        const numType = TextInputType.numberWithOptions(decimal: true);

        return [
          // Cell 1: PPC No (read-only)
          // roField(dataPPCItem.ppcId.toString()),
          CustomTextField(
            key: ValueKey("ppc_${index}_ppc"),
            controller: ppcCntrlr.ppcCtrl,
            keyboardType: numType,
            inputFormatters: textInputFormatter,
            filled: true,
            readOnly: true,
          ),

          // Cell 2: PPC Date (editable)
          CustomDatePicker(
            key: ValueKey("ppc_${index}_ppcDate"),
            isEnabled: (viewModel.canEdit) ? true : false,
            initialDateTime:
                DateTimeUtils.intToDateTime(ppcCntrlr.ppcDateCtrl.text),
            onSubmit2: (DateTime? dt) {
              ppcCntrlr.ppcDateCtrl.text =
                  dt == null ? "" : DateFormat("dd/MM/yyyy").format(dt);
              onAnyFieldChanged();
            },
            validator: (val) => viewModel.mandatoryDateIfOther(
              c: ppcCntrlr,
              value: val,
              fieldLabel: "PPC Date",
            ),
          ),

          // Cell 3: Gross PPC Value (editable)
          CustomTextField(
            key: ValueKey("ppc_${index}_gross"),
            controller: ppcCntrlr.grossPPCValueCtrl,
            filled: (viewModel.canEdit) ? false : true,
            readOnly: (viewModel.canEdit) ? false : true,
            keyboardType: numType,
            inputFormatters: textInputFormatter
            // For GrossPay validation with Contract Value
            // TextInputFormatter.withFunction((oldValue, newValue) {
            //   final text = newValue.text;
            //   if (text.isEmpty) return newValue;

            //   if (text == viewModel.contractorValueController.text ||
            //       text == viewModel.contractValue.toString()) {
            //     return newValue;
            //   }

            //   final value = double.tryParse(text);
            //   if (value == null) return oldValue;

            //   final cap = (double.tryParse(
            //           viewModel.contractorValueController.text.toString()) ??
            //       viewModel.contractValue);
            //   if (value > cap) return oldValue;

            //   return newValue;
            // }
            // ),
            ,
            validator: (val) => viewModel.mandatoryNumericIfOther(
              c: ppcCntrlr,
              value: val,
              fieldLabel: "Gross PPC Value",
            ),
            onSubmitted: (_) => viewModel.handleSubmitForRow(
              context,
              ppcCntrlr,
              index,
              onAnyFieldChanged,
            ),
          ),

          // Derived (read-only)
          CustomTextField(
            key: ValueKey("ppc_${index}_cumPpc"),
            controller: TextEditingController(text: cumPpcDisplay),
            readOnly: true,
            filled: true,
            onSaved: (p0) {},
            inputFormatters: textInputFormatter,
          ),
          CustomTextField(
            key: ValueKey("ppc_${index}_pctWorkDone"),
            controller: TextEditingController(text: pctWorkDoneDisplay),
            readOnly: true,
            filled: true,
            onSaved: (p0) {},
            inputFormatters: textInputFormatter,
          ),
          CustomTextField(
            key: ValueKey("ppc_${index}_pctCumWorkDone"),
            controller: TextEditingController(text: pctCumWorkDoneDisplay),
            readOnly: true,
            filled: true,
            onSaved: (p0) {},
            inputFormatters: textInputFormatter,
          ),

          // Advance Payment Deduction (editable)
          CustomTextField(
            key: ValueKey("ppc_${index}_adv"),
            controller: ppcCntrlr.advancePaymentDeductionCtrl,
            filled: (viewModel.canEdit) ? false : true,
            readOnly: (viewModel.canEdit) ? false : true,
            keyboardType: numType,
            validator: (val) => viewModel.mandatoryNumericIfOther(
              c: ppcCntrlr,
              value: val,
              fieldLabel: "Advance Payment Deduction",
            ),
            onSubmitted: (_) => viewModel.handleSubmitForRow(
              context,
              ppcCntrlr,
              index,
              onAnyFieldChanged,
            ),
            inputFormatters: textInputFormatter,
          ),

          // Retention Deduction (editable)
          CustomTextField(
            key: ValueKey("ppc_${index}_ret"),
            controller: ppcCntrlr.retentionDeductionCtrl,
            filled: (viewModel.canEdit) ? false : true,
            readOnly: (viewModel.canEdit) ? false : true,
            keyboardType: numType,
            validator: (val) => viewModel.mandatoryNumericIfOther(
              c: ppcCntrlr,
              value: val,
              fieldLabel: "Retention Deduction",
            ),
            onSubmitted: (_) => onAnyFieldChanged(),
            inputFormatters: textInputFormatter,
          ),

          // Derived (read-only)
          CustomTextField(
            key: ValueKey("ppc_${index}_netPpc"),
            controller: TextEditingController(text: netPpcDisplay),
            readOnly: true,
            filled: true,
            onSaved: (p0) {},
            inputFormatters: textInputFormatter,
          ),

          // VAT Amount (editable)
          CustomTextField(
            key: ValueKey("ppc_${index}_vat"),
            controller: ppcCntrlr.vatAmountCtrl,
            filled: (viewModel.canEdit) ? false : true,
            readOnly: (viewModel.canEdit) ? false : true,
            keyboardType: numType,
            validator: (val) => viewModel.mandatoryNumericIfOther(
              c: ppcCntrlr,
              value: val,
              fieldLabel: "VAT Amount",
            ),
            onSubmitted: (_) => viewModel.handleSubmitForRow(
              context,
              ppcCntrlr,
              index,
              onAnyFieldChanged,
            ),
            inputFormatters: textInputFormatter,
          ),

          // Other Payment (editable)
          CustomTextField(
            key: ValueKey("ppc_${index}_other"),
            controller: ppcCntrlr.otherPaymentCtrl,
            filled: (viewModel.canEdit) ? false : true,
            readOnly: (viewModel.canEdit) ? false : true,
            keyboardType: numType,
            validator: (val) => viewModel.mandatoryNumericIfOther(
              c: ppcCntrlr,
              value: val,
              fieldLabel: "Other Payment",
            ),
            onSubmitted: (_) => viewModel.handleSubmitForRow(
              context,
              ppcCntrlr,
              index,
              onAnyFieldChanged,
            ),
            inputFormatters: textInputFormatter,
          ),

          // Derived (read-only)
          CustomTextField(
            key: ValueKey("ppc_${index}_netCertVat"),
            controller: TextEditingController(text: netCertPlusVatDisplay),
            readOnly: true,
            filled: true,
            onSaved: (p0) {},
            inputFormatters: textInputFormatter,
          ),

          // Actual Payment Received (editable)
          CustomTextField(
            key: ValueKey("ppc_${index}_actual"),
            controller: ppcCntrlr.actualPaymentReceivedCtrl,
            filled: (viewModel.canEdit) ? false : true,
            readOnly: (viewModel.canEdit) ? false : true,
            keyboardType: numType,
            validator: (val) => viewModel.mandatoryNumericIfOther(
              c: ppcCntrlr,
              value: val,
              fieldLabel: "Actual Payment Received",
            ),
            onSubmitted: (_) => viewModel.handleSubmitForRow(
              context,
              ppcCntrlr,
              index,
              onAnyFieldChanged,
            ),
            inputFormatters: textInputFormatter,
          ),

          // Date Payment Received (editable)
          CustomDatePicker(
            key: ValueKey("ppc_${index}_dateReceived"),
            isEnabled: (viewModel.canEdit) ? true : false,
            initialDateTime: DateTimeUtils.intToDateTime(
              ppcCntrlr.datePaymentReceivedCtrl.text,
            ),
            onSubmit2: (DateTime? dt) {
              ppcCntrlr.datePaymentReceivedCtrl.text =
                  dt == null ? "" : DateFormat("dd/MM/yyyy").format(dt);
              onAnyFieldChanged();
            },
            validator: (val) => viewModel.mandatoryDateIfOther(
              c: ppcCntrlr,
              value: val,
              fieldLabel: "Date Payment Received",
            ),
          ),

          // Delete action
          const SizedBox(),
          // IconButton(
          //   key: ValueKey('ppc_${index}_delete'),
          //   icon: const Icon(Icons.delete, color: Colors.red),
          //   onPressed: () => viewModel.removePpcRow(index),
          // ),
        ];
      }),
    );
  }
}
