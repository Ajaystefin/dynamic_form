import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// FI bank proposed limit radio field for the customer information screen.
class FiBankProposedLimit extends StatelessWidget {
  /// Creates an FI bank proposed limit field.
  const FiBankProposedLimit({required this.viewModel, super.key});

  /// Customer information view model.
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "customerInformation.customerInformation.fiBankProposedLimit".tr(),
      isRequired: true,
      child: CustomRadioButton<Reference>(
        key: const ValueKey(
          "customerInformation.customerInformation.fiBankProposedLimit",
        ),
        isEnabled: viewModel.canEdit,
        itemBuilder: (context, item, {bool? isSelected, bool? isEnabled}) =>
            Text(item.name ?? ""),
        options: viewModel.getFilteredOptions(viewModel.fiBankProposedOptions),
        selectedValue: viewModel.getSelectedReference(
          options: viewModel.fiBankProposedOptions,
          selectedValue: viewModel.selectedFiBankProposedValue,
          fallbackFlag: viewModel.customerInformation?.isLimitWithinPolicy,
        ),
        validator: (value) {
          return (!viewModel.isFI)
              ? null
              : viewModel.validateSelection(
                  value?.name,
                  viewModel.getFilteredOptions(viewModel.fiBankProposedOptions),
                  "customerInformation.customerInformation."
                          "selectFiBankProposedLimit"
                      .tr(),
                );
        },
        onChanged: (selectedRef) {
          viewModel.onFiBankProposedSelected(selectedRef);
        },
        selectedColor: AppColors.primary,
        unselectedColor: Colors.grey,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
