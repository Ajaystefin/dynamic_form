import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/accordion.dart';
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
import 'package:wcas_frontend/features/request/profitability_account_conduct/business_volume/widgets/bussiness_volume_table.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/business_volume/widgets/comments_field.dart';

import 'model.dart';
import 'state.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    BusinessVolumeViewModel viewModel = context.read<BusinessVolumeViewModel>();
    return BlocBuilder<BusinessVolumeViewModel, BusinessVolumeState>(
        builder: (context, state) {
      return Layout(
        child: SingleChildScrollView(
          child: BoxLayout(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(
                  title:
                      "profitabilityAccountConduct.businessVolume.sectonTitle"
                          .tr()),
              const Gap(),
              BoxLayout(
                child: TopSectionDetails(request: Globals.request!),
              ),
              BoxLayout(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TabMenu(
                        activeKey:
                            BusinessVolumeAccountStatsTabs.businessVolume,
                        routes: TabConstants.businessVolumeAccountStatsRoutes,
                        labels: TabConstants.businessVolumeAccountStatsTitles),
                    BoxLayout(
                      child: _body(context, state, viewModel),
                    ),
                  ],
                ),
              ),
            ],
          )),
        ),
      );
    });
  }

  Widget _body(BuildContext context, BusinessVolumeState state,
      BusinessVolumeViewModel viewModel) {
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
        return _buildView(viewModel);
    }
  }

  Widget _buildView(BusinessVolumeViewModel viewModel) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ...viewModel.customerWiseBusinessVolume.entries.map((data) {
            return CustomAccordion(
                title: data.key.customerName ?? "",
                children: [
                  BusinessVoumeTable(
                    businessVolumes: data.value,
                    viewModel: viewModel,
                  )
                ]);
          }),
          const Gap(),
          BussinessVolumeCommentsField(
            viewModel: viewModel,
          ),
          const Gap(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                semanticLabel:
                    "profitablityAccountConduct.businessVolume.save".tr(),
                label: "profitablityAccountConduct.businessVolume.save".tr(),
                onPressed: () {
                  viewModel.onSavePress();
                },
              ),
              const Gap(
                direction: Axis.horizontal,
              ),
              CustomButton(
                semanticLabel:
                    "profitablityAccountConduct.businessVolume.saveAndContinue"
                        .tr(),
                label:
                    "profitablityAccountConduct.businessVolume.saveAndContinue"
                        .tr(),
                onPressed: () {
                  viewModel.onSavePress(isContinue: true);
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
