import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class Tpan extends StatelessWidget {
  const Tpan({required this.viewModel, super.key});
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.tpan".tr(),
          isRequired: false,
          showLabel: true,
          child: CustomRadioButton<Reference>(
            isEnabled: viewModel.canEdit,
            // isEnabled: viewModel.canEdit ? viewModel.viewAccessRolesCheck()
            //       ? true
            //       : false : false,
            itemBuilder: (context, item, isSelected, isEnabled) =>
                Text(item.name ?? ""),
            options: viewModel.getFilteredOptions(viewModel.tpanRequiredItems),
            selectedValue: viewModel.getSelectedReference(
              options: viewModel.tpanRequiredItems,
              selectedValue: viewModel.selectedTpanRequired,
              fallbackFlag: viewModel.applicationDetails?.tpanRequired,
            ),
            validator: (value) => viewModel.validateSelection(
              value?.name,
              viewModel.getFilteredOptions(viewModel.tpanRequiredItems),
              "requestInformation.requestInformation.selectTpan".tr(),
            ),
            onChanged: (selectedRef) {
              viewModel.onTPANTypeSelected(selectedRef);
            },
            selectedColor: AppColors.primary,
            unselectedColor: Colors.grey,
            scrollDirection: Axis.horizontal,
          ),
        ),
      ],
    );
  }
}
