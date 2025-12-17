import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class Gender extends StatelessWidget {
  final CustomerInformationViewModel viewModel;

  const Gender({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label: 'ccsys.customerInformation.gender'.tr(),
        isRequired: true,
        child: CustomDropdown<Reference>(
          semanticLabel: 'ccsys.customerInformation.gender'.tr(),
          items: viewModel.genders,
          isSearchable: false,
          itemBuilder: (context, item, isDisabled, isSelected) {
            return dropdownItemBuildWidget(item.name);
          },
          dropdownBuilder: (context, data) {
            return dropdownBuilderWidget(
              text: data?.name ?? "",
              showToolTip: false,
            );
          },
          validationMessage: "common.validation.emptyField".tr(),
          onSelected: (List<Reference> gender) {
            viewModel.customerInformation.gender = gender[0];
          },
        ));
  }
}
