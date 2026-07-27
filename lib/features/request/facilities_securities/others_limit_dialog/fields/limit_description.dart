import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/model.dart";

/// Widget for displaying and capturing the limit description.
class LimitDescription extends StatelessWidget {
  /// Creates a limit description widget.
  const LimitDescription({
    required this.viewModel,
    super.key,
  });

  /// View model containing others limit dialog data and actions.
  final OthersLimitDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "Limit Description",
      isRequired: true,
      child: CustomTextField(
        initialValue: viewModel.reference.name,
        semanticLabel: "admin.referenceDataManagement.referenceDataName".tr(),
        maxLength: 50,
        inputFormatters: viewModel.descriptionFormatters,
        validator: (value) => CustomValidator.requiredField(value ?? ""),
        onSaved: (String? value) {
          viewModel.reference.name = value;
        },
      ),
    );
  }
}
