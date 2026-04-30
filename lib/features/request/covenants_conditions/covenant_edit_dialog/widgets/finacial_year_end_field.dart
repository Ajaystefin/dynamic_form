import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";

class FinancialYearEndField extends StatelessWidget {
  const FinancialYearEndField({
    required this.viewModel,
    super.key,
    this.isEnabled = true,
    this.row,
  });
  final CovenantEditDialogViewModel viewModel;
  final bool? isEnabled;
  final Covenant? row;

  @override
  Widget build(BuildContext context) {
    final String? financialYearEnd = (row != null)
        ? row!.financialYearEndDate
        : viewModel.covenant?.financialYearEndDate;

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
