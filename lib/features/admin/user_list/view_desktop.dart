import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/user_list/model.dart";
import "package:wcas_frontend/features/admin/user_list/state.dart";
import "package:wcas_frontend/features/admin/user_list/widgets/user_list_table.dart";
import "package:wcas_frontend/features/layout/view.dart";

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final UserListViewModel viewModel = context.read<UserListViewModel>();
    return BlocBuilder<UserListViewModel, UserListState>(
      builder: (context, state) {
        return Layout(
          child: SingleChildScrollView(
            child: BoxLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                    title: "admin.userManagementList.usersList".tr(),
                  ),
                  const Gap(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BoxLayout(
                        child: _body(context, state, viewModel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    UserListState state,
    UserListViewModel viewModel,
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
    UserListState state,
    UserListViewModel viewModel,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [UserListTable(viewModel: viewModel, state: state)],
    );
  }
}
