import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart';

class FinancialYearEndField extends StatelessWidget {
  const FinancialYearEndField({
    super.key,
    required this.viewModel,
    this.isEnabled = true,
  });
  final CovenantEditDialogViewModel viewModel;
  final bool? isEnabled;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LabelWidget(
          label: 'covenantsConditions.covenantEditDialog.financialYearEnd'.tr(),
          isRequired: viewModel.isRequiredBusinessSegment,
          child: CustomDatePicker(
            isEnabled: isEnabled! && !viewModel.isReadOnly,
            dateFormat: 'dd/MM',
            initialDateTime: viewModel.parseFinancialYearEndDate(
                viewModel.covenant?.financialYearEndDate),
            semanticLabel:
                'covenantsConditions.covenantEditDialog.financialYearEnd'.tr(),
            labelText: viewModel.isUpdateCovenant()
                ? viewModel
                    .getTimeAsString(viewModel.covenant?.financialYearEndDate)
                : null,
            onSubmit2: (selectedDate) {},
            onSubmit: (value) {
              viewModel.onFinancialYearEndSubmit(value);
            },
            // validator: CustomValidator.date,
             validator: CustomValidator.financialYearEndValidator, // <-- local validato

          ),
        ),
      ],
    );
  }
}
