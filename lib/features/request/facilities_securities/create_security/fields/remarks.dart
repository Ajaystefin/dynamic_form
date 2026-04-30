import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";

class Remarks extends StatelessWidget {
  const Remarks({required this.viewModel, super.key});
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isEnabled: !viewModel.isCmoUpdate(),
      label: "security.createSecurity.remarks".tr(),
      child: viewModel.isFIFlow && viewModel.remarksController != null
          ? UnifiedTextEditor(
              controller: viewModel.remarksController,
              initialText: viewModel.security.remarks ?? "",
              disable: viewModel.isCmoUpdate(),
              // height: 400,
              editorId:
                  'security_remarks_${viewModel.security.securityId ?? 'new'}',
              scrollController: viewModel.scrollController,
            )
          : CustomTextArea(
              maxLength: 1000,
              initialValue: viewModel.remark,
              readOnly: viewModel.isCmoUpdate(),
              onSaved: (String? value) {
                viewModel.security.remarks = value;
              },
            ),
    );
  }
}
