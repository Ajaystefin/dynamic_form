import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/information/request_info/model.dart';

class Region extends StatelessWidget {
  final RequestInfoViewModel viewModel;
  const Region({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // final bool isEditable = viewModel.canEdit;
    // final bool hasCaValue =
    // viewModel.requestInformation.region?.isNotEmpty ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: 'requestInformation.requestInformation.region'.tr(),
          isRequired: false,
          showLabel: true,
          child: CustomTextField(
            filled: true,
            semanticLabel: 'requestInformation.requestInformation.region'.tr(),
            readOnly: true,
            initialValue: viewModel.applicationDetails?.region ?? "Jumeirah" ,
            onSaved: (String? value) {
              viewModel. applicationDetails?.region = value;
            },
          ),
        )
      ],
    );
  }
}
