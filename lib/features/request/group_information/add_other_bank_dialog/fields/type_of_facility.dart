import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Type of facility selection field widget.
class TypeOfFacility extends StatelessWidget {
  /// Creates a [TypeOfFacility] widget.
  TypeOfFacility({required this.viewModel, super.key});

  /// View model used by the widget.
  final AddOtherBankDialogViewModel viewModel;

  /// Scroll controller used by the selected facility items.
  final ScrollController contrlr = ScrollController();

  @override
  Widget build(BuildContext context) {
    // Add "Not Disclosed" option
    // final notDisclosedOption = Reference(id: 1, name: 'Not Disclosed');

    // Combine options with "Not Disclosed"
    // final allOptions = [
    //   ...viewModel.typeOfFacilityOptions
    //       .where((e) => (e.name ?? "").trim().isNotEmpty)
    //       .distinctBy((e) => e.name?.trim()),
    //   notDisclosedOption,
    // ];

    return LabelWidget(
      label: "groupInformation.facilitiesWithOtherBanks.typeOfFacility".tr(),
      isRequired: !viewModel.isFiFlow,
      child: CustomMultiSelectDropdown<Reference>(
        key: ValueKey(
          viewModel.currentFacilityItems.facilityWith?.length,
        ),
        semanticLabel:
            "customerInformation.customerInformation.contriesTradedWith".tr(),
        isSearchable: true,
        validationMessage: (viewModel.isFiFlow)
            ? ""
            : "requestInformation.requestInformation.requiredField".tr(),
        // Use the canonical, distinct-by-id list for items
        items: viewModel.typeOfFacilityOptions
            .where((e) => (e.name ?? "").trim().isNotEmpty)
            .distinctBy<int?>((e) => e.id) // generic distinctBy fixed earlier
            .toList(),
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownMultiItemBuildWidget(
            item.name,
            isSelected: isSelected ?? false,
          );
        },
        // search by name (and optionally by id string)
        filterFn: (Reference item, String filter) {
          final name = (item.name ?? item.toString()).toLowerCase();
          final idStr = item.id?.toString() ?? "";
          final q = filter.toLowerCase();
          return name.contains(q) || idStr.contains(q);
        },
        dropdownBuilder: (context, data) {
          final items = data ?? const <Reference>[];
          return multiSelectDropDownBuilderWidget(
            data: items,
            controller: contrlr,
            key: ValueKey(
              viewModel.currentFacilityItems.facilityWith?.length ?? 0,
            ),
            itemBuilder: (index) {
              final ref = items[index];
              // Resolve name by id, fallback to ref.name (keeps your visual
              // logic)
              final label = viewModel.displayNameFromIdOrRef(
                ref: ref,
                options: viewModel.typeOfFacilityOptions,
              );
              return Container(
                margin: const EdgeInsets.all(4),
                child: buildMultiSelectChip(
                  label: buildItemText(
                    label,
                    FontSizeHelper(size: FontSize.small),
                  ),
                  onDeleted: () => viewModel.onSecurityDeleted(index),
                ),
              );
            },
          );
        },
        onSelected: (selected) {
          // keep your delegate
          viewModel.onFacilityTypeSelected(selected);
          // OPTIONAL: If your source of truth is ids, sync them too:
          // final ids = selected.map((r) => r.id).whereType<int>().toList();
          // viewModel.onSecurityTypeSelectedById(ids);
        },

        // Make selectedItems instances match items (by id)
        selectedItems: (() {
          final selected = viewModel.currentFacilityItems.facilityWith ??
              const <Reference>[];
          if (selected.isEmpty) {
            return const <Reference>[];
          }

          final selectedIds =
              selected.map((r) => r.id).whereType<int>().toSet();
          // Rebuild selectedItems from the same 'items' source to align
          // instances
          return viewModel.typeOfFacilityOptions
              .where((opt) => opt.id != null && selectedIds.contains(opt.id))
              .toList();
        })(),

        //CRITICAL FIX: compare logical equality by id
        compareFn: (a, b) => a.id == b.id,

        // keep other props from your component as-is...
      ),
    );
  }
}

/// Provides distinct-key filtering for iterable values.
extension DistinctBy<T> on Iterable<T> {
  /// Returns elements with distinct keys derived from [keySelector].
  /// Works for any key type (int, String, DateTime, etc.), null-safe.
  Iterable<T> distinctBy<K>(K? Function(T) keySelector) {
    final seen = <K?>{};
    return where((element) => seen.add(keySelector(element)));
  }
}
