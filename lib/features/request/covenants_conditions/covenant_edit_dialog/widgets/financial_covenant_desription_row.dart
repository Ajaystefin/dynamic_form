import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";

/// Per-row description. Does NOT use viewModel.financialDescriptionController.
class FinancialCovenantDescriptionRow extends StatelessWidget {
  const FinancialCovenantDescriptionRow({
    required this.viewModel,
    required this.row,
    super.key,
    this.width = double.infinity,
  });

  final CovenantEditDialogViewModel viewModel;
  final Covenant row;
  final double width;

  String _standardTextForRow() {
    final int? subId = row.covenantSubType;
    final String template = viewModel.getDescriptionTemplateForSubtype(subId);
    final String subName =
        (viewModel.findFinancialSubtypeById(row.covenantSubType)?.name ?? "")
            .trim();
    return (subName.isNotEmpty && subId != 11141 && subId != 11142)
        ? "$subName $template"
        : template;
  }

  @override
  Widget build(BuildContext context) {
    final bool isStd = row.isStandard ?? true;
    return SizedBox(
      width: width,
      child: isStd
          ? LabelWidget(
              label: "covenantsConditions.covenantEditDialog.description".tr(),
              child: Text(_standardTextForRow()),
            )
          : CustomTextArea(
              readOnly: !viewModel.canEdit,
              maxLines: 4,
              minLines: 3,
              initialValue: (row.description ?? "").trim(),
              maxLength: 2000,
              validator: CustomValidator.requiredField,
              onChanged: (value) => row.description = value,
            ),
    );
  }
}
