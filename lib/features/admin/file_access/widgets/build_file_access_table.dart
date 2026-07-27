import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/file_access/model.dart";
import "package:wcas_frontend/features/admin/file_access/state.dart";
import "package:wcas_frontend/features/admin/file_access/widgets/file_access_table.dart";

/// Displays the file access table and save action for the admin module.
///
/// Depending on the current [FileAccessState.fileAccessStatus], this widget:
/// - Shows a loading indicator while data is loading.
/// - Displays the file access table and save button when data is loaded.
/// - Returns an empty container for any other state.
class BuildFileAccessTable extends StatelessWidget {
  /// Creates a [BuildFileAccessTable].
  const BuildFileAccessTable({
    required this.state,
    required this.viewModel,
    super.key,
  });

  /// Current file access state.
  final FileAccessState state;

  /// View model used to manage file access operations.
  final FileAccessViewModel viewModel;

  /// Builds the widget based on the current file access status.
  @override
  Widget build(BuildContext context) {
    switch (state.fileAccessStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.darkBlue,
          ),
        );

      case LoadingStatus.loaded:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabelWidget(
              label: "admin.fileAccess.fileAccess".tr(),
              child: FileAccessTableField(
                viewModel: viewModel,
              ),
            ),
            const Gap(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  isLoading: state.savingStatus == LoadingStatus.loading,
                  onPressed: viewModel.fileAccesses.isNotEmpty
                      ? viewModel.onSave
                      : null,
                  label: "common.save".tr(),
                  semanticLabel: "common.save".tr(),
                ),
              ],
            ),
          ],
        );

      default:
        return Container();
    }
  }
}
