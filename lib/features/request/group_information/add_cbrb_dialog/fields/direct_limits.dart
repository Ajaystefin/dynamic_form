import "package:decimal/decimal.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/model.dart";

/// Direct limits field widget.
class DirectLimits extends StatelessWidget {
  /// Creates a [DirectLimits] widget.
  const DirectLimits({required this.viewModel, super.key});

  /// View model used by the widget.
  final AddCbrbDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "groupInformation.facilitiesWithOtherBanks.directLimits".tr(),
      label2: "groupInformation.facilitiesWithOtherBanks.inAed".tr(),
      isRequired: !viewModel.isFiFlow,
      child: CustomTextField(
        semanticLabel:
            "groupInformation.facilitiesWithOtherBanks.directLimits".tr(),
        initialValue: viewModel.currentCbrbItems.directLimit?.toString() ?? "",
        validator: (viewModel.isFiFlow)
            ? null
            : viewModel.currentCbrbItems.directLimit == null
                ? CustomValidator.requiredField
                : null,
        inputFormatters: [DecimalInputFormatter()],
        // onChanged: (value) {
        //   viewModel.currentCbrbItems.fundedLimitAllBanks =
        // int.tryParse(value);
        // },
        onSaved: (value) {
          viewModel.currentCbrbItems.directLimit =
              Decimal.tryParse(value.toString());
        },
      ),
    );
  }
}
