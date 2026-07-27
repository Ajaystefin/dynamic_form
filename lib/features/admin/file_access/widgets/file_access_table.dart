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

/// Displays the file access table.
class FileAccessTableField extends StatelessWidget {
  /// Creates a [FileAccessTableField].
  const FileAccessTableField({required this.viewModel, super.key});

  /// View model for managing file access data.
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
                if (viewModel.fileAccesses.length - 1 != index)
                  const Divider(
                    color: AppColors.tableCellColorGroupedRow,
                  )
                else
                  const SizedBox(height: 4),
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
      showLeadingIcon: file.children?.isNotEmpty ?? false,
      initiallyExpanded: viewModel.firstLevelParentsWithChildren.contains(file),
      children: (file.children?.isEmpty ?? true)
          ? []
          : List.generate(file.children!.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(left: 14),
                child: _customRoleRightRow(file.children![index]),
              );
            }),
    );
  }

  /// Builds the access type dropdown widget.
  Widget trailingWidget(FileAccess file) => SizedBox(
        width: 200.w,
        child: CustomDropdown<AccessType>(
          validationMessage: "common.validation.pleaseEnter".tr(),
          showClearIcon: false,
          items: AccessType.values.toList(),
          dropdownBuilder: (context, item) =>
              Text(accessTypeDisplayText(item!)),
          itemBuilder: (context, item, {isDisabled, isSelected}) {
            return dropdownItemBuildWidget(
              accessTypeDisplayText(item),
              isSelected: isSelected ?? false,
            );
          },
          selectedItems: file.access != null
              ? [AccessType.values.firstWhere((e) => e == file.access)]
              : [],
          onSelected: (selectedValue) {
            file
              ..access = selectedValue.first
              ..isUpdated = true;
            viewModel.updatedFileAccess.add(file);
          },
        ),
      );
}
