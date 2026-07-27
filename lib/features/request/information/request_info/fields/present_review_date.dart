import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/features/request/information/request_info/state.dart";

/// Displays the Present Review Date field on the Request Information screen.
///
/// Allows users to view or specify the review date associated
/// with the current request presentation.
class PresentReviewDate extends StatelessWidget {
  /// Creates a [PresentReviewDate].
  const PresentReviewDate({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// View model that provides request information data and
  /// manages review date-related operations.
  final RequestInfoViewModel viewModel;

  /// Current state of the Request Information screen.
  final RequestInfoState state;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDate = now; // Always today onwards
    final lastDate = now.add(const Duration(days: 300));
    DateTime? initialDate;

    // NTB logic
    if (Utils.checkApplicationType(ApplicationType.newToBank)) {
      initialDate = (viewModel.isNewRequest) ? null : state.presentReviewDate;
    }
    // Reconsideration
    else if (Utils.checkApplicationType(ApplicationType.reconsideration)) {
      initialDate = state.presentReviewDate;
    }
    // Existing customers (Annual Review / Amendment / Isolated)
    else {
      initialDate = state.presentReviewDate;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.presentReviewDate".tr(),
          child: CustomDatePicker(
            isEnabled: viewModel.canEditPresentReviewDate(),
            key: ValueKey(initialDate),
            semanticLabel:
                "requestInformation.requestInformation.presentReviewDate".tr(),
            initialDateTime: initialDate,
            blockedDates: const [],
            firstDate: firstDate,
            lastDate: lastDate,
            onSubmit2: (date) {
              viewModel.validateAndSetPresentReviewDate(
                date,
                details: viewModel.applicationDetails,
              );
            },
          ),
        ),
      ],
    );
  }
}
