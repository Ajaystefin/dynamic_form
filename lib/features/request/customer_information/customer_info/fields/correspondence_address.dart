import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/model.dart';

class CorrespondenceAddressField extends StatelessWidget {
  const CorrespondenceAddressField({super.key, required this.viewModel});
  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final String initialValue =
        viewModel.customerInformation?.correspondanceAddress ?? "";
    // final bool isValid = !viewModel.canEdit && initialValue.trim().isNotEmpty;

    return LabelWidget(
      isRequired: (viewModel.showCurrentFiCreditRisk) ? false : true,
      showLabel: true,
      label:
          "customerInformation.customerInformation.correspondanceAddress".tr(),
      child: SizedBox(
        height: AppStyle.multiSelectDropdownHeight,
        child: CustomTextArea(
          semanticLabel:
              "customerInformation.customerInformation.correspondanceAddress"
                  .tr(),
          initialValue: initialValue,
          filled: true,
          readOnly: true,
          validator: CustomValidator.requiredField,
          onSaved: (value) {
            viewModel.customerInformation?.correspondanceAddress = value;
          },
        ),
      ),
    );
  }
}
