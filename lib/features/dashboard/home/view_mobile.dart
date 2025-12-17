import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
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

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

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
          child: SingleChildScrollView(
            child: BoxLayout(
              child: Padding(
                padding: const EdgeInsets.all(AppStyle.spacing),
                child: Column(
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
                            const Gap(direction: Axis.horizontal),
                            CustomSectionHeader(
                                title: "dashboard.home.requestSummary".tr()),
                            const Gap(direction: Axis.horizontal),
                            RefreshButton(
                              viewModel: viewModel,
                              state: state,
                            ),
                            const Gap(direction: Axis.horizontal),
                          ],
                        ),
                        const Gap(),
                        QuickLinks(viewModel, isMobile: true),
                        const Gap(),
                        ChipFilters(viewModel),
                        const Gap(),
                      ],
                    ),
                    const Gap(),
                    ApplicationFilters(viewModel,
                        applicationTypes: viewModel.applicationTypes),
                    const Gap(),
                    GraphView(
                      viewModel: viewModel,
                      state: state,
                      isMobile: true,
                    ),
                    const Gap(),
                    DraftTable(viewModel, state: state),
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
