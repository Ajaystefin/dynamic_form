import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/features/request/information/request_info/state.dart";

/// Displays the Mark Forward Date field on the Request Information screen.
///
/// Allows users to view or specify the date on which the request
/// is marked for forwarding in the workflow.
class MarkForwardDate extends StatelessWidget {
  /// Creates a [MarkForwardDate].
  const MarkForwardDate({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// View model that provides request information data and
  /// manages mark-forward date-related operations.
  final RequestInfoViewModel viewModel;

  /// Current state of the Request Information screen.
  final RequestInfoState state;

  @override
  Widget build(BuildContext context) {
    final bool isValid = viewModel.canEdit;
    // bool? isValid = viewModel.canEdit
    //     ? viewModel.viewAccessRolesCheck()
    //         ? true
    //         : false
    //     : false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.markForwardDate".tr(),
          isRequired: true,
          child: Builder(
            builder: (_) {
              final now = DateTime.now();
              final nextReviewDate = state.nextReviewDate ?? now;

              // Calculate range
              final DateTime firstDate = nextReviewDate;
              DateTime lastDate =
                  DateTime(nextReviewDate.year, nextReviewDate.month + 4, 0);

              // Ensure firstDate <= lastDate
              if (lastDate.isBefore(firstDate)) {
                lastDate = firstDate;
              }
              DateTime? initialDate;
              if (viewModel.isNewRequest) {
                initialDate = null;
              } else {
                // Show the actual saved value as-is. Do not clamp to the
                // [firstDate, lastDate] window: an out-of-window date is
                // allowed (warning-only), so clamping would display a
                // different date than what is stored/saved.
                initialDate = state.markForwardDate ?? lastDate;
              }
              return CustomDatePicker(
                isEnabled: isValid,
                key: ValueKey(initialDate),
                semanticLabel:
                    "requestInformation.requestInformation.markForwardDate"
                        .tr(),
                initialDateTime: viewModel.isNewRequest ? null : initialDate,
                blockedDates: const [],
                firstDate: firstDate,
                //  lastDate: lastDate,
                onSubmit2: (date) {
                  viewModel.validateAndSetMarkForwardDate(date);
                },
                validator: CustomValidator.date,
              );
            },
          ),
        ),
      ],
    );
  }
}
