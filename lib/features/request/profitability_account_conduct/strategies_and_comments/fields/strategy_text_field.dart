import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_editor_controller.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
// import 'package:wcas_frontend/core/components/textarea.dart';
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/strategies_and_comments/model.dart";

class StrategyTextField extends StatelessWidget {
  const StrategyTextField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    required this.controller,
    required this.scrollController,
    required this.viewModel,
    super.key,
  });
  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final UnifiedEditorController controller;
  final ScrollController scrollController;
  final StrategiesAndCommentsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final double fieldWidth = MediaQuery.of(context).size.width * .8;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(label: label, labelStyle: AppStyle.boldLabel),
        SizedBox(
          width: fieldWidth,
          child: UnifiedTextEditor(
            disable: !viewModel.canEdit,
            characterLimit: 5000,
            editorId: "ultimateOwnership-$label", // must be unique
            initialText: initialValue, // '' after first build
            semanticLabel:
                "profitabilityAccountConduct.strategiesComments.typeHere".tr(),
            controller: controller,
            scrollController: scrollController,
          ),
        ),
        const Gap(size: GapSize.small),
      ],
    );
  }
}
