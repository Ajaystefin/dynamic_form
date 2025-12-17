import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:wcas_frontend/features/request/certifications/other_certifications/widgets/certification_table.dart';
import 'package:wcas_frontend/core/components/section_background.dart';

import 'package:wcas_frontend/models/request/request.dart';

import 'model.dart';
import 'state.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<OtherCertificationsViewModel>();
    return BlocBuilder<OtherCertificationsViewModel, OtherCertificationsState>(
      builder: (context, state) {
        return Layout(child: _buildBody(state, viewModel));
      },
    );
  }

  Widget _buildBody(
      OtherCertificationsState state, OtherCertificationsViewModel viewModel) {
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
        return _buildContent(viewModel);
    }
  }

  Widget _buildContent(OtherCertificationsViewModel viewModel) {
    return SingleChildScrollView(
        child: BoxLayout(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CustomSectionHeader(title: viewModel.getPageHeading().tr()),
      const Gap(),
      BoxLayout(
        child: TopSectionDetails(request: Globals.request ?? Request()),
      ),
      BoxLayout(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionBackground(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'certification.otherCertifications.rmPartOne'.tr(),
                style: AppStyle.tableHeaderStyle,
              ),
              const Gap(size: GapSize.small),
              Form(
                  key: viewModel.formKey3,
                  child: CertificateTable(
                    certificates: viewModel.attachmentCertifications,
                  )),
            ],
          )),
          const Gap(),
          SectionBackground(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'certification.otherCertifications.rmPartTwo'.tr(),
                semanticsLabel:
                    'certification.otherCertifications.rmPartTwo'.tr(),
                style: AppStyle.tableHeaderStyle,
              ),
              const Gap(size: GapSize.small),
              Form(
                key: viewModel.formKey2,
                child: CertificateTable(
                  certificates: viewModel.certifications,
                ),
              )
            ],
          )),
          const Gap(),
          viewModel.isReadOnly
              ? Container()
              : Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: CustomButton(
                    label:
                        'certification.otherCertifications.saveContinue'.tr(),
                    semanticLabel:
                        'certification.otherCertifications.saveContinue'.tr(),
                    onPressed: () {
                      viewModel.onSaveContinueButtonPressed();
                    },
                  ),
                ),
        ]),
      ),
    ])));
  }
}
