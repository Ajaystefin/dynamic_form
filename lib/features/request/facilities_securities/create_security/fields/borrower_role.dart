import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for selecting and managing the borrower role.
class BorrowerRole extends StatelessWidget {
  /// Creates a borrower role widget.
  const BorrowerRole({
    required this.viewModel,
    super.key,
  });

  /// View model containing borrower role data and actions.
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
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item?.name,
            isSelected: isSelected ?? false,
          );
        },
        filterFn: (Reference? item, String filter) {
          return (item?.name ?? item.toString())
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name),
      ),
    );
  }
}

/// Adds distinct filtering functionality to an iterable.
extension DistinctBy<T> on Iterable<T> {
  /// Returns distinct elements based on the key produced by
  /// [keySelector].
  ///
  /// Only the first occurrence of each unique key is included
  /// in the returned iterable.
  Iterable<T> distinctBy(String? Function(T) keySelector) {
    final seen = <String?>{};
    return where((element) => seen.add(keySelector(element)));
  }
}
