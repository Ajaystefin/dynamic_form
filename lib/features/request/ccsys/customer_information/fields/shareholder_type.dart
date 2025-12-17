import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class ShareholderType extends StatelessWidget {
  final CustomerInformationViewModel viewModel;

  const ShareholderType({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'ccsys.customerInformation.shareholderType'.tr(),
      isRequired: true,
      child: CustomDropdown<Reference>(
        semanticLabel: 'ccsys.customerInformation.shareholderType'.tr(),
        items: viewModel.shareholderTypes,
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(item.name);
        },
        dropdownBuilder: (context, data) {
          return dropdownBuilderWidget(
            text: data?.name ?? "",
            showToolTip: false,
          );
        },
        validationMessage: "",
        onSelected: (value) {
          viewModel.customerInformation.shareholderType = value[0];
        },
      ),
    );
  }
}
