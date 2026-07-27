import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/accordion_file_tree.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart";
import "package:wcas_frontend/models/admin/file_access.dart";
import "package:wcas_frontend/models/admin/page.dart";

/// FileAccessTree stateless widget
class FileAccessTree extends StatelessWidget {
  /// Creates [FileAccessTree] instance
  const FileAccessTree(this.fileAccesses, this.viewModel, {super.key});

  /// List of FileAccess
  final List<FileAccess> fileAccesses;

  /// FileAttachmentViewModel view model to handle actions
  final FileAttachmentViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // For each top-level file/folder node, we pass level = 0.
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 600;
        final double treeWidth = isWide
            ? 260.w // tablet & desktop width
            : constraints.maxWidth; // mobile full width
        return SizedBox(
          width: treeWidth, //  full width on mobile
          child: BoxLayout(
            child: ListView(
              shrinkWrap: true,
              children: List.generate(fileAccesses.length, (index) {
                return Column(
                  children: [
                    // For each top-level file/folder node, we pass level = 0.
                    _customRoleRightRow(fileAccesses[index]),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _customRoleRightRow(FileAccess file) {
    final isSelected = viewModel.selectedFolder?.id == file.id;

    if (file.children?.isEmpty ?? true) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
          child: ListTile(
            onTap: () => viewModel.onSelectFolder(file),
            dense: true,
            leading: const SizedBox(),
            title: Row(
              children: [
                Text(
                  "${file.name} "
                  "${file.fileCount > 0 ? "(${file.fileCount})" : ""}",
                  style: AppStyle.tableSuffixHeaderStyle,
                  overflow: TextOverflow.ellipsis,
                ),
                if (file.access == AccessType.view)
                  const Icon(
                    Icons.file_upload_off,
                    size: 14,
                    color: AppColors.darkGrey,
                  ),
              ],
            ),
            // trailing: trailingWidget(file),
          ),
        ),
      );
    }
    return CustomFileAccordion(
      title: "${file.name} ${file.fileCount > 0 ? "(${file.fileCount})" : ""}",
      textStyle: AppStyle.tableSuffixHeaderStyle,
      accordionType: AccordionFileType.teritory,
      onTitleTap: () => viewModel.onSelectFolder(file),
      isSelected: isSelected,
      selectedColor: AppColors.primary.withValues(alpha: 0.1),
      // trailing: trailingWidget(file),

      showLeadingIcon: file.children?.isNotEmpty ?? false,
      children: (file.children?.isEmpty ?? true)
          ? []
          : List.generate(file.children!.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(left: 10),
                child: _customRoleRightRow(file.children![index]),
              );
            }),
    );
  }
}
