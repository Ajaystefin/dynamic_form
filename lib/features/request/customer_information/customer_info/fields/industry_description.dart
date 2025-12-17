import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/model.dart';

class IndustryDescriptionField extends StatelessWidget {
  const IndustryDescriptionField({super.key, required this.viewModel});

  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "customerInformation.customerInformation.industryDescription".tr(),
      child: CustomTextField(
        semanticLabel:
            "customerInformation.customerInformation.industryDescription".tr(),
        key: ValueKey(viewModel.selectedProposedSicCode?.description),
        initialValue: viewModel.customerInformation?.industryDescription,
        hintText: viewModel.customerInformation?.industryDescription,
        maxLength: 50,
        filled: false,
        readOnly: false,
        onSaved: (value) {
          viewModel.customerInformation?.industryDescription = value;
        },
      ),
    );
  }
}
