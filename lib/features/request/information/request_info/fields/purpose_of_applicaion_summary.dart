import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";

class PurposeOfApplicaionSummary extends StatelessWidget {
  const PurposeOfApplicaionSummary({required this.viewModel, super.key});
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
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LabelWidget(
            isRequired: true,
            showLabel: true,
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
              initialText: viewModel.applicationDetails?.purpose,
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
