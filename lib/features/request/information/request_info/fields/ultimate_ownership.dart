import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart';
// import 'package:wcas_frontend/core/components/text_editor.dart';
import 'package:wcas_frontend/features/request/information/request_info/model.dart';

class UltimateOwnership extends StatelessWidget {
  const UltimateOwnership({super.key, required this.viewModel});
  final RequestInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    bool isValid = viewModel.canEdit
        ? viewModel.viewAccessRolesCheck()
            ? true
            : false
        : false;
    return LabelWidget(
        label: 'requestInformation.requestInformation.ultimateOwnership'.tr(),
        showLabel: true,
        isRequired: true,
        child: UnifiedTextEditor(
          scrollController: viewModel.scrollController,
          disable: !isValid,
          characterLimit: 1000,
          initialText: viewModel.applicationDetails?.ultimateOwnership,
          // hintText: viewModel.applicationDetails?.ultimateOwnership ?? '',
          semanticLabel:
              "requestInformation.requestInformation.ultimateOwnership".tr(),
          controller: viewModel.controllerUltimate,
        )
        //   onSaved: (String? value) {
        //     viewModel.requestInformation.ultimateOwnership = value ?? "";
        //   },
        );
  }
}
