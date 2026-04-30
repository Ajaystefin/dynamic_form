import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";

import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/model.dart";

class Comments extends StatelessWidget {
  const Comments({required this.viewModel, super.key});
  final OthersLimitDialogViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "Comments",
      showLabel: true,
      child: CustomTextField(
        maxLength: 100,
        maxLines: 2,
        initialValue: "This is the new product code",
        semanticLabel:
            "admin.referenceDataManagement.referenceDataDescription".tr(),
        //  validator: CustomValidator.requiredField,
        onSaved: (String? value) {
          viewModel.reference.description = value;
        },
      ),
    );
  }
}
