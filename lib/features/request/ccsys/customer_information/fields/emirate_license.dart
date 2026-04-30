import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class EmirateLicense extends StatelessWidget {
  const EmirateLicense({
    required this.viewModel,
    required this.state,
    super.key,
  });
  final CustomerInformationViewModel viewModel;
  final CustomerInformationState state;
  @override
  Widget build(BuildContext context) {
    if (!state.legalEntityIdentifier &&
        viewModel.customerInformation.emiLic == null) {
      viewModel.selectedEmirateLicense = viewModel.defaultField;
      viewModel.customerInformation.emiLic = viewModel.defaultField.name;
    }

    return LabelWidget(
      label: "ccsys.customerInformation.emirateLicense".tr(),
      isRequired: (!viewModel.canEdit) ? false : state.legalEntityIdentifier,
      child: CustomDropdown<Reference>(
        semanticLabel: "ccsys.customerInformation.emirateLicense".tr(),
        items: viewModel.ccsysEmirateList,
        isSearchable: true,
        filterFn: (Reference item, String filter) {
          return (item.name ?? item.toString())
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        isEnabled: (!viewModel.canEdit) ? false : state.legalEntityIdentifier,
        selectedItems: !state.legalEntityIdentifier
            ? [viewModel.defaultField]
            : viewModel.selectedEmirateLicense != null
                ? [viewModel.selectedEmirateLicense]
                : null,
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
          viewModel.customerInformation.emiLic = selectedValue[0].name;
          viewModel.selectedEmirateLicense = selectedValue.first;
        },
      ),
    );
  }
}
