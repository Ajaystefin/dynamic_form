import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';

import 'model.dart';
import 'state.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/features/admin/user_detail/widgets/user_access_rights.dart';
import 'package:wcas_frontend/features/admin/user_detail/widgets/user_access_to_customer_segment.dart';
import 'package:wcas_frontend/features/admin/user_detail/widgets/user_access_to_region.dart';
import 'package:wcas_frontend/features/admin/user_detail/widgets/user_department.dart';
import 'package:wcas_frontend/features/admin/user_detail/widgets/user_designation.dart';
import 'package:wcas_frontend/features/admin/user_detail/widgets/user_email.dart';
import 'package:wcas_frontend/features/admin/user_detail/widgets/user_id.dart';
import 'package:wcas_frontend/features/admin/user_detail/widgets/user_name.dart';
import 'package:wcas_frontend/features/admin/user_detail/widgets/user_roles.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<UserDetailViewModel>();
    return BlocBuilder<UserDetailViewModel, UserDetailState>(
      builder: (context, state) {
        switch (state.loaderStatus) {
          case LoadingStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case LoadingStatus.empty:
            return Center(child: Text('common.emptyState'.tr()));
          default:
            return Layout(child: _buildForm(viewModel));
        }
      },
    );
  }

  Widget _buildForm(UserDetailViewModel viewModel) {
    return BoxLayout(
      child: SingleChildScrollView(
        child: Focus(
          focusNode: viewModel.formFocusNode,
          child: Form(
            key: viewModel.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSectionHeader(
                    title: "admin.userManagementList.userAccess".tr()),
                const Gap(
                  size: GapSize.large,
                ),
                BoxLayout(
                  extraPadding: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserId(viewModel: viewModel),
                      const Gap(),
                      UserName(viewModel: viewModel),
                      const Gap(),
                      UserEmail(viewModel: viewModel),
                      const Gap(),
                      UserDepartment(viewModel: viewModel),
                      const Gap(),
                      UserDesignation(viewModel: viewModel),
                      const Gap(),
                      UserRoles(viewModel: viewModel),
                      const Gap(),
                      UserAccessToCustomerSegment(viewModel: viewModel),
                      const Gap(),
                      UserAccessToRegion(viewModel: viewModel),
                      const Gap(),
                      UserAccessRights(viewModel: viewModel),
                      const Gap(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomButton(
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
                      const Gap(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
