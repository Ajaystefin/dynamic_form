import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Displays the Sharia Approval field on the Request Information screen.
///
/// Allows users to view or manage Sharia approval details
/// associated with the current request.
class ShariaApproval extends StatelessWidget {
  /// Creates a [ShariaApproval].
  const ShariaApproval({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages Sharia approval-related operations.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool isValid;
    if (viewModel.isNewRequest) {
      if (Utils.checkApplicationType(ApplicationType.cancellation)) {
        isValid = false;
      } else {
        isValid = true;
      }
    } else {
      if (Utils.checkApplicationType(ApplicationType.cancellation)) {
        isValid = false;
      } else {
        isValid = viewModel.canEdit;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.shariaApproval".tr(),
          child: CustomRadioButton<Reference>(
            isEnabled: isValid,
            itemBuilder: (context, item, {bool? isSelected, bool? isEnabled}) =>
                Text(item.name ?? ""),
            options:
                viewModel.getFilteredOptions(viewModel.shariaApprovalItems),
            selectedValue: viewModel.getSelectedReference(
              options: viewModel.shariaApprovalItems,
              selectedValue: viewModel.selectedShariaApproval,
              fallbackFlag: viewModel.applicationDetails?.shariaApproval,
            ),
            validator: (value) => viewModel.validateSelection(
              value?.name,
              viewModel.getFilteredOptions(viewModel.shariaApprovalItems),
              "requestInformation.requestInformation.selectShariaApproval".tr(),
            ),
            onChanged: (selectedRef) {
              viewModel.onShariaApprovalSelected(selectedRef);
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
