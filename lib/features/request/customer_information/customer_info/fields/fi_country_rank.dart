import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/model.dart';

class FiCountryRank extends StatelessWidget {
  const FiCountryRank({super.key, required this.viewModel});
  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final String initialValue =
        viewModel.customerInformation?.countryRank.toString() ?? "";
    final bool isValid = !viewModel.canEdit && initialValue.trim().isNotEmpty;

    return LabelWidget(
      isRequired: true,
      showLabel: true,
      label: "customerInformation.customerInformation.fiCountryRank".tr(),
      child: CustomTextField(
        semanticLabel: "customerInformation.customerInformation.fiCountryRank".tr(),
        validator: (viewModel.showCurrentFiCreditRisk)
            ? CustomValidator.requiredField
            : null,
        initialValue: initialValue,
        filled: isValid,
        readOnly: isValid,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onSaved: (value) {
          viewModel.customerInformation?.countryRank =
              int.tryParse(value.toString());
        },
      ),
    );
  }
}
