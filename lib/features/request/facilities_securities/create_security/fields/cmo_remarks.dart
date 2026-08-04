import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";

/// Widget for displaying and managing CMO remarks.
class CmoRemarks extends StatelessWidget {
  /// Creates a CMO remarks widget.
  const CmoRemarks({
    required this.viewModel,
    super.key,
  });

  /// View model containing CMO remarks data and actions.
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    //final bool hasData = viewModel.CmoRemarks?.toString().isNotEmpty ?? false;
    return LabelWidget(
      label: "security.createSecurity.cmoRemarks".tr(),
      isEnabled: viewModel.isCmoUpdate(),
      exponent: "#",
      child: viewModel.isFIFlow && viewModel.cmoRemarksController != null
          ? UnifiedTextEditor(
              ignoreProvider: viewModel.isCmoUpdate(),
              controller: viewModel.cmoRemarksController,
              initialText: viewModel.security.cmoRemarksFi ?? "",
              disable: !viewModel.isCmoUpdate(),
              editorId: "security_cmo_remarks_"
                  '${viewModel.security.securityId ?? 'new'}',
              scrollController: viewModel.scrollController,
            )
          : CustomTextArea(
              ignoreProvider: viewModel.isCmoUpdate(),
              initialValue: viewModel.cmoRemark,
              filled: !viewModel.isCmoUpdate(),
              showMaximumLengthIndicator: false,
              maxLength: 1000,
              readOnly: !viewModel.isCmoUpdate(),
              onSaved: (String? value) {
                viewModel.security.cmoRemark = value;
              },
            ),
    );
  }
}
