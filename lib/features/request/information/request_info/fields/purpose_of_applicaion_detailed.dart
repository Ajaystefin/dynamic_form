import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";

/// Displays the Purpose of Application (Detailed) field on the
/// Request Information screen.
///
/// Allows users to provide or review detailed information about
/// the purpose of the current application/request.
class PurposeOfApplicaionDetailed extends StatelessWidget {
  /// Creates a [PurposeOfApplicaionDetailed].
  const PurposeOfApplicaionDetailed({
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
            isRequired: !viewModel.isFI,
            infoContent: (viewModel.isFI)
                ? null
                : "requestInformation.requestInformation.purposeApplicationHint"
                    .tr(),
            label: "requestInformation.requestInformation."
                    "purposeofApplicationDetailed"
                .tr(),
            child: UnifiedTextEditor(
              scrollController: viewModel.scrollController,
              disable: !isValid,
              characterLimit: 2000,
              editorId: "purposeofApplicationDetailed",
              initialText: (viewModel.comments ?? []).isNotEmpty
                  ? viewModel.comments?.first.strategyComment ?? ""
                  : "",
              semanticLabel: "requestInformation.requestInformation."
                      "purposeofApplicationDetailed"
                  .tr(),
              controller: viewModel.controllerDetail,
            ),
          ),
        ),
      ],
    );
  }
}
