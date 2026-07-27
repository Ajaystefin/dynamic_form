import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Multi-select field for selecting role IDs.
class RoleIdField extends StatelessWidget {
  /// Creates a [RoleIdField].
  RoleIdField({
    required this.viewModel,
    super.key,
    this.width,
  });

  /// View model used to manage advanced search values.
  final AdvancedSearchViewModel viewModel;

  /// Optional width for the field.
  final double? width;

  /// Scroll controller used for the selected role chips area.
  final ScrollController contrlr = ScrollController();

  @override
  Widget build(BuildContext context) {
    Scale.setup(context, const Size(1080, 1));
    return LabelWidget(
      isRequired: true,
      label: "dashboard.advancedSearch.roleId".tr(),
      child: CustomMultiSelectDropdown<Reference>(
        key: ValueKey(
          viewModel.selectedRoles?.length,
        ),
        semanticLabel: "dashboard.advancedSearch.roleId".tr(),
        validationMessage: "common.validation.pleaseEnter".tr() +
            "dashboard.advancedSearch.roleId".tr(),
        items: viewModel.getRoleList() ?? [],
        itemBuilder: (context, item, {isDisabled, isSelected}) {
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
          viewModel.onRoleSelected(selectedValues);
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
                  key: ValueKey(
                    viewModel.selectedRoles?.length,
                  ),
                  children: List.generate(data!.length, (index) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      child: Chip(
                        onDeleted: () {
                          viewModel.onRoleChipDeleted(index);
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
        selectedItems: viewModel.selectedRoles,
      ),
    );
  }
}
