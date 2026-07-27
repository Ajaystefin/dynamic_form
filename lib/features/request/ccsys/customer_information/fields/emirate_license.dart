import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/ccsys_tooltip.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Displays the emirate license dropdown field for CCSYS customer information.
class EmirateLicense extends StatelessWidget {
  /// Creates the emirate license dropdown widget.
  const EmirateLicense({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// View model used to manage emirate license selection and edit access.
  final CustomerInformationViewModel viewModel;

  /// Current customer information state used to control legal entity behavior.
  final CustomerInformationState state;

  @override
  Widget build(BuildContext context) {
    if (!state.legalEntityIdentifier &&
        viewModel.customerInformation.emiLic == null) {
      viewModel.selectedEmirateLicense = viewModel.defaultField;
      viewModel.customerInformation.emiLic = viewModel.defaultField.name;
    }

    return CcsysTootltip(
      message: "ccsys.customerInformation.tooltip.emirateLicenseTooltip".tr(),
      child: LabelWidget(
        label: "ccsys.customerInformation.emirateLicense".tr(),
        isRequired: viewModel.canEdit && state.legalEntityIdentifier,
        child: CustomDropdown<Reference>(
          semanticLabel: "ccsys.customerInformation.emirateLicense".tr(),
          items: viewModel.ccsysEmirateList,
          isEnabled: viewModel.canEdit && state.legalEntityIdentifier,
          isSearchable: true,
          filterFn: (Reference item, String filter) {
            return (item.name ?? item.toString())
                .toLowerCase()
                .contains(filter.toLowerCase());
          },
          selectedItems: !state.legalEntityIdentifier
              ? [viewModel.defaultField]
              : viewModel.selectedEmirateLicense != null
                  ? [viewModel.selectedEmirateLicense]
                  : null,
          validationMessage: "common.validation.emptyField".tr(),
          itemBuilder: (context, item, {isDisabled, isSelected}) {
            return dropdownItemBuildWidget(item.name);
          },
          dropdownBuilder: (context, data) {
            return dropdownBuilderWidget(
              text: data?.name ?? "",
            );
          },
          onSelected: (selectedValue) {
            viewModel.customerInformation.emiLic = selectedValue[0].name;
            viewModel.selectedEmirateLicense = selectedValue.first;
          },
        ),
      ),
    );
  }
}
