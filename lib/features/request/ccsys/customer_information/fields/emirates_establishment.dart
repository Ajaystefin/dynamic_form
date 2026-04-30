import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class EmirateEstablishment extends StatelessWidget {
  const EmirateEstablishment({
    required this.viewModel,
    required this.state,
    super.key,
  });
  final CustomerInformationViewModel viewModel;
  final CustomerInformationState state;
  @override
  Widget build(BuildContext context) {
    if (!state.legalEntityIdentifier &&
        viewModel.customerInformation.emiEst == null) {
      viewModel.selectedEmirateEstablishment = viewModel.defaultField;
      viewModel.customerInformation.emiEst = viewModel.defaultField.name;
    }

    return LabelWidget(
      label: "ccsys.customerInformation.emirateEstablishment".tr(),
      isRequired: (!viewModel.canEdit) ? false : state.legalEntityIdentifier,
      child: CustomDropdown<Reference>(
        semanticLabel: "ccsys.customerInformation.emirateEstablishment".tr(),
        isSearchable: true,
        isEnabled: (!viewModel.canEdit) ? false : state.legalEntityIdentifier,
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
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(item.name);
        },
        dropdownBuilder: (context, data) {
          return dropdownBuilderWidget(
            text: data?.name ?? "",
            showToolTip: false,
          );
        },
        onSelected: (selectedValue) {
          viewModel.customerInformation.emiEst = selectedValue[0].name;
          viewModel.selectedEmirateEstablishment = selectedValue.first;
        },
      ),
    );
  }
}
