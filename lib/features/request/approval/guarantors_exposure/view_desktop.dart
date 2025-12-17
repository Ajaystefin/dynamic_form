import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/tab_menu.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/approval/guarantors_exposure/widgets/guarantors_exposure_table.dart';
import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    GuarantorsExposureViewModel viewModel =
        context.read<GuarantorsExposureViewModel>();
    return BlocBuilder<GuarantorsExposureViewModel, GuarantorsExposureState>(
        builder: (context, state) {
      return Layout(
          child: BoxLayout(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(title: "approval.sectionTitle".tr()),
              const Gap(),
              BoxLayout(
                child: TopSectionDetails(request: Globals.request!),
              ),
              BoxLayout(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TabMenu(
                        activeKey: RecommendationTabs.guarantorsExposure,
                        routes: TabConstants.recommendationRoutes,
                        labels: TabConstants.recommendationTitles),
                    BoxLayout(
                      child: SingleChildScrollView(
                          child: _body(context, state, viewModel)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ));
    });
  }

  Widget _body(BuildContext context, GuarantorsExposureState state,
      GuarantorsExposureViewModel viewModel) {
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
        return _buildView(context, viewModel);
    }
  }

  Widget _buildView(
      BuildContext context, GuarantorsExposureViewModel viewModel) {
    return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GuarantorsExposureTable(viewModel: viewModel),
      const Gap(size: GapSize.medium),
      Align(
        alignment: Alignment.centerRight,
        child: CustomButton(
          semanticLabel: "approval.guarantorsExposure.continue".tr(),
          label: "approval.guarantorsExposure.continue".tr(),
          onPressed: () {
            viewModel.onSavePress(context, isContinue: true);
          },
        ),
      ),
      const Gap(size: GapSize.medium),
    ]));
  }
}
