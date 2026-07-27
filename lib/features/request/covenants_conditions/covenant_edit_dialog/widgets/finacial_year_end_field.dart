import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";

/// Financial year end field for the covenant edit dialog.
class FinancialYearEndField extends StatelessWidget {
  /// Creates a financial year end field.
  const FinancialYearEndField({
    required this.viewModel,
    super.key,
    this.isEnabled = true,
    this.row,
  });

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  /// Whether the financial year end field is enabled.
  final bool? isEnabled;

  /// Covenant row data.
  final Covenant? row;

  @override
  Widget build(BuildContext context) {
    final String? financialYearEnd = (row != null)
        ? row!.financialYearEndDate
        : viewModel.covenant?.financialYearEndDate;

    final now = DateTime.now();
    final firstDayOfYear = DateTime(now.year);
    final lastDayOfYear = DateTime(now.year, 12, 31);

    return Column(
      children: [
        LabelWidget(
          label: "covenantsConditions.covenantEditDialog.financialYearEnd".tr(),
          isRequired: viewModel.isRequiredBusinessSegment,
          child: CustomDatePicker(
            key: ValueKey('picker-fye-${financialYearEnd ?? ''}'),
            isEnabled: isEnabled! && !viewModel.isReadOnly,
            dateFormat: "dd/MM",
            initialDateTime:
                viewModel.parseFinancialYearEndDate(financialYearEnd),
            firstDate: firstDayOfYear, // restrict to current year
            lastDate: lastDayOfYear, //  restrict to current year
            semanticLabel:
                "covenantsConditions.covenantEditDialog.financialYearEnd".tr(),
            labelText: (financialYearEnd?.isNotEmpty ?? false)
                ? viewModel.getTimeAsString(financialYearEnd)
                : null,
            onSubmit2: (selectedDate) {},
            onSubmit: (value) {
              if (row == null) {
                viewModel.onFinancialYearEndSubmit(value);
              } else {
                viewModel.onRowFinancialYearEndSubmit(row!, value);
              }
            },
            validator: CustomValidator.financialYearEndValidator,
          ),
        ),
      ],
    );
  }
}
