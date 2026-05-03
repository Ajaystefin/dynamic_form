import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";

class CmoRemarks extends StatelessWidget {
  const CmoRemarks({required this.viewModel, super.key});
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    //final bool hasData = viewModel.CmoRemarks?.toString().isNotEmpty ?? false;
    return LabelWidget(
      label: "security.createSecurity.cmoRemarks".tr(),
      isEnabled: viewModel.isCmoUpdate(),
      exponent: "#",
      isRequired: false,
      showLabel: true,
      child: viewModel.isFIFlow && viewModel.cmoRemarksController != null
          ? UnifiedTextEditor(
              controller: viewModel.cmoRemarksController,
              initialText: viewModel.security.cmoRemark ?? "",
              disable: viewModel.isApproved || viewModel.isCmoUpdate(),
              // height: 400,
              editorId: "security_cmo_remarks_"
                  '${viewModel.security.securityId ?? 'new'}',
              scrollController: viewModel.scrollController,
            )
          : CustomTextArea(
              initialValue: viewModel.cmoRemark,
              filled: !viewModel.isCmoUpdate(),
              maxLength: 1000,
              readOnly: !viewModel.isCmoUpdate(),
              onSaved: (String? value) {
                viewModel.security.cmoRemark = value;
              },
            ),
    );
  }
}
