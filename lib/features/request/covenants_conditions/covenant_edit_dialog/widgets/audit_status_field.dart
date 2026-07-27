import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Audit status field for the covenant edit dialog.
class AuditStatusField extends StatelessWidget {
  /// Creates an audit status field.
  const AuditStatusField({
    required this.viewModel,
    super.key,
    this.isEnabled = true,
  });

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  /// Whether the audit status dropdown is enabled.
  final bool isEnabled;

  static const int _nonFinancialDefaultAuditStatusId =
      ServerConstants.auditStatusUnqualified; //"name": "Unqualif'd",

  @override
  Widget build(BuildContext context) {
    final List<Reference> items =
        viewModel.referenceData[ReferenceDataKeys.covenantAuditStatus] ??
            const <Reference>[];

    // Try to find the item with referenceDataListId == 11086
    Reference? findNonFinancialDefault() {
      try {
        final int indexByRefListId = items.indexWhere(
          (reference) =>
              (reference.id == _nonFinancialDefaultAuditStatusId) ||
              (reference.id == _nonFinancialDefaultAuditStatusId),
        );
        if (indexByRefListId != -1) {
          return items[indexByRefListId];
        }
      } on Object catch (_) {}

      final int indexById = items
          .indexWhere((ref) => ref.id == _nonFinancialDefaultAuditStatusId);
      return (indexById != -1) ? items[indexById] : null;
    }

    // find which item should appear as selected in the dropdown
    List<Reference> selectedItems() {
      if (viewModel.selectedAuditStatus?.id != null &&
          items.any(
            (reference) => reference.id == viewModel.selectedAuditStatus!.id,
          )) {
        return <Reference>[viewModel.selectedAuditStatus!];
      }

      if (viewModel.selectedCovenantTypeEnum == CovenantType.nonFinancial) {
        final Reference? nonFinDefault = findNonFinancialDefault();
        if (nonFinDefault != null) {
          return <Reference>[nonFinDefault];
        }
      }
      return const <Reference>[];
    }

    return LabelWidget(
      label: "covenantsConditions.covenantEditDialog.auditStatus".tr(),
      isRequired: viewModel.isRequiredBusinessSegment,
      child: CustomDropdown<Reference>(
        hintText: "common.selectValue".tr(),
        isEnabled: isEnabled & !viewModel.isReadOnly,
        semanticLabel:
            "covenantsConditions.covenantEditDialog.auditStatus".tr(),
        validationMessage: "common.validation.emptyField".tr(),
        items: items,
        onSelected: viewModel.onAuditStatusSelected,
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name),
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.name,
            isSelected: isSelected ?? false,
          );
        },
        selectedItems: selectedItems(),
      ),
    );
  }
}
