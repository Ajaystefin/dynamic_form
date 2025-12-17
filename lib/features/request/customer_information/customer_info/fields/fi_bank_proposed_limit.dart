import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class FiBankProposedLimit extends StatelessWidget {
  final CustomerInfoViewModel viewModel;
  const FiBankProposedLimit({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label:
            'customerInformation.customerInformation.fiBankProposedLimit'.tr(),
        isRequired: true,
        showLabel: true,
        child: CustomRadioButton<Reference>(
          isEnabled: viewModel.canEdit,
          itemBuilder: (context, item, isSelected, isEnabled) =>
              Text(item.name ?? ''),
          options:
              viewModel.getFilteredOptions(viewModel.fiBankProposedOptions),
          selectedValue: viewModel.getSelectedReference(
            options: viewModel.fiBankProposedOptions,
            selectedValue: viewModel.selectedFiBankProposedValue ??
                viewModel.fiBankProposedOptions.firstWhere(
                  (ref) => ref.id == ServerConstants.yesRefId,
                  orElse: () => viewModel.fiBankProposedOptions.first,
                ),
            fallbackFlag: viewModel.customerInformation?.isLimitWithinPolicy,
          ),
          validator: (value) {
            return (viewModel.showCurrentFiCreditRisk)
                ? null
                : viewModel.validateSelection(
                    value?.name,
                    viewModel
                        .getFilteredOptions(viewModel.fiBankProposedOptions),
                    "customerInformation.customerInformation.selectFiBankProposedLimit"
                        .tr(),
                  );
          },
          onChanged: (selectedRef) {
            viewModel.onFiBankProposedSelected(selectedRef);
          },
          selectedColor: AppColors.primary,
          unselectedColor: Colors.grey,
          scrollDirection: Axis.horizontal,
        ));
  }
}
