import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/model.dart";

/// Displays and manages remarks for a guarantor entity.
class GuarantorTextArea extends StatelessWidget {
  /// Creates a guarantor remarks text area.
  const GuarantorTextArea({
    required this.viewModel,
    required this.entityId,
    super.key,
  });

  /// Guarantor financial view model.
  final GuarantorFinancialViewModel viewModel;

  /// Entity identifier associated with the remarks section.
  final int entityId;

  @override
  Widget build(BuildContext context) {
    final bool isStrategyComment =
        viewModel.hasCreditLensData || viewModel.hasSavedAnalysisData;
    return LabelWidget(
      label: "remarks.guarantorFinancials.guarantorFinancialsRatio".tr(),
      labelStyle: AppStyle.tableHeaderStyle,
      child: SizedBox(
        height: 450,
        child: UnifiedTextEditor(
          key: ValueKey("entity-editor-$entityId"),
          scrollController: viewModel.scrollController,
          showVideoUpload: false,
          semanticLabel:
              "remarks.guarantorFinancials.guarantorFinancialsRatio".tr(),
          controller: isStrategyComment
              ? viewModel.remarksEditorForEntity(entityId)
              : viewModel.controller, //
          // initialText: viewModel.remarksForEntity(entityId).isNotEmpty
          //     ? viewModel.remarksForEntity(entityId)
          //     : viewModel.commentData?.strategyComment,
          initialText: isStrategyComment
              ? viewModel.remarksForEntity(entityId)
              : viewModel.commentData?.strategyComment,
          disable: viewModel.isReadOnlyMode,
        ),
      ),
    );
  }
}
