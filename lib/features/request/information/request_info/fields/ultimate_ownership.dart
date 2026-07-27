import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";

/// Displays the Ultimate Ownership field on the Request Information screen.
///
/// Allows users to view or manage ultimate ownership information
/// associated with the current request.
class UltimateOwnership extends StatelessWidget {
  /// Creates an [UltimateOwnership].
  const UltimateOwnership({
    required this.viewModel,
    super.key,
  });

  /// View model that provides request information data and
  /// manages ultimate ownership-related operations.
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool isValid = viewModel.canEdit;
    // bool isValid = viewModel.canEdit
    //     ? viewModel.viewAccessRolesCheck()
    //         ? true
    //         : false
    //     : false;
    return LabelWidget(
      label: "requestInformation.requestInformation.ultimateOwnership".tr(),
      isRequired: !viewModel.isFI,
      child: UnifiedTextEditor(
        scrollController: viewModel.scrollController,
        disable: !isValid,
        characterLimit: 1000,
        editorId: "ultimateOwnership",
        initialText: viewModel.applicationDetails?.ultimateOwnership,
        // hintText: viewModel.applicationDetails?.ultimateOwnership ?? '',
        semanticLabel:
            "requestInformation.requestInformation.ultimateOwnership".tr(),
        controller: viewModel.controllerUltimate,
      ),
      //   onSaved: (String? value) {
      //     viewModel.requestInformation.ultimateOwnership = value ?? "";
      //   },
    );
  }
}
