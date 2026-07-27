import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/model.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/state.dart";

/// Customer name field widget.
class CustomerName extends StatelessWidget {
  /// Creates a [CustomerName] widget.
  const CustomerName({required this.viewModel, required this.state, super.key});

  /// View model used by the widget.
  final AddCbrbDialogViewModel viewModel;

  /// State used by the widget.
  final AddCbrbDialogState state;

  @override
  Widget build(BuildContext context) {
    final initialValue =
        (state.customerName == null || state.customerName == "null")
            ? ""
            : state.customerName ?? viewModel.selectedCustomer?.fullName ?? "";
    return LabelWidget(
      label: "groupInformation.facilitiesWithOtherBanks.customerName".tr(),
      isRequired: !viewModel.isFiFlow,
      child: CustomTooltip(
        message: initialValue,
        child: CustomTextField(
          controller: viewModel.customerController,
          semanticLabel:
              "groupInformation.facilitiesWithOtherBanks.customerName".tr(),
          filled: viewModel.isHasRimYes,
          readOnly: viewModel.isHasRimYes,
          validator: !viewModel.isHasRimYes
              ? (value) => value == null || value.isEmpty
                  ? "common.validation.requiredField".tr()
                  : null
              : null,
          initialValue: initialValue,
          onChanged: (value) {
            viewModel.selectedCustomer?.customerName = value;
          },
        ),
      ),
    );
  }
}
