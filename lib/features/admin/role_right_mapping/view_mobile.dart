import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/role_right_mapping/model.dart";
import "package:wcas_frontend/features/admin/role_right_mapping/state.dart";
import "package:wcas_frontend/features/admin/role_right_mapping/widgets/build_table.dart";
import "package:wcas_frontend/features/admin/role_right_mapping/widgets/request_type_field.dart";
import "package:wcas_frontend/features/admin/role_right_mapping/widgets/role_field.dart";
import "package:wcas_frontend/features/layout/view.dart";

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final RoleRightMappingViewModel viewModel =
        context.read<RoleRightMappingViewModel>();
    return BlocBuilder<RoleRightMappingViewModel, RoleRightMappingState>(
      builder: (context, state) {
        return Layout(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: BoxLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                    title: "admin.roleRightMapping.tabTitle".tr(),
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
    RoleRightMappingState state,
    RoleRightMappingViewModel viewModel,
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
    RoleRightMappingState state,
    RoleRightMappingViewModel viewModel,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            RoleField(viewModel: viewModel),
            const Gap(direction: Axis.horizontal),
            RequestTypeField(viewModel: viewModel),
          ],
        ),
        const Gap(),
        BuildReferenceTable(state: state, viewModel: viewModel),
        const Gap(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomButton(
              isLoading: state.saveReferenceStatus == LoadingStatus.loading
                  ? true
                  : false,
              onPressed: viewModel.updatedAccessRight != null
                  ? () async {
                      await viewModel.onSave();
                    }
                  : null,
              label: "common.save".tr(),
            ),
          ],
        ),
      ],
    );
  }
}
