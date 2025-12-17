import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/constants/_reference_data_keys.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class CccStatusField extends StatelessWidget {
  const CccStatusField({super.key, required this.viewModel});
  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: (viewModel.showCurrentFiCreditRisk) ? false : true,
      label: "customerInformation.customerInformation.cccStatus".tr(),
      child: CustomDropdown<Reference>(
        isEnabled: false,
        semanticLabel: "customerInformation.customerInformation.cccStatus".tr(),
        validationMessage: "common.validation.emptyField".tr(),
        items: viewModel.referenceData[ReferenceDataKeys.cccStatus] ?? [],
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(item.name);
        },
        onSelected: (selectedValue) {
          viewModel.customerInformation?.cccStatus = selectedValue[0].name;
          viewModel.selectedCccStatus = selectedValue.first;
        },
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name, showToolTip: false),
        selectedItems: viewModel.selectedCccStatus != null
            ? [viewModel.selectedCccStatus!]
            : null,
      ),
    );
  }
}
