import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";

/// Displays the Main Branch field on the Request Information screen.
///
/// Allows users to view or select the main branch associated
/// with the current request.
class MainBranch extends StatelessWidget {
  /// Creates a [MainBranch].
  const MainBranch({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages main branch-related operations.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // final bool isEditable = viewModel.canEdit;
    // final bool hasBranchValue =
    // viewModel.requestInformation.branch?.isNotEmpty ?? false;
    final bool isEditable = viewModel.isManualEntry;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "requestInformation.requestInformation.mainBranch".tr(),
          child: CustomTextField(
            filled: !isEditable,
            semanticLabel:
                "requestInformation.requestInformation.mainBranch".tr(),
            readOnly: !isEditable,
            initialValue:
                viewModel.applicationDetails?.branch ?? "Al Qouz Branch",
            onSaved: (String? value) {
              viewModel.applicationDetails?.branch = value;
            },
          ),
        ),
      ],
    );
  }
}
