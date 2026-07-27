import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Displays the Pricing Committee field on the Request Information screen.
///
/// Allows users to view or manage Pricing Committee-related
/// information associated with the current request.
class PricingCommittee extends StatelessWidget {
  /// Creates a [PricingCommittee].
  const PricingCommittee({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages Pricing Committee-related operations.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.priceCommitte".tr(),
          isRequired: !viewModel.isFI,
          child: CustomRadioButton<Reference>(
            isEnabled: viewModel.canEdit,
            //  isEnabled: viewModel.canEdit
            //     ? viewModel.viewAccessRolesCheck()
            //         ? true
            //         : false
            //     : false,

            itemBuilder: (context, item, {bool? isSelected, bool? isEnabled}) =>
                Text(item.name ?? ""),
            options:
                viewModel.getFilteredOptions(viewModel.pricingCommitteeItems),
            selectedValue: viewModel.getSelectedReference(
              options: viewModel.pricingCommitteeItems,
              selectedValue: viewModel.selectedPricinCommittee,
              fallbackFlag:
                  viewModel.applicationDetails?.pricingCommitteApproval,
            ),
            validator: (value) => viewModel.validateSelection(
              value?.name,
              viewModel.getFilteredOptions(viewModel.pricingCommitteeItems),
              "requestInformation.requestInformation.selectPriceCommitte".tr(),
            ),
            onChanged: (selectedRef) {
              viewModel.onPricingCommitteeSelected(selectedRef);
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
