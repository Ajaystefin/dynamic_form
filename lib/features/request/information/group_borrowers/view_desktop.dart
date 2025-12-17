import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:wcas_frontend/features/request/information/group_borrowers/widgets/add_potential_rim.dart';
import 'package:wcas_frontend/features/request/information/group_borrowers/widgets/borrowers_field.dart';
import 'package:wcas_frontend/features/request/information/group_borrowers/widgets/borrowers_table.dart';
import 'package:wcas_frontend/features/request/information/group_borrowers/widgets/continue_button.dart';
import 'package:wcas_frontend/features/request/information/group_borrowers/widgets/non_borrowers_field.dart';
import 'package:wcas_frontend/features/request/information/group_borrowers/widgets/non_borrowers_table.dart';

import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final GroupBorrowersViewModel viewModel =
        context.read<GroupBorrowersViewModel>();
    return BlocBuilder<GroupBorrowersViewModel, GroupBorrowersState>(
      builder: (context, state) {
        return Layout(
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(BuildContext context, GroupBorrowersState state,
      GroupBorrowersViewModel viewModel) {
    final viewModel = context.read<GroupBorrowersViewModel>();
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadingStatus.empty:
        return Center(child: Text('common.emptyState'.tr()));
      case LoadingStatus.error:
        return Center(child: Text('common.errorState'.tr()));
      default:
        return SingleChildScrollView(
          child: BoxLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BoxLayout(
                  child: TopSectionDetails(request: Globals.request!),
                ),
                BoxLayout(
                    child: Form(
                  key: viewModel.formKey,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomSectionHeader(
                                    title:
                                        'requestInformation.groupBorrowers.borrowersPartGroup'
                                            .tr()),
                                const Gap(),
                                const BorrowersTable(),
                                const Gap(size: GapSize.medium),
                                BorrowersField(
                                  viewModel: viewModel,
                                ),
                                const Gap(size: GapSize.small),
                                if (viewModel.showAddRimSection)
                                  const AddRimSection(),
                              ],
                            ),
                          ),
                          const Gap(size: GapSize.large),
                          const Gap(direction: Axis.horizontal),
                          const Gap(size: GapSize.large),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomSectionHeader(
                                    title:
                                        "requestInformation.groupBorrowers.nonBorrowersPartGroup"
                                            .tr()),
                                const Gap(),
                                const NonBorrowersTable(),
                                const Gap(size: GapSize.medium),
                                NonBorrowersField(viewModel: viewModel),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Gap(size: GapSize.medium),
                      if (!viewModel.isReadOnly) const ContinueButton(),
                      const Gap(size: GapSize.medium),
                    ],
                  ),
                )),
              ],
            ),
          ),
        );
    }
  }
}
