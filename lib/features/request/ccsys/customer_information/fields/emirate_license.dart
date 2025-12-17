import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class EmirateLicense extends StatelessWidget {
  final CustomerInformationViewModel viewModel;

  const EmirateLicense({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label: 'ccsys.customerInformation.emirateLicense'.tr(),
        isRequired: true,
        child: CustomDropdown<Reference>(
          semanticLabel: 'ccsys.customerInformation.emirateLicense'.tr(),
          items: viewModel.countryCodes,
          isSearchable: true,
          selectedItems: viewModel.isLegalEntityIdentifier
              ? [viewModel.defaultField]
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
          onSelected: (List<Reference> value) =>
              viewModel.customerInformation.emirateLicense = value[0],
        ));
  }
}
