import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/dashboard/home/widgets/application_filters.dart';
import 'package:wcas_frontend/features/dashboard/home/widgets/graph/graph_view.dart';
import 'package:wcas_frontend/features/dashboard/home/widgets/quick_links.dart';
import 'package:wcas_frontend/features/dashboard/home/widgets/refresh_button.dart';
import 'package:wcas_frontend/features/dashboard/home/widgets/summary/chip_filters.dart';
import 'package:wcas_frontend/features/dashboard/home/widgets/worklist_table.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';

import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    HomeViewModel viewModel = context.read<HomeViewModel>();
    return BlocBuilder<HomeViewModel, HomeState>(builder: (context, state) {
      if (state.loaderStatus == LoadingStatus.loading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state.loaderStatus == LoadingStatus.error) {
        return Scaffold(
          body: Center(
            child: Text(viewModel.errorText ?? ""),
          ),
        );
      } else {
        return Layout(
          hideSideMenu: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppStyle.spacing),
              child: BoxLayout(
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Gap(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomSectionHeader(
                                    title:
                                        "dashboard.home.requestSummary".tr()),
                                const Gap(direction: Axis.horizontal),
                                RefreshButton(
                                  viewModel: viewModel,
                                  state: state,
                                ),
                              ],
                            ),
                            const Gap(),
                            ChipFilters(viewModel),
                          ],
                        ),
                        ApplicationFilters(
                          viewModel,
                          applicationTypes: viewModel.applicationTypes,
                        ),
                        const Gap(size: GapSize.large), //Newly added
                        GraphView(
                          viewModel: viewModel,
                          state: state,
                        ),
                        const Gap(),
                        DraftTable(viewModel, state: state),
                      ],
                    ),
                    const Gap(),
                    Positioned(
                        right: 0,
                        top: 0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Gap(direction: Axis.horizontal),
                            TextButton(
                                onPressed: () =>
                                    router.go(Routes.advancedSearch),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.search,
                                      color: AppColors.primary,
                                    ),
                                    const Gap(direction: Axis.horizontal),
                                    Text(
                                      "dashboard.home.filter.advancedSearch"
                                          .tr(),
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                )),
                            const Gap(direction: Axis.horizontal),
                            QuickLinks(viewModel),
                          ],
                        )),
                    const Gap(),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    });
  }
}
