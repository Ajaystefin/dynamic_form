import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart";

/// GroupCorporateStructure stateless widget
class GroupCorporateStructure extends StatelessWidget {
  /// Creates [GroupCorporateStructure] instance
  const GroupCorporateStructure({required this.viewModel, super.key});

  /// AppendixViewModel view model to handle actions
  final AppendixViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label:
          "eDigitalFilingFileAttachments.appendix.groupCorporateStructure".tr(),
      child: UnifiedTextEditor(
        key: ValueKey("editor-${viewModel.groupCorporateStructureEditorId}"),
        editorId:
            "rich-text-editor-${viewModel.groupCorporateStructureEditorId}",
        scrollController: viewModel.scrollController,
        showVideoUpload: false,
        disable: viewModel.isAppendixReadOnly,
        // semanticLabel: TabConstants.remarksTitles[tab]!.tr(),
        controller: viewModel.gcsController,
        initialText: viewModel.appendix.groupCorporateStructure,
        characterLimit: 5000,
        // disable: viewModel.isReadOnlyMode,
      ),
    );
  }
}
