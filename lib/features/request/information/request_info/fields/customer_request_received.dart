import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";

/// Displays the Customer Request Received field on the
/// Request Information screen.
///
/// Allows users to view or specify the date on which the
/// customer's request was received.
class CustomerRequestReceived extends StatelessWidget {
  /// Creates a [CustomerRequestReceived].
  const CustomerRequestReceived({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages customer request receipt details.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.customerRequestReceived"
              .tr(),
          child: CustomDatePicker(
            isEnabled: viewModel.canEdit,
            //  isEnabled: viewModel.canEdit
            //     ? viewModel.viewAccessRolesCheck()
            //         ? true
            //         : false
            //     : false,
            key: const ValueKey("custRequestRecieved"),
            semanticLabel:
                "requestInformation.requestInformation.customerRequestReceived"
                    .tr(),
            initialDateTime: viewModel.isNewRequest
                ? null
                : viewModel.applicationDetails?.custRequestReceived,
            blockedDates: const [],
            onSubmit2: (date) {
              viewModel.applicationDetails?.custRequestReceived = date;
            },
          ),
        ),
      ],
    );
  }
}
