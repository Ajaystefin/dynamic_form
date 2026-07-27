import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Displays the ESG field on the Request Information screen.
///
/// Allows users to view or manage Environmental, Social, and
/// Governance (ESG) information associated with the current request.
class ESG extends StatelessWidget {
  /// Creates an [ESG].
  const ESG({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages ESG-related operations.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.esg".tr(),
          isRequired: !viewModel.isFI,
          child: CustomRadioButton<Reference>(
            isEnabled: viewModel.canEdit,
            // isEnabled: viewModel.canEdit
            //     ? viewModel.viewAccessRolesCheck()
            //         ? true
            //         : false
            //     : false,
            itemBuilder: (context, item, {bool? isSelected, bool? isEnabled}) =>
                Text(item.name ?? ""),
            options: viewModel.getFilteredOptions(viewModel.esgItems),
            selectedValue: viewModel.getSelectedReference(
              options: viewModel.esgItems,
              selectedValue: viewModel.selectedEsg,
              fallbackFlag: viewModel.applicationDetails?.esgApproval,
            ),
            validator: (viewModel.isFI)
                ? null
                : (value) => viewModel.validateSelection(
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
        ),
      ],
    );
  }
}
