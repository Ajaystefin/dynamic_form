import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/model.dart";

/// Number of banks field widget.
class NoOfBanks extends StatelessWidget {
  /// Creates a [NoOfBanks] widget.
  const NoOfBanks({required this.viewModel, super.key});

  /// View model used by the widget.
  final AddCbrbDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "groupInformation.facilitiesWithOtherBanks.numberofBanks".tr(),
      isRequired: !viewModel.isFiFlow,
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
