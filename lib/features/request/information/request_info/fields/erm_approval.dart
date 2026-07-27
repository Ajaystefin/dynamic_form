import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Displays the ERM Approval field on the Request Information screen.
///
/// Allows users to view or manage Enterprise Risk Management (ERM)
/// approval details associated with the current request.
class ERMApproval extends StatelessWidget {
  /// Creates an [ERMApproval].
  const ERMApproval({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages ERM approval-related operations.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.ermApproval".tr(),
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
            options: viewModel.getFilteredOptions(viewModel.ermApprovalItems),
            selectedValue: viewModel.getSelectedReference(
              options: viewModel.ermApprovalItems,
              selectedValue: viewModel.selectedErmApproval,
              fallbackFlag: viewModel.applicationDetails?.ermApproval,
            ),
            validator: (viewModel.isFI)
                ? null
                : (value) => viewModel.validateSelection(
                      value?.name,
                      viewModel.getFilteredOptions(viewModel.ermApprovalItems),
                      "requestInformation.requestInformation.selectermApproval"
                          .tr(),
                    ),
            onChanged: (selectedRef) {
              viewModel.onErmApprovalSelected(selectedRef);
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
