import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart'; 
import 'package:wcas_frontend/features/request/information/request_info/model.dart';

class MainBranch extends StatelessWidget {
  final RequestInfoViewModel viewModel;
  const MainBranch({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // final bool isEditable = viewModel.canEdit;
    // final bool hasBranchValue =
    // viewModel.requestInformation.branch?.isNotEmpty ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
            label: 'requestInformation.requestInformation.mainBranch'.tr(),
            isRequired: false,
            showLabel: true,
            child: CustomTextField(
              filled: true,
              semanticLabel:
                  'requestInformation.requestInformation.mainBranch'.tr(),
              readOnly: true,
              initialValue: viewModel.applicationDetails?.branch ?? "Al Qouz Branch",
              onSaved: (String? value) {
                viewModel. applicationDetails?.branch = value;
              },
            ))
      ],
    );
  }
}
