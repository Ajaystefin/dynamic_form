import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";

/// Displays the Purpose of Application (Summary) field on the
/// Request Information screen.
///
/// Allows users to provide or review a summarized description
/// of the purpose of the current application/request.
class PurposeOfApplicaionSummary extends StatelessWidget {
  /// Creates a [PurposeOfApplicaionSummary].
  const PurposeOfApplicaionSummary({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages application purpose-related operations.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool isValid = viewModel.canEdit;
    //  bool isValid = viewModel.canEdit
    //     ? viewModel.viewAccessRolesCheck()
    //         ? true
    //         : false
    //     : false;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LabelWidget(
            isRequired: true,
            infoContent: (viewModel.isFI)
                ? null
                : "requestInformation.requestInformation."
                        "purposeofApplicationSummaryHint"
                    .tr(),
            label: "requestInformation.requestInformation."
                    "purposeofApplicationSummary"
                .tr(),
            child: UnifiedTextEditor(
              scrollController: viewModel.scrollController,
              disable: !isValid,
              characterLimit: 2000,
              editorId: "purposeofApplicationSummary",
              initialText: (viewModel.isNewRequest &&
                      !Utils.checkApplicationType(ApplicationType.newToBank))
                  ? ""
                  : viewModel.applicationDetails?.purpose,
              controller: viewModel.controllerPurpose,
              semanticLabel: "requestInformation.requestInformation."
                      "purposeofApplicationSummary"
                  .tr(),
            ),
          ),
        ),
      ],
    );
  }
}
