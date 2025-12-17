import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/features/request/group_information/add_other_bank_dialog/model.dart';

class Comments extends StatelessWidget {
  final AddOtherBankDialogViewModel viewModel;
  const Comments({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "groupInformation.facilitiesWithCBD.comments".tr(),
      child: CustomTextArea(
        semanticLabel:  "groupInformation.facilitiesWithCBD.comments".tr(),
        maxLines: 10,
        minLines: 4,
        initialValue: viewModel.currentFacilityItems.comments,
        onSaved: (String? value) {
          viewModel.currentFacilityItems.comments = value;
        },
      ),
    );
  }
}
