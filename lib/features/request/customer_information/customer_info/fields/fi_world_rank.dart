import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

class FiWorldRank extends StatelessWidget {
  const FiWorldRank({required this.viewModel, super.key});
  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final String initialValue =
        viewModel.customerInformation?.worldRank != null ||
                viewModel.customerInformation?.worldRank.toString() != "null"
            ? viewModel.customerInformation?.worldRank.toString() ?? ""
            : "";
    // final bool isValid = !viewModel.canEdit &&
    // initialValue.trim().isNotEmpty;
    return LabelWidget(
      isRequired: true,
      showLabel: true,
      label: "customerInformation.customerInformation.fiWorldRank".tr(),
      child: CustomTextField(
        key: const ValueKey("fiWorldRank"),
        maxLength: 10,
        semanticLabel:
            "customerInformation.customerInformation.fiWorldRank".tr(),
        validator: (viewModel.isFI) ? CustomValidator.requiredField : null,
        initialValue: initialValue,
        // filled: isValid,
        // readOnly: isValid,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onSaved: (value) {
          viewModel.customerInformation?.worldRank =
              int.tryParse(value.toString());
        },
      ),
    );
  }
}
