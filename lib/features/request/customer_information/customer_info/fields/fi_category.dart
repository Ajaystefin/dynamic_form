import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/model.dart';

class FiCategory extends StatelessWidget {
  const FiCategory({super.key, required this.viewModel});
  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final String initialValue = viewModel.customerInformation?.category ?? "";
    final bool isValid = !viewModel.canEdit && initialValue.trim().isNotEmpty;

    return LabelWidget(
      isRequired: false,
      showLabel: true,
      label: "customerInformation.customerInformation.fiCategory".tr(),
      child: CustomTextField(
        semanticLabel:
            "customerInformation.customerInformation.fiCategory".tr(),
        initialValue: initialValue,
        filled: isValid,
        readOnly: isValid,
        onSaved: (value) {
          viewModel.customerInformation?.category = value;
        },
        hintText:
            "customerInformation.customerInformation.fiCategoryHintText".tr(),
      ),
    );
  }
}
