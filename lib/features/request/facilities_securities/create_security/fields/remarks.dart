import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";

/// Widget for displaying and managing security remarks.
class Remarks extends StatelessWidget {
  /// Creates a remarks widget.
  const Remarks({
    required this.viewModel,
    super.key,
  });

  /// View model containing security remarks data and actions.
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isEnabled: !viewModel.isCmoUpdate() ||
          Utils.checkApplicationType(
            ApplicationType.cancellation,
          ),
      label: "security.createSecurity.remarks".tr(),
      child: viewModel.isFIFlow && viewModel.remarksController != null
          ? UnifiedTextEditor(
              controller: viewModel.remarksController,
              initialText: viewModel.security.remarksFi ?? "",
              ignoreProvider: Utils.checkApplicationType(
                ApplicationType.cancellation,
              ),
              editorId:
                  'security_remarks_${viewModel.security.securityId ?? 'new'}',
              scrollController: viewModel.scrollController,
            )
          : CustomTextArea(
              maxLength: 1000,
              initialValue: viewModel.remark,
              ignoreProvider: Utils.checkApplicationType(
                ApplicationType.cancellation,
              ),
              onSaved: (String? value) {
                viewModel.security.remarks = value;
              },
            ),
    );
  }
}
