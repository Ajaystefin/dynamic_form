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

class BuildFileAccessTable extends StatelessWidget {
  const BuildFileAccessTable({
    required this.state,
    required this.viewModel,
    super.key,
  });
  final FileAccessState state;
  final FileAccessViewModel viewModel;

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
