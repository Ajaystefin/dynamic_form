import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/model.dart";

/// Comments field widget.
class Comments extends StatelessWidget {
  /// Creates a [Comments] widget.
  const Comments({required this.viewModel, super.key});

  /// View model used by the widget.
  final AddOtherBankDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "groupInformation.facilitiesWithCBD.comments".tr(),
      child: CustomTextArea(
        semanticLabel: "groupInformation.facilitiesWithCBD.comments".tr(),
        minLines: 4,
        maxLength: 2000,
        initialValue: viewModel.currentFacilityItems.comments,
        onSaved: (String? value) {
          viewModel.currentFacilityItems.comments = value;
        },
      ),
    );
  }
}
