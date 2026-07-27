import "package:decimal/decimal.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/model.dart";

/// Indirect limits field widget.
class IndirectLimits extends StatelessWidget {
  /// Creates an [IndirectLimits] widget.
  const IndirectLimits({required this.viewModel, super.key});

  /// View model used by the widget.
  final AddCbrbDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "groupInformation.facilitiesWithOtherBanks.indirectLimits".tr(),
      label2: "groupInformation.facilitiesWithOtherBanks.inAed".tr(),
      isRequired: !viewModel.isFiFlow,
      child: CustomTextField(
        semanticLabel:
            "groupInformation.facilitiesWithOtherBanks.indirectLimits".tr(),
        initialValue:
            viewModel.currentCbrbItems.indirectLimit?.toString() ?? "",
        validator: (viewModel.isFiFlow)
            ? null
            : viewModel.currentCbrbItems.indirectLimit == null
                ? CustomValidator.requiredField
                : null,
        inputFormatters: [DecimalInputFormatter()],
        // onChanged: (value) {
        //   viewModel.currentCbrbItems.nonFundedLimitAllBanks =
        //       int.tryParse(value);
        // },
        onSaved: (value) {
          viewModel.currentCbrbItems.indirectLimit =
              Decimal.tryParse(value.toString());
        },
      ),
    );
  }
}
