import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";

/// Displays the CA Date field on the Request Information screen.
///
/// Allows users to view or manage the Credit Approval (CA) date
/// associated with the current request.
class CaDate extends StatelessWidget {
  /// Creates a [CaDate].
  const CaDate({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages CA date-related operations.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // final bool isEditable = viewModel.canEdit;
    // final bool hasCaValue =
    // viewModel.requestInformation.cda?.isNotEmpty ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.caDate".tr(),
          child: CustomTextField(
            filled: true,
            semanticLabel: "requestInformation.requestInformation.caDate".tr(),
            readOnly: true,
            initialValue: viewModel.isNewRequest
                ? DateFormat("dd/MM/yyyy").format(DateTime.now().toLocal())
                : DateFormat("dd/MM/yyyy").format(
                    DateTimeUtils.convertToDate(
                      viewModel.applicationDetails?.cda,
                    ),
                  ),
            onSaved: (String? value) {
              viewModel.applicationDetails?.cda = value;
            },
          ),
        ),
      ],
    );
  }
}
