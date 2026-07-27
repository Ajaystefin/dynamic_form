import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/ccsys_tooltip.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Displays the legal entity identifier selection field for CCSYS customer information.
class LegalEntityIdentifier extends StatelessWidget {
  /// Creates the legal entity identifier selection widget.
  const LegalEntityIdentifier({
    required this.viewModel,
    super.key,
  });

  /// View model used to manage legal entity identifier selection and edit access.
  final CustomerInformationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // Assumes yesAndNo is a 2-item list: [Yes, No].
    final options = viewModel.getFilteredOptions(
      viewModel.yesNoNaItems.isEmpty
          ? viewModel.radioButtonItems
          : viewModel.yesNoNaItems,
    );
    return CcsysTootltip(
      message:
          "ccsys.customerInformation.tooltip.legalEntityIdentifierTooltip".tr(),
      child: LabelWidget(
        label: "ccsys.customerInformation.legalEntityIdentifier".tr(),
        isRequired: viewModel.canEdit,
        child: CustomRadioButton<Reference>(
          isEnabled: viewModel.canEdit,
          itemBuilder: (context, item, {bool? isSelected, bool? isEnabled}) =>
              Text(item.name ?? ""),
          options: options,
          selectedValue: viewModel.getSelectedReference(
            options: options,
            selectedValue: viewModel.selectedLegalEntityIdentifier,
            fallbackFlag: viewModel.customerInformation.legalEntityIdentifier,
          ),
          validator: (!viewModel.canEdit)
              ? null
              : (value) => viewModel.validateSelection(
                    value?.name,
                    options,
                    "requestInformation.requestInformation.selectTpan".tr(),
                  ),
          onChanged: (selectedRef) {
            viewModel.onChangeisLegalEntityIdentifier(selectedRef);
          },
          selectedColor: AppColors.primary,
          unselectedColor: Colors.grey,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }
}
