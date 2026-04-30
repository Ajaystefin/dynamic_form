import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/form_row.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/user_detail/model.dart";
import "package:wcas_frontend/features/admin/user_detail/state.dart";
import "package:wcas_frontend/features/admin/user_detail/widgets/user_access_rights.dart";
import "package:wcas_frontend/features/admin/user_detail/widgets/user_access_to_customer_segment.dart";
import "package:wcas_frontend/features/admin/user_detail/widgets/user_access_to_region.dart";
import "package:wcas_frontend/features/admin/user_detail/widgets/user_department.dart";
import "package:wcas_frontend/features/admin/user_detail/widgets/user_designation.dart";
import "package:wcas_frontend/features/admin/user_detail/widgets/user_email.dart";
import "package:wcas_frontend/features/admin/user_detail/widgets/user_id.dart";
import "package:wcas_frontend/features/admin/user_detail/widgets/user_islamic_relation.dart";
import "package:wcas_frontend/features/admin/user_detail/widgets/user_name.dart";
import "package:wcas_frontend/features/admin/user_detail/widgets/user_roles.dart";
import "package:wcas_frontend/features/layout/view.dart";

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<UserDetailViewModel>();

    return BlocBuilder<UserDetailViewModel, UserDetailState>(
      builder: (context, state) {
        switch (state.loaderStatus) {
          case LoadingStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case LoadingStatus.empty:
            return Center(child: Text("common.emptyState".tr()));
          default:
            return Layout(
              child: BoxLayout(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomSectionHeader(
                        title: "admin.userManagementList.userAccess".tr(),
                      ),
                      const Gap(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            child: Focus(
                              focusNode: viewModel.formFocusNode,
                              child: Form(
                                key: viewModel.formKey,
                                child: _body(context, state, viewModel),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
        }
      },
    );
  }

  Widget _body(
    BuildContext context,
    UserDetailState state,
    UserDetailViewModel viewModel,
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
        return buildView(context, state, viewModel);
    }
  }

  Widget buildView(
    BuildContext context,
    UserDetailState state,
    UserDetailViewModel viewModel,
  ) {
    return BoxLayout(
      alignment: Alignment.centerLeft,
      extraPadding: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormRow(
            children: [
              UserId(viewModel: viewModel),
              UserName(viewModel: viewModel),
              UserEmail(viewModel: viewModel),
            ],
          ),
          const Gap(),
          FormRow(
            children: [
              UserDepartment(viewModel: viewModel),
              UserDesignation(viewModel: viewModel),
              UserRoles(viewModel: viewModel),
            ],
          ),
          const Gap(),
          FormRow(
            children: [
              UserAccessToCustomerSegment(viewModel: viewModel),
              UserAccessToRegion(viewModel: viewModel),
            ],
          ),
          const Gap(
            size: GapSize.large,
          ),
          FormRow(
            children: [
              UserAccessRights(viewModel: viewModel),
              UserIslamicRelationship(viewModel: viewModel),
            ],
          ),
          const Gap(),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomButton(
                  isLoading: state.saveUserDetailStatus == LoadingStatus.loading
                      ? true
                      : false,
                  label: "common.save".tr(),
                  onPressed: viewModel.onSaveButtonPressed,
                ),
                const Gap(
                  direction: Axis.horizontal,
                ),
                CustomButton(
                  label: "common.cancel".tr(),
                  onPressed: viewModel.onCancelButtonPressed,
                ),
              ],
            ),
          ),
          const Gap(),
        ],
      ),
    );
  }
}
