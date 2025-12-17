import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/customer_dropdown.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/tab_menu.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/remarks/fee_structure/widgets/fee_structure_table.dart';
import 'package:wcas_frontend/features/request/remarks/fee_structure/widgets/save_button.dart';

import 'model.dart';
import 'state.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    FeeStructureViewModel viewModel = context.read<FeeStructureViewModel>();
    return BlocBuilder<FeeStructureViewModel, FeeStructureState>(
        builder: (context, state) {
      return Layout(
        child: _body(context, state, viewModel),
      );
    });
  }

  Widget _body(BuildContext context, FeeStructureState state,
      FeeStructureViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text('common.emptyState'.tr()),
        );
      case LoadingStatus.error:
        return Center(
          child: Text('common.errorState'.tr()),
        );
      default:
        return buildView(context, state, viewModel);
    }
  }

  Widget buildView(
    BuildContext context,
    FeeStructureState state,
    FeeStructureViewModel viewModel,
  ) {
    return SingleChildScrollView(
      child: BoxLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSectionHeader(title: "remarks.feeStructure.title".tr()),
            const Gap(),
            BoxLayout(child: TopSectionDetails(request: Globals.request!)),
            BoxLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomCustomerDropdown(
                    onCustomerChange: viewModel.onCustomerChanged,
                    selectedCustomer: viewModel.selectedCustomer,
                    onRefresh: () {
                      viewModel.onCustomerChanged(viewModel.selectedCustomer!);
                    },
                  ),
                  const Gap(size: GapSize.small),
                  TabMenu(
                    activeKey: RemarksTabs.feeStructure,
                    routes: TabConstants.remarksRoutes,
                    labels: TabConstants.remarksTitles,
                    showAsteriskTabs: viewModel.showAsteriskTabs,
                    conditionalRoutes: TabConstants.getRemarksRoutes(
                        viewModel.selectedCustomer!),
                    onTabChange: viewModel.changeTab,
                  ),
                  BoxLayout(
                    child: SingleChildScrollView(
                        child: _tabView(context, viewModel, state)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabView(BuildContext context, FeeStructureViewModel viewModel,
      FeeStructureState state) {
    return Form(
      key: viewModel.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(),
          FeeStructureTableTab(viewModel: viewModel, state: state),
          const Gap(size: GapSize.medium),
          SaveButton(viewModel: viewModel),
          const Gap(size: GapSize.medium),
        ],
      ),
    );
  }
}
