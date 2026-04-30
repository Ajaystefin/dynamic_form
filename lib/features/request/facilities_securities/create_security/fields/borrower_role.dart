import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class BorrowerRole extends StatelessWidget {
  const BorrowerRole({required this.viewModel, super.key});
  final CreateSecurityViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "security.createSecurity.borrowerRole".tr(),
      isRequired: !viewModel.isFIFlow,
      child: CustomDropdown<Reference?>(
        isSearchable: true,
        isEnabled: !viewModel.isCmoUpdate(),
        validationMessage: !viewModel.isFIFlow
            ? "common.validation.emptyRequiredField".tr()
            : null,
        items: viewModel.securityBorrowerRole
            .where((e) => (e.name ?? "").trim().isNotEmpty)
            .distinctBy((e) => e.name?.trim())
            .toList(),
        selectedItems: [viewModel.security.borrowerRole],
        onSelected: (selectedValue) {
          viewModel.security.borrowerRole = selectedValue.first;
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item?.name,
            isListTile: true,
            isSelected: isSelected,
          );
        },
        filterFn: (Reference? item, String filter) {
          return (item?.name ?? item.toString())
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name, showToolTip: false),
      ),
    );
  }
}

extension DistinctBy<T> on Iterable<T> {
  Iterable<T> distinctBy(String? Function(T) keySelector) {
    final seen = <String?>{};
    return where((element) => seen.add(keySelector(element)));
  }
}
