import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Displays the Interim Review Date Required field on the
/// Request Information screen.
///
/// Allows users to indicate whether an interim review date
/// is required for the current request.
class InterimReviewDateRequired extends StatelessWidget {
  /// Creates an [InterimReviewDateRequired].
  const InterimReviewDateRequired({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages interim review date requirement details.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label:
              "requestInformation.requestInformation.interimReviewDateRequired"
                  .tr(),
          child: CustomRadioButton<Reference>(
            isEnabled: viewModel.canEdit,
            // isEnabled: viewModel.canEdit
            //     ? viewModel.viewAccessRolesCheck()
            //         ? true
            //         : false
            //     : false,
            itemBuilder: (context, item, {bool? isSelected, bool? isEnabled}) =>
                Text(item.name ?? ""),
            options: viewModel
                .getFilteredOptions(viewModel.interimReviewDateRequiredItems),
            selectedValue: viewModel.getSelectedReference(
              options: viewModel.interimReviewDateRequiredItems,
              selectedValue: viewModel.selectedInterimReviewDateRequired,
              fallbackFlag:
                  viewModel.applicationDetails?.interimReviewDateRequired,
            ),
            validator: (viewModel.isFI)
                ? null
                : (value) => viewModel.validateSelection(
                      value?.name,
                      viewModel.getFilteredOptions(
                        viewModel.interimReviewDateRequiredItems,
                      ),
                      "requestInformation.requestInformation."
                              "selectInterimReviewDateRequired"
                          .tr(),
                    ),
            onChanged: (selectedRef) {
              viewModel.onInterimReviewDateRequiredSelected(selectedRef);
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
