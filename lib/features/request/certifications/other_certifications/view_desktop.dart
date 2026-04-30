import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_background.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/certifications/other_certifications/model.dart";
import "package:wcas_frontend/features/request/certifications/other_certifications/state.dart";
import "package:wcas_frontend/features/request/certifications/other_certifications/widgets/certification_table.dart";
import "package:wcas_frontend/models/request/request.dart";

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<OtherCertificationsViewModel>();
    return BlocBuilder<OtherCertificationsViewModel, OtherCertificationsState>(
      builder: (context, state) {
        return Layout(child: _buildBody(context, state, viewModel));
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    OtherCertificationsState state,
    OtherCertificationsViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text("common.emptyState".tr()),
        );
      case LoadingStatus.error:
        return Center(
          child: Text("common.errorState".tr()),
        );
      default:
        return SingleChildScrollView(
          child: BoxLayout(
            disabled: !viewModel.canEdit,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSectionHeader(title: viewModel.getPageHeading().tr()),
                const Gap(),
                BoxLayout(
                  child:
                      TopSectionDetails(request: Globals.request ?? Request()),
                ),
                BoxLayout(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.type == CertificationType.rm &&
                          !Utils.checkApplicationType(
                            ApplicationType.markForward,
                          ))
                        SectionBackground(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "certification.otherCertifications.rmPartOne"
                                    .tr(),
                                semanticsLabel: "certification."
                                        "otherCertifications.rmPartOne"
                                    .tr(),
                                style: AppStyle.tableHeaderStyle,
                              ),
                              const Gap(size: GapSize.small),
                              Form(
                                key: viewModel.formKey3,
                                child: CertificateTable(
                                  certificates:
                                      viewModel.attachmentCertifications,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (state.type == CertificationType.rm) const Gap(),
                      SectionBackground(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewModel.getPageHeading().tr(),
                              style: AppStyle.tableHeaderStyle,
                            ),
                            const Gap(size: GapSize.small),
                            Form(
                              key: viewModel.formKey2,
                              child: CertificateTable(
                                certificates: viewModel.certifications,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(),
                      // Show 'Continue' (navigate only) in read-only mode,
                      // or 'Save & Continue' (save + navigate) in edit mode.
                      if (!viewModel.canEdit)
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: CustomButton(
                            label: "certification.otherCertifications.continue"
                                .tr(),
                            semanticLabel:
                                "certification.otherCertifications.continue"
                                    .tr(),
                            onPressed: () => LayoutViewModel().goToNextRoute(),
                          ),
                        )
                      else
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: CustomButton(
                            label:
                                "certification.otherCertifications.saveContinue"
                                    .tr(),
                            semanticLabel:
                                "certification.otherCertifications.saveContinue"
                                    .tr(),
                            onPressed: () =>
                                viewModel.onSaveContinueButtonPressed(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}
