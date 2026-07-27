import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/ccsys_tooltip.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Displays the emirate establishment dropdown field for CCSYS customer information.
class EmirateEstablishment extends StatelessWidget {
  /// Creates the emirate establishment dropdown widget.
  const EmirateEstablishment({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// View model used to manage emirate establishment selection and edit access.
  final CustomerInformationViewModel viewModel;

  /// Current customer information state used to control legal entity behavior.
  final CustomerInformationState state;

  @override
  Widget build(BuildContext context) {
    if (!state.legalEntityIdentifier &&
        viewModel.customerInformation.emiEst == null) {
      viewModel.selectedEmirateEstablishment = viewModel.defaultField;
      viewModel.customerInformation.emiEst = viewModel.defaultField.name;
    }

    return CcsysTootltip(
      message:
          "ccsys.customerInformation.tooltip.emirateEstablishmentTooltip".tr(),
      child: LabelWidget(
        label: "ccsys.customerInformation.emirateEstablishment".tr(),
        isRequired: viewModel.canEdit && state.legalEntityIdentifier,
        child: CustomDropdown<Reference>(
          semanticLabel: "ccsys.customerInformation.emirateEstablishment".tr(),
          isSearchable: true,
          isEnabled: viewModel.canEdit && state.legalEntityIdentifier,
          filterFn: (Reference item, String filter) {
            return (item.name ?? item.toString())
                .toLowerCase()
                .contains(filter.toLowerCase());
          },
          selectedItems: !state.legalEntityIdentifier
              ? [viewModel.defaultField]
              : viewModel.selectedEmirateEstablishment != null
                  ? [viewModel.selectedEmirateEstablishment]
                  : null,
          items: viewModel.ccsysEmirateList,
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
            viewModel.customerInformation.emiEst = selectedValue[0].name;
            viewModel.selectedEmirateEstablishment = selectedValue.first;
          },
        ),
      ),
    );
  }
}
