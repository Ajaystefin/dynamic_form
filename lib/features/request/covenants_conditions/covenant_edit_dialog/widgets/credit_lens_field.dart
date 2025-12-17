import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart';

class CreditLensField extends StatelessWidget {
  final String? initialValue;
  final bool isRequired;
  final CovenantEditDialogViewModel viewModel;
  final bool? isEnabled;

  const CreditLensField({
    super.key,
    required this.initialValue,
    required this.viewModel,
    required this.isRequired,
    this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label: "covenantsConditions.covenantEditDialog.creditLensId".tr(),
        showLabel: true,
        isRequired: viewModel.isRequiredBusinessSegment,
        child: CustomTextField(
          controller: viewModel.creditLensController,
          readOnly: !isEnabled!,
          filled: !isEnabled!,
          semanticLabel:
              "covenantsConditions.covenantEditDialog.creditLensId".tr(),
          counterText: "",
          initialValue: viewModel.covenant?.creditLensId,
          onSaved: (value) => viewModel.covenant?.creditLensId = value,
          onChanged: (value) => viewModel.covenant?.creditLensId = value,
          maxLength: 17,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "common.validation.emptyField".tr();
            }
            return null;
          },
        ));
  }
}
