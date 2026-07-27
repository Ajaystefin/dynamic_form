import "package:decimal/decimal.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/model.dart";

/// Indirect OS field widget.
class IndirectOs extends StatelessWidget {
  /// Creates an [IndirectOs] widget.
  const IndirectOs({required this.viewModel, super.key});

  /// View model used by the widget.
  final AddCbrbDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "groupInformation.facilitiesWithOtherBanks.indirectOs".tr(),
      label2: "groupInformation.facilitiesWithOtherBanks.inAed".tr(),
      isRequired: !viewModel.isFiFlow,
      child: CustomTextField(
        semanticLabel:
            "groupInformation.facilitiesWithOtherBanks.indirectOs".tr(),
        initialValue:
            viewModel.currentCbrbItems.indirectOutstanding?.toString() ?? "",
        validator: (viewModel.isFiFlow)
            ? null
            : viewModel.currentCbrbItems.indirectOutstanding == null
                ? CustomValidator.requiredField
                : null,
        inputFormatters: [DecimalInputFormatter()],
        // onChanged: (value) {
        //   viewModel.currentCbrbItems.nonFundedOutstandingAllBanks =
        //       int.tryParse(value);
        // },
        onSaved: (value) {
          viewModel.currentCbrbItems.indirectOutstanding =
              Decimal.tryParse(value.toString());
        },
      ),
    );
  }
}
