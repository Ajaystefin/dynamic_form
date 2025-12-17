import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart';
import 'package:wcas_frontend/features/request/information/request_info/model.dart';

class PurposeOfApplicaionDetailed extends StatelessWidget {
  const PurposeOfApplicaionDetailed({super.key, required this.viewModel});
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
     bool isValid = viewModel.canEdit
        ? viewModel.viewAccessRolesCheck()
            ? true
            : false
        : false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LabelWidget(
              isRequired: (viewModel.showCurrentFiCreditRisk) ? false : true,
              showLabel: true,
              infoContent:
                  "requestInformation.requestInformation.purposeApplicationHint"
                      .tr(),
              label:
                  "requestInformation.requestInformation.purposeofApplicationDetailed"
                      .tr(),
              child: UnifiedTextEditor(
                scrollController: viewModel.scrollController,
                disable: !isValid,
                characterLimit: 2000,
                initialText: (viewModel.comments ?? []).isNotEmpty
                    ? viewModel.comments?.first.strategyComment ?? ""
                    : "",
                // hintText: (viewModel.comments ?? []).isNotEmpty
                //     ? viewModel.comments?.first.strategyComment ?? ""
                //     : "",
                semanticLabel:
                    "requestInformation.requestInformation.purposeofApplicationDetailed"
                        .tr(),
                controller: viewModel.controllerDetail,
              )),
        ),
      ],
    );
  }
}
