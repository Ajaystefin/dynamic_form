import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/admin/role_right_mapping/model.dart";
import "package:wcas_frontend/models/admin/page.dart";

class AccessRightTableField extends StatelessWidget {
  const AccessRightTableField({required this.viewModel, super.key});
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
          showPagination: true,
          rowsPerPage: 10,
          key: UniqueKey(),
          columnHeaderHeight: 30.w,
          initialPage: viewModel.currentPage,
          onPageChange: (page) {
            viewModel.currentPage = page;
          },
          columns: getTableColumns(),
          rows: List.generate(
              viewModel.updatedAccessRight?.pages == null
                  ? 0
                  : viewModel.updatedAccessRight!.pages!.length, (index) {
            final page = viewModel.updatedAccessRight?.pages?[index];
            return [
              Text(page?.name.toString() ?? ""),
              Text(page?.type.toString() ?? ""),
              SizedBox(
                width: 200.w,
                child: CustomDropdown<AccessType>(
                  items: AccessType.values,
                  dropdownBuilder: (context, item) =>
                      Text(accessTypeDisplayText(item!)),
                  itemBuilder: (context, item, isDisabled, isSelected) {
                    return dropdownItemBuildWidget(
                      accessTypeDisplayText(item),
                      isListTile: true,
                      isSelected: isSelected,
                    );
                  },
                  selectedItems: [page?.accessType],
                  onSelected: (selectedValue) {
                    final page = viewModel.updatedAccessRight?.pages?[index];
                    if (page == null) return;

                    if (page.accessType != selectedValue.first) {
                      page.accessType = selectedValue.first;
                      page.isUpdated = true;

                      // Add only if not already in updatedPages
                      // if (!viewModel.updatedPages!.contains(page)) {
                      //   viewModel.updatedPages!.add(page);
                      // }
                    }
                  },
                ),
              ),
            ];
          }),
        ),
      ],
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
