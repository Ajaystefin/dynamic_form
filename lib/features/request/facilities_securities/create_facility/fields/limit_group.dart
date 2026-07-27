import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing limit group information.
class LimitGroup extends StatelessWidget {
  /// Creates a limit group widget.
  const LimitGroup({required this.viewModel, super.key});

  /// View model containing limit group data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.createFacility.limitGroup".tr(),
      child: CustomDropdown<Reference>(
        semanticLabel: "facilities.createFacility.limitGroup".tr(),
        validationMessage: "validation.emptyField".tr(),
        items: viewModel.isProductTypeIslamic
            ? viewModel.facilityTypes
                .where((e) => (e.reference1 ?? "").trim().toUpperCase() == "I")
                .distinctBy((e) => e.reference4?.trim())
                .toList()
            : viewModel.facilityTypes
                .where((e) => (e.reference1 ?? "").trim().toUpperCase() == "C")
                .distinctBy((e) => e.reference4?.trim())
                .toList(),
        selectedItems: viewModel.getFacility.facilityTypeSelectedValue == null
            ? null
            : [viewModel.getFacility.facilityTypeSelectedValue],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.selectLimittedGroup(selectedValue.first);
          }
        },
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.reference4,
            isSelected: isSelected ?? false,
            isListTile: false,
          );
        },
        dropdownBuilder: (context, data) {
          return Text(
            data?.reference4 ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
      ),
    );
  }
}

/// Extension that provides utility methods for filtering unique items.
extension DistinctBy<T> on Iterable<T> {
  /// Returns distinct elements based on the value returned by [keySelector].
  ///
  /// Only the first occurrence of each key is included in the result.
  Iterable<T> distinctBy(String? Function(T) keySelector) {
    final seen = <String?>{};
    return where((element) => seen.add(keySelector(element)));
  }
}
