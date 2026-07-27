import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";

/// Displays the Region field on the Request Information screen.
///
/// Allows users to view the region associated with the current
/// request or customer information.
class Region extends StatelessWidget {
  /// Creates a [Region].
  const Region({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages region-related operations.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // final bool isEditable = viewModel.canEdit;
    // final bool hasCaValue =
    // viewModel.requestInformation.region?.isNotEmpty ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.region".tr(),
          child: CustomTextField(
            filled: true,
            semanticLabel: "requestInformation.requestInformation.region".tr(),
            readOnly: true,
            initialValue: viewModel.applicationDetails?.region ?? "Jumeirah",
            onSaved: (String? value) {
              viewModel.applicationDetails?.region = value;
            },
          ),
        ),
      ],
    );
  }
}
