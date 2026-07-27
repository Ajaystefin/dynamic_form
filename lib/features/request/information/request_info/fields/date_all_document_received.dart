import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";

/// Displays the Date All Documents Received field on the
/// Request Information screen.
///
/// Allows users to view or specify the date on which all
/// required supporting documents were received for the request.
class DateAllDocumentReceived extends StatelessWidget {
  /// Creates a [DateAllDocumentReceived].
  const DateAllDocumentReceived({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages document receipt-related operations.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.dateAllDocumentReceived"
              .tr(),
          child: CustomDatePicker(
            isEnabled: viewModel.canEdit,
            //  isEnabled: viewModel.canEdit
            //     ? viewModel.viewAccessRolesCheck()
            //         ? true
            //         : false
            //     : false,
            key: const ValueKey("dateAllDocumentReceived"),
            semanticLabel:
                "requestInformation.requestInformation.dateAllDocumentReceived"
                    .tr(),
            initialDateTime: viewModel.isNewRequest
                ? null
                : viewModel.applicationDetails?.dateAllDocumentReceived,
            blockedDates: const [],
            onSubmit2: (DateTime? date) {
              viewModel.applicationDetails?.dateAllDocumentReceived = date;
            },
          ),
        ),
      ],
    );
  }
}
