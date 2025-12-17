import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/information/request_info/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class ESG extends StatelessWidget {
  final RequestInfoViewModel viewModel;
  const ESG({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: 'requestInformation.requestInformation.esg'.tr(),
          isRequired: true,
          showLabel: true,
          child: CustomRadioButton<Reference>(
            isEnabled: viewModel.canEdit ? viewModel.viewAccessRolesCheck()
                    ? true
                    : false: false,
            itemBuilder: (context, item, isSelected, isEnabled) =>
                Text(item.name ?? ''),
            options: viewModel.getFilteredOptions(viewModel.esgItems),
            selectedValue: viewModel.getSelectedReference(
              options: viewModel.esgItems,
              selectedValue: viewModel.selectedEsg,
              fallbackFlag: viewModel. applicationDetails?.esgApproval,
            ),
            validator: (value) => viewModel.validateSelection(
              value?.name,
              viewModel.getFilteredOptions(viewModel.esgItems),
              "requestInformation.requestInformation.selectesg".tr(),
            ),
            onChanged: (selectedRef) {
              viewModel.onEsgSelected(selectedRef);
            },
            selectedColor: AppColors.primary,
            unselectedColor: Colors.grey,
            scrollDirection: Axis.horizontal,
          ),
        )
      ],
    );
  }
}
