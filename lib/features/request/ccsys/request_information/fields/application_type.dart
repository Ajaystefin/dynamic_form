import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/ccsys/request_information/model.dart';

class ApplicationTypeDropdown extends StatelessWidget {
  final RequestInformationViewModel viewModel;
  const ApplicationTypeDropdown({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'ccsys.requestInformation.applicationType'.tr(),
      isRequired: true,
      child: CustomDropdown(
        isEnabled: false,
        semanticLabel: 'ccsys.requestInformation.applicationType'.tr(),
        selectedItems: [viewModel.applicationTypes.first.name],
        validationMessage: "common.validation.emptyField".tr(),
        items: viewModel.applicationTypes,
        // onSelected: (selectedValue) =>
        //     viewModel.onSelectApplicationType(selectedValue[0]),
      ),
    );
  }
}
