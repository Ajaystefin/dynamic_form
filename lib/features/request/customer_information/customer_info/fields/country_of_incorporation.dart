import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

class CountryOfIncoporationField extends StatelessWidget {
  const CountryOfIncoporationField({required this.viewModel, super.key});
  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final String initialValue =
        viewModel.customerInformation?.incorporateCountry ?? "";
    //final bool isValid = !viewModel.canEdit && initialValue.trim().isNotEmpty;

    return LabelWidget(
      isRequired: (viewModel.isFI) ? false : true,
      showLabel: true,
      label:
          "customerInformation.customerInformation.countryOfIncorporation".tr(),
      child: CustomTextField(
        key: const ValueKey("countryOfIncorporation"),
        semanticLabel:
            "customerInformation.customerInformation.countryOfIncorporation"
                .tr(),
        initialValue: initialValue,
        filled: true,
        fillColor: AppColors.textFieldDisabledFill,
        readOnly: true,
        maxLength: 50,
        onSaved: (value) {
          viewModel.customerInformation?.incorporateCountry = value;
        },
        validator: (value) {
          return (viewModel.isFI) ? null : CustomValidator.requiredField(value);
        },
      ),
    );
  }
}
