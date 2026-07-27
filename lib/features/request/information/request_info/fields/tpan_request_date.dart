import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";

/// Displays the TPAN Request Date field on the Request Information screen.
///
/// Allows users to view or specify the date on which the
/// TPAN request was initiated for the current request.
class TPANRequestDate extends StatelessWidget {
  /// Creates a [TPANRequestDate].
  const TPANRequestDate({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages TPAN request date-related operations.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.tpanRequestDate".tr(),
          child: CustomDatePicker(
            isEnabled: viewModel.canEdit,
            //  isEnabled: viewModel.canEdit
            //     ? viewModel.viewAccessRolesCheck()
            //         ? true
            //         : false
            //     : false,
            key: const ValueKey("tpanRequestDate"),
            semanticLabel:
                "requestInformation.requestInformation.tpanRequestDate".tr(),
            initialDateTime: viewModel.isNewRequest
                ? null
                : viewModel.applicationDetails?.tpanRequestDate,
            blockedDates: const [],
            onSubmit2: (date) {
              viewModel.applicationDetails?.tpanRequestDate = date;
            },
            // validator: CustomValidator.date,
          ),
        ),
      ],
    );
  }
}
