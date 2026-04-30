import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/model.dart";

class NoOfBanks extends StatelessWidget {
  const NoOfBanks({required this.viewModel, super.key});
  final AddCbrbDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "groupInformation.facilitiesWithOtherBanks.numberofBanks".tr(),
      isRequired: (viewModel.isFiFlow) ? false : true,
      showLabel: true,
      child: CustomTextField(
        semanticLabel:
            "groupInformation.facilitiesWithOtherBanks.numberofBanks".tr(),
        initialValue: viewModel.currentCbrbItems.noOfBanks?.toString() ?? "",
        hintText: viewModel.currentCbrbItems.noOfBanks?.toString() ?? "",
        maxLength: 5,
        validator: (viewModel.isFiFlow)
            ? null
            : viewModel.currentCbrbItems.noOfBanks == null
                ? CustomValidator.requiredField
                : null,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          viewModel.currentCbrbItems.noOfBanks = int.tryParse(value);
        },
        onSaved: (value) {
          viewModel.currentCbrbItems.noOfBanks = int.tryParse(value.toString());
        },
      ),
    );
  }
}
