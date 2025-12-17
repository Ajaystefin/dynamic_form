import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/form_row.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/top_section/fields/customer_name.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:wcas_frontend/core/components/top_section/fields/request_type.dart'
    as top_section;

import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/ccsys/request_information/fields/application_type.dart';
import 'package:wcas_frontend/features/request/ccsys/request_information/fields/business_segment.dart';
import 'package:wcas_frontend/features/request/ccsys/request_information/fields/ca_date.dart';
import 'package:wcas_frontend/features/request/ccsys/request_information/fields/main_branch.dart';
import 'package:wcas_frontend/features/request/ccsys/request_information/fields/region.dart';
import 'package:wcas_frontend/models/request/request.dart';

import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    RequestInformationViewModel viewModel =
        context.read<RequestInformationViewModel>();
    return BlocBuilder<RequestInformationViewModel, RequestInformationState>(
        builder: (context, state) {
      return Layout(
        child: _body(context, state, viewModel),
      );
    });
  }

  Widget _body(BuildContext context, RequestInformationState state,
      RequestInformationViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.error:
        return Center(
          child: Text('common.serverError'.tr()),
        );
      default:
        return BoxLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(
                title: "ccsys.requestInformation.requestInformation".tr(),
              ),
              const Gap(size: GapSize.large),
              BoxLayout(
                child: FormRow(
                  children: [
                    CustomerName(
                      request: Globals.request ?? Request(),
                    ),
                    top_section.RequestType(
                        request: Request(
                      applicationType: viewModel.applicationTypes.first,
                    ))
                  ],
                ),
              ),
              BoxLayout(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormRow(
                      children: [
                        CaDate(ca: "${viewModel.request.caDate}"),
                      ],
                    ),
                    const Gap(),
                    FormRow(
                      children: [
                        BusinessSegmentField(
                            businessSegment:
                                viewModel.request.businessSegment?.name),
                        Region(region: viewModel.request.region),
                        MainBranch(mainBranch: viewModel.request.branch),
                      ],
                    ),
                    const Gap(),
                    FormRow(
                      children: [
                        ApplicationTypeDropdown(viewModel: viewModel),
                      ],
                    ),
                    const Gap(size: GapSize.large),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButton(
                            label: "ccsys.requestInformation.saveContinue".tr(),
                            onPressed: () async =>
                                await viewModel.onSavePressed()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }
}
