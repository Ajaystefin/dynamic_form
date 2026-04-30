import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";

import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/model.dart";

class Subtype extends StatelessWidget {
  const Subtype({required this.viewModel, super.key});
  final OthersLimitDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "Sub Type",
      showLabel: true,
      child: CustomTextField(
        initialValue: viewModel.reference.reference5,
        semanticLabel: "admin.referenceDataManagement.referenceDataName".tr(),
        maxLength: 50,
        onSaved: (String? value) {
          viewModel.reference.reference5 = value; // CHANGED
        },
      ),
    );
  }
}
