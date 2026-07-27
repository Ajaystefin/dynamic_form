import "package:decimal/decimal.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/model.dart";

/// Direct OS field widget.
class DirectOs extends StatelessWidget {
  /// Creates a [DirectOs] widget.
  const DirectOs({required this.viewModel, super.key});

  /// View model used by the widget.
  final AddCbrbDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "groupInformation.facilitiesWithOtherBanks.directOs".tr(),
      label2: "groupInformation.facilitiesWithOtherBanks.inAed".tr(),
      isRequired: !viewModel.isFiFlow,
      child: CustomTextField(
        semanticLabel:
            "groupInformation.facilitiesWithOtherBanks.directOs".tr(),
        initialValue:
            viewModel.currentCbrbItems.directOutstanding?.toString() ?? "",
        validator: (viewModel.isFiFlow)
            ? null
            : viewModel.currentCbrbItems.directOutstanding == null
                ? CustomValidator.requiredField
                : null,
        inputFormatters: [DecimalInputFormatter()],
        // onChanged: (value) {
        //   viewModel.currentCbrbItems.fundedOutstandingAllBanks =
        //       int.tryParse(value);
        // },
        onSaved: (value) {
          viewModel.currentCbrbItems.directOutstanding =
              Decimal.tryParse(value.toString());
        },
      ),
    );
  }
}
