import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/certifications/esg_certification/widgets/section_five.dart';
import 'package:wcas_frontend/features/request/certifications/esg_certification/widgets/section_four.dart';
import 'package:wcas_frontend/features/request/certifications/esg_certification/widgets/section_one.dart';
import 'package:wcas_frontend/features/request/certifications/esg_certification/widgets/section_three.dart';
import 'package:wcas_frontend/features/request/certifications/esg_certification/widgets/section_two.dart';

import 'model.dart';
import 'state.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    EsgCertificationViewModel viewModel =
        context.read<EsgCertificationViewModel>();
    return BlocBuilder<EsgCertificationViewModel, EsgCertificationState>(
        builder: (context, state) {
      return Layout(
        child: _body(context, state, viewModel),
      );
    });
  }

  Widget _body(BuildContext context, EsgCertificationState state,
      EsgCertificationViewModel viewModel) {
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
          child: Text('common.serverError'.tr()),
        );
      default:
        return SingleChildScrollView(
            child: BoxLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(
                  title: "certification.esgCertification.title".tr()),
              const Gap(),
              BoxLayout(
                child: TopSectionDetails(request: Globals.request!),
              ),
              BoxLayout(
                  child: Form(
                key: viewModel.formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionOne(viewModel: viewModel),
                      const Gap(),
                      SectionTwo(viewModel: viewModel),
                      const Gap(),
                      SectionThree(viewModel: viewModel),
                      const Gap(),
                      SectionFour(viewModel: viewModel),
                      const Gap(),
                      SectionFive(viewModel: viewModel, state: state),
                    ]),
              )),
            ],
          ),
        ));
    }
  }
}
