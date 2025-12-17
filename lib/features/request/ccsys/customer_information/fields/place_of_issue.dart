import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class PlaceOfIssue extends StatelessWidget {
  final CustomerInformationViewModel viewModel;

  const PlaceOfIssue({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label: 'ccsys.customerInformation.placeOfIssue'.tr(),
        isRequired: true,
        child: CustomDropdown<Reference>(
          semanticLabel: 'ccsys.customerInformation.placeOfIssue'.tr(),
          items: viewModel.countryCodes,
          isEnabled: true, //Trade License number =! null
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
          onSelected: (List<Reference> placeOfIssue) {
            viewModel.customerInformation.placeOfIssue = placeOfIssue[0];
          },
        ));
  }
}
