import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/admin/role_right_mapping/model.dart";
import "package:wcas_frontend/models/admin/page.dart";

/// Displays the access rights table.
class AccessRightTableField extends StatelessWidget {
  /// Creates an [AccessRightTableField].
  const AccessRightTableField({required this.viewModel, super.key});

  /// View model containing access rights data.
  final RoleRightMappingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomSelectableText(
              text: "admin.roleRightMapping.accessRights".tr(),
              textAlign: TextAlign.left,
              style: AppStyle.tableHeaderStyle,
              semanticsLabel: "admin.roleRightMapping.accessRights".tr(),
            ),
          ],
        ),
        const Gap(),
        CustomRawTable(
          rowsPerPage: viewModel.rowsPerPage,
          isFilterTable: true,
          key: UniqueKey(),
          columnHeaderHeight: 30.w,
          initialPage: viewModel.currentPage,
          onPageChange: (page) {
            viewModel.currentPage = page;
          },
          columns: getTableColumns(),
          rowModels: _buildRows(viewModel),
        ),
      ],
    );
  }

  List<RowModel> _buildRows(RoleRightMappingViewModel viewModel) {
    final filterRow = RowModel(
      isFilterRow: true,
      color: AppColors.tableHeadingColor,
      widget: [
        _nameFilterField(viewModel),
        _typeFilterDropdown(viewModel),
        _accessTypeFilterDropdown(viewModel),
      ],
    );

    final List<RowModel> rowModels = viewModel.filteredPages.map((page) {
      return RowModel(
        isFilterRow: false,
        widget: [
          Text(page.name ?? ""),
          Text(page.type ?? ""),
          SizedBox(
            width: 200.w,
            child: CustomDropdown<AccessType>(
              items: AccessType.values,
              dropdownBuilder: (context, item) =>
                  Text(accessTypeDisplayText(item!)),
              itemBuilder: (context, item, {isDisabled, isSelected}) {
                return dropdownItemBuildWidget(
                  accessTypeDisplayText(item),
                  isSelected: isSelected ?? false,
                );
              },
              selectedItems: [page.accessType],
              onSelected: (selectedValue) {
                if (page.accessType != selectedValue.first) {
                  page
                    ..accessType = selectedValue.first
                    ..isUpdated = true;
                }
              },
            ),
          ),
        ],
      );
    }).toList();

    final List<RowModel> merged = addFilterForRowModel(
      rows: rowModels,
      filterRow: filterRow,
      rowsPerPage: viewModel.rowsPerPage,
    );
    return merged.isEmpty ? [filterRow] : merged;
  }

  Widget _nameFilterField(RoleRightMappingViewModel viewModel) {
    return CustomTextField(
      initialValue: viewModel.nameFilter,
      semanticLabel: "admin.roleRightMapping.accessTableName".tr(),
      fillColor: AppColors.white,
      filled: true,
      textStyle: const TextStyle(fontSize: 13),
      onSubmitted: (String value) {
        viewModel.onNameFilterChanged(value);
      },
    );
  }

  Widget _selectedSummary(List<String> labels) {
    if (labels.isEmpty) {
      return const SizedBox();
    }
    final String text = labels.length == 1
        ? labels.first
        : "${labels.first} & ${labels.length - 1} more";
    return CustomTooltip(
      message: labels.join(", "),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _typeFilterDropdown(RoleRightMappingViewModel viewModel) {
    final List<String> typeOptions = (viewModel.updatedAccessRight?.pages ?? [])
        .map((page) => page.type ?? "")
        .where((type) => type.isNotEmpty)
        .toSet()
        .toList();

    return CustomMultiSelectDropdown<String>(
      isFilterField: true,
      items: typeOptions,
      semanticLabel: "admin.roleRightMapping.accessTableType".tr(),
      fillColor: AppColors.white,
      itemBuilder: (context, item, {isDisabled, isSelected}) {
        return dropdownItemBuildWidget(
          item,
          isSelected: isSelected ?? false,
        );
      },
      dropdownBuilder: (context, items) => _selectedSummary(items ?? []),
      selectedItems: viewModel.typeFilter,
      onSelected: (selectedValue) {
        viewModel.onTypeFilterChanged(selectedValue);
      },
    );
  }

  Widget _accessTypeFilterDropdown(RoleRightMappingViewModel viewModel) {
    return CustomMultiSelectDropdown<AccessType>(
      isFilterField: true,
      items: AccessType.values,
      semanticLabel: "admin.roleRightMapping.adminTableRight".tr(),
      fillColor: AppColors.white,
      itemBuilder: (context, item, {isDisabled, isSelected}) {
        return dropdownItemBuildWidget(
          accessTypeDisplayText(item),
          isSelected: isSelected ?? false,
        );
      },
      dropdownBuilder: (context, items) => _selectedSummary(
        (items ?? []).map(accessTypeDisplayText).toList(),
      ),
      selectedItems: viewModel.accessTypeFilter,
      onSelected: (selectedValue) {
        viewModel.onAccessTypeFilterChanged(selectedValue);
      },
    );
  }

  List<TableColumn> getTableColumns() {
    return [
      TableColumn(
        forcedWidth: 150.w,
        label: Text("admin.roleRightMapping.accessTableName".tr()),
      ),
      TableColumn(
        forcedWidth: 150.w,
        label: Text("admin.roleRightMapping.accessTableType".tr()),
      ),
      TableColumn(
        forcedWidth: 40.w,
        label: Text("admin.roleRightMapping.adminTableRight".tr()),
      ),
    ];
  }
}
