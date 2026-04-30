import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/model.dart";

class LimitDescription extends StatelessWidget {
  const LimitDescription({required this.viewModel, super.key});
  final OthersLimitDialogViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "Limit Description",
      isRequired: true,
      showLabel: true,
      child: CustomTextField(
        initialValue: viewModel.reference.name,
        semanticLabel: "admin.referenceDataManagement.referenceDataName".tr(),
        maxLength: 50,
        inputFormatters: viewModel.descriptionFormatters,
        validator: !(viewModel.reference.name?.isNotEmpty ?? false)
            ? CustomValidator.requiredField
            : null,
        onSaved: (String? value) {
          viewModel.reference.name = value;
        },
      ),
    );
  }
}
