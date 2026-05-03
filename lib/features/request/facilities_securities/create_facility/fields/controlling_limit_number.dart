import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class ControllingLimitNumber extends StatelessWidget {
  const ControllingLimitNumber({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool isMainLimit = viewModel.subLimit ?? false;

    return LabelWidget(
      label: "facilities.createFacility.controllingLimitNumber".tr(),
      isRequired: !isMainLimit,
      child: isMainLimit
          // READ-ONLY field for Main Limit
          ? CustomTextField(
              key: ValueKey(
                viewModel.getFacility.controllingLimitNumber ?? "",
              ), // NEW

              maxLength: 8,
              semanticLabel:
                  "facilities.createFacility.controllingLimitNumber".tr(),
              readOnly: true,
              filled: true,
              initialValue: (!viewModel.showCreateFacilityForm &&
                      viewModel.facilityDetail.isNotEmpty)
                  ? (viewModel.facilityDetail.first.controllingLimitNo)
                  : (viewModel.getFacility.controllingLimitNumber ?? ""),
            )
          // DROPDOWN for Sub Limit
          : CustomDropdown<Reference>(
              semanticLabel:
                  "facilities.createFacility.controllingLimitNumber".tr(),
              validationMessage: "common.validation.emptyField".tr(),
              // items: viewModel.controllingLimitNumbers,

              // when list is empty, inject current controlling limit as an item
              items: () {
                final List<Reference> base = viewModel.controllingLimitNumbers;

                final String txt = (viewModel.parentControlliingNumber ??
                        viewModel.getFacility.controllingLimitNumber ??
                        "")
                    .trim();

                if (base.isNotEmpty) return base;

                // If list is empty but we have a value (typical when coming
                // from summary -> add sublimit),
                // provide a single-item list so dropdown doesn't show "No data
                // found"
                return txt.isNotEmpty
                    ? <Reference>[Reference(name: txt)]
                    : <Reference>[];
              }(),

              selectedItems: () {
                final String txt = (viewModel.parentControlliingNumber ??
                        viewModel.getFacility.controllingLimitNumber ??
                        "")
                    .trim();

                if (txt.isEmpty) return <Reference>[];

                // If the value exists in items, use it; otherwise inject a
                // synthetic item to show the text
                final match = viewModel.controllingLimitNumbers.firstWhere(
                  (r) => (r.name ?? "").trim() == txt,
                  orElse: () => Reference(name: txt),
                );
                return [match];
              }(),
              onSelected: (selectedValue) {
                if (selectedValue.isNotEmpty) {
                  viewModel.getFacility.controllingLimitNumber =
                      selectedValue.first.name;
                }
              },
              itemBuilder: (context, item, isDisabled, isSelected) {
                return dropdownMultiItemBuildWidget(
                  item.name,
                  isSelected: isSelected,
                );
              },
              dropdownBuilder: (context, data) {
                return Text(
                  data?.name ?? "",
                  style: const TextStyle(fontSize: 14),
                );
              },
            ),
    );
  }
}
