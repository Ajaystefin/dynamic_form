import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/file_access/model.dart";
import "package:wcas_frontend/features/admin/file_access/state.dart";
import "package:wcas_frontend/features/admin/file_access/widgets/build_file_access_table.dart";
import "package:wcas_frontend/features/admin/file_access/widgets/role_field.dart";
import "package:wcas_frontend/features/layout/view.dart";

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final FileAccessViewModel viewModel = context.read<FileAccessViewModel>();
    return BlocBuilder<FileAccessViewModel, FileAccessState>(
      builder: (context, state) {
        return Layout(
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    FileAccessState state,
    FileAccessViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text("common.emptyState".tr()),
        );
      default:
        return _buildView(context, state, viewModel);
    }
  }

  Widget _buildView(
    BuildContext context,
    FileAccessState state,
    FileAccessViewModel viewModel,
  ) {
    return SingleChildScrollView(
      child: BoxLayout(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSectionHeader(
              title: "admin.fileAccess.fileAccessManagement".tr(),
            ),
            const Gap(),
            BoxLayout(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RoleField(viewModel: viewModel),
                  const Gap(),
                  BuildFileAccessTable(
                    viewModel: viewModel,
                    state: state,
                  ),
                  const Gap(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
