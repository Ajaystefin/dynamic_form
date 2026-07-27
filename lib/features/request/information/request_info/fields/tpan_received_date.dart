import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";

/// Displays the TPAN Received Date field on the Request Information screen.
///
/// Allows users to view or specify the date on which the
/// TPAN documentation was received for the current request.
class TPANReceivedDate extends StatelessWidget {
  /// Creates a [TPANReceivedDate].
  const TPANReceivedDate({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages TPAN received date-related operations.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.tpanReceivedDate".tr(),
          child: CustomDatePicker(
            isEnabled: viewModel.canEdit,
            // isEnabled: viewModel.canEdit
            //     ? viewModel.viewAccessRolesCheck()
            //         ? true
            //         : false
            //     : false,

            key: const ValueKey("tpanRecievedDate"),
            initialDateTime: viewModel.isNewRequest
                ? null
                : viewModel.applicationDetails?.tpanRecievedDate,
            blockedDates: const [],
            semanticLabel:
                "requestInformation.requestInformation.tpanReceivedDate".tr(),
            onSubmit2: (date) {
              viewModel.applicationDetails?.tpanRecievedDate = date;
            },
            // validator: CustomValidator.optionalDate,
          ),
        ),
      ],
    );
  }
}
