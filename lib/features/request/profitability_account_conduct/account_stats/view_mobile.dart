import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/accordion.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_background.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/tab_menu.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/account_stats/widgets/account_stats_table.dart';

import 'model.dart';
import 'state.dart';
import 'widgets/action.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    AccountStatsViewModel viewModel = context.read<AccountStatsViewModel>();
    return BlocBuilder<AccountStatsViewModel, AccountStatsState>(
        builder: (context, state) {
      return Layout(
          child: SingleChildScrollView(
        child: BoxLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(
                  title: "profitabilityAccountConduct.accountStats.sectionTitle"
                      .tr()),
              const Gap(),
              BoxLayout(
                child: TopSectionDetails(request: Globals.request!),
              ),
              BoxLayout(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TabMenu(
                          activeKey:
                              BusinessVolumeAccountStatsTabs.accountStats,
                          routes: TabConstants.businessVolumeAccountStatsRoutes,
                          labels:
                              TabConstants.businessVolumeAccountStatsTitles),
                      BoxLayout(
                        child: _body(context, state, viewModel),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ));
    });
  }

  Widget _body(BuildContext context, AccountStatsState state,
      AccountStatsViewModel viewModel) {
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
        return _buildView(viewModel,state);
    }
  }

  Widget _buildView(AccountStatsViewModel viewModel, AccountStatsState state) {
    return SingleChildScrollView(
      child: SectionBackground(
        child: Column(
          children: [
            ...viewModel.customerWiseAccountStat.entries.map((data) {
              return CustomAccordion(
                  title: data.key.customerName ?? "",
                  children: [
                    AccountStatsTable(
                      viewModel: viewModel,
                      accountStat: data.value,
                    )
                  ]);
            }),
            const Gap(),
           ActionWidget(
              viewModel: viewModel,
              state: state,
            )
          ],
        ),
      ),
    );
  }
}
