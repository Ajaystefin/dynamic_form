// ignore_for_file: prefer_is_empty

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/admin/file_access/model.dart";
import "package:wcas_frontend/models/admin/file_access.dart";
import "package:wcas_frontend/models/admin/page.dart";

class FileAccessTableField extends StatelessWidget {
  const FileAccessTableField({required this.viewModel, super.key});
  final FileAccessViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.tableCellColorGroupedRow),
      ),
      width: context.isDesktop ? 500.w : 900.w,
      child: Column(
        children: [
          CustomRawTable(
            key: UniqueKey(),
            autoFitWidth: true,
            rowMinHeight: 0,
            rowHeight: 0,
            columns: [
              TableColumn(label: Text("admin.fileAccess.fileName".tr())),
              TableColumn(label: Text("admin.fileAccess.right".tr())),
            ],
            rows: const [],
          ),
          const Gap(
            size: GapSize.small,
          ),
          ...List.generate(viewModel.fileAccesses.length, (index) {
            return Column(
              children: [
                _customRoleRightRow(viewModel.fileAccesses[index]),
                viewModel.fileAccesses.length - 1 != index
                    ? const Divider(
                        color: AppColors.tableCellColorGroupedRow,
                      )
                    : const SizedBox(height: 4),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _customRoleRightRow(FileAccess file) {
    if (file.children?.isEmpty ?? true) {
      return ListTile(
        dense: true,
        leading: const SizedBox(),
        title: Text(file.name ?? ""),
        trailing: trailingWidget(file),
      );
    }
    return CustomAccordion(
      title: file.name ?? "",
      textStyle: const TextStyle(fontSize: AppStyle.fontSizeSmall),
      accordionType: AccordionType.teritory,
      trailing: trailingWidget(file),
      showLeadingIcon: file.children?.length != 0,
      initiallyExpanded:
          (viewModel.firstLevelParentsWithChildren.contains(file))
              ? true
              : false,
      children: (file.children?.length == 0)
          ? []
          : List.generate(file.children!.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(left: 14),
                child: _customRoleRightRow(file.children![index]),
              );
            }),
    );
  }

  Widget trailingWidget(FileAccess file) => SizedBox(
        width: 200.w,
        child: CustomDropdown<AccessType>(
          validationMessage: "common.validation.pleaseEnter".tr(),
          showClearIcon: false,
          items: AccessType.values.toList(),
          dropdownBuilder: (context, item) =>
              Text(accessTypeDisplayText(item!)),
          itemBuilder: (context, item, isDisabled, isSelected) {
            return dropdownItemBuildWidget(
              accessTypeDisplayText(item),
              isListTile: true,
              isSelected: isSelected,
            );
          },
          selectedItems: file.access != null
              ? [AccessType.values.firstWhere((e) => e == file.access)]
              : [],
          onSelected: (selectedValue) {
            file
              ..access = selectedValue.first
              ..isUpdated = true;
            // viewModel.updatedFileAccess.add(file);
          },
        ),
      );
}
