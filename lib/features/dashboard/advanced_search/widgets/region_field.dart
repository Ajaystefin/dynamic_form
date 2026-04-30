import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class RegionField extends StatelessWidget {
  RegionField({required this.viewModel, super.key, this.width});
  final AdvancedSearchViewModel viewModel;
  final double? width;
  final ScrollController contrlr = ScrollController();
  @override
  Widget build(BuildContext context) {
    Scale.setup(context, const Size(1080, 1));

    return LabelWidget(
      isRequired: true,
      label: "dashboard.advancedSearch.region".tr(),
      child: CustomMultiSelectDropdown<Reference>(
        key: ValueKey(
          viewModel.selectedRegions?.length,
        ),
        semanticLabel: "dashboard.advancedSearch.region".tr(),
        validationMessage: "common.validation.pleaseEnter".tr() +
            "dashboard.advancedSearch.region".tr(),
        items: viewModel.referenceData[ReferenceDataKeys.regionList] ?? [],
        isSearchable: true,
        filterFn: (item, query) =>
            item.name?.toLowerCase().contains(query.toLowerCase()) ?? false,
        itemBuilder: (context, item, isDisabled, isSelected) {
          return ListTile(
            dense: true,
            minVerticalPadding: 0,
            minTileHeight: 34,
            title: Text(
              item.name ?? "",
            ),
          );
        },
        onSelected: (selectedValues) {
          viewModel.selectedRegions = selectedValues;
        },
        dropdownBuilder: (context, data) {
          return SizedBox(
            height: 100,
            child: Scrollbar(
              controller: contrlr,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: contrlr,
                child: Wrap(
                  key: ValueKey(viewModel.selectedRegions?.length),
                  children: List.generate(data!.length, (index) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      child: Chip(
                        onDeleted: () {
                          viewModel.onRegionChipDeleted(index);
                        },
                        label: Text(data[index].name.toString()),
                      ),
                    );
                  }),
                ),
              ),
            ),
          );
        },
        selectedItems: viewModel.selectedRegions,
      ),
    );
  }
}
