import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class LimitGroup extends StatelessWidget {
  const LimitGroup({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.createFacility.limitGroup".tr(),
      isRequired: false,
      showLabel: true,
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
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item.reference4,
            isSelected: isSelected,
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

extension DistinctBy<T> on Iterable<T> {
  Iterable<T> distinctBy(String? Function(T) keySelector) {
    final seen = <String?>{};
    return where((element) => seen.add(keySelector(element)));
  }
}
