import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class NationalityPartner extends StatelessWidget {
  final CustomerInformationViewModel viewModel;

  const NationalityPartner({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label: 'ccsys.customerInformation.NationalityPartner'.tr(),
        isRequired: viewModel.customerInformation.legalStatusPartners ==
            viewModel
                .legalStatusPartners[0], //-	Mandatory only if Legal Status = JP
        child: CustomDropdown<Reference>(
          semanticLabel: 'ccsys.customerInformation.NationalityPartner'.tr(),
          items: viewModel.countryCodes,
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
          onSelected: (List<Reference> nationalityPartner) => viewModel
            ..customerInformation.nationalityPartner = nationalityPartner[0],
        ));
  }
}
