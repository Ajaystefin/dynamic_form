import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/features/request/information/request_info/state.dart";

/// Displays the Next Review Date field on the Request Information screen.
///
/// Allows users to view or specify the next scheduled review date
/// associated with the current request.
class NextReviewDate extends StatelessWidget {
  /// Creates a [NextReviewDate].
  const NextReviewDate({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// View model that provides request information data and
  /// manages next review date-related operations.
  final RequestInfoViewModel viewModel;

  /// Current state of the Request Information screen.
  final RequestInfoState state;

  @override
  Widget build(BuildContext context) {
    final bool isValid = state.overrideDate ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.nextReviewDate".tr(),
          isRequired: !viewModel.isFI,
          child: CustomDatePicker(
            key: ValueKey(state.nextReviewDate),
            semanticLabel:
                "requestInformation.requestInformation.nextReviewDate".tr(),
            isEnabled: isValid,
            initialDateTime:
                state.nextReviewDate ?? state.defaultNextReviewDate,
            blockedDates: const [],

            lastDate: state.overrideDate ?? false
                ? null
                : state.defaultNextReviewDate,

            firstDate: state.presentReviewDate ?? DateTime.now(),
            // lastDate: state.defaultNextReviewDate ?? DateTime.now(),
            onSubmit2: (date) {
              viewModel.validateAndSetNextReviewDate(date);
            },
            validator: (viewModel.isFI) ? null : CustomValidator.date,
          ),
        ),
      ],
    );
  }
}
