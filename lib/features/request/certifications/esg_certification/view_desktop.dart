import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/model.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/state.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/widgets/section_dynamic_comment_field.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/widgets/section_five.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/widgets/section_four.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/widgets/section_one.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/widgets/section_three.dart";
import "package:wcas_frontend/features/request/certifications/esg_certification/widgets/section_two.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final EsgCertificationViewModel viewModel =
        context.read<EsgCertificationViewModel>();
    return BlocBuilder<EsgCertificationViewModel, EsgCertificationState>(
      builder: (context, state) {
        return Layout(
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    EsgCertificationState state,
    EsgCertificationViewModel viewModel,
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
          child: Text("common.serverError".tr()),
        );
      default:
        return SingleChildScrollView(
          child: BoxLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSectionHeader(
                  title: "certification.esgCertification.title".tr(),
                ),
                const Gap(),
                BoxLayout(
                  child: TopSectionDetails(request: Globals.request!),
                ),
                BoxLayout(
                  disabled: viewModel.isReadOnly,
                  child: Form(
                    key: viewModel.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionOne(
                          key: ValueKey("section1-${state.fieldVersion}"),
                          viewModel: viewModel,
                        ),
                        const Gap(),
                        if (viewModel.sffRequired) ...[
                          const Gap(),
                          SectionTwo(
                            key: ValueKey("section2-${state.fieldVersion}"),
                            viewModel: viewModel,
                          ),
                        ],
                        const Gap(),
                        if (viewModel.sllRequired) ...[
                          const Gap(),
                          SectionThree(
                            key: ValueKey("section3-${state.fieldVersion}"),
                            viewModel: viewModel,
                          ),
                        ],
                        const Gap(),
                        SectionFour(
                          key: ValueKey("section4-${state.fieldVersion}"),
                          viewModel: viewModel,
                        ),
                        const Gap(),
                        // Build for each section
                        ...viewModel.dynamicSections.map((Reference ref) {
                          final int refId = ref.id ?? 0;
                          final String headerTitle = ref.name ?? "";
                          final String label = ref.description ?? "";
                          final String initialValue =
                              viewModel.initialTextOnceFor(refId);

                          return SectionDynamicCommentField(
                            key: ValueKey(
                              "strategy-$refId-${state.fieldVersion}",
                            ),
                            readOnly: viewModel.isReadOnly,
                            label: label,
                            initialValue: initialValue,
                            headerTitle: headerTitle,
                            onChanged: (val) =>
                                viewModel.updateComment(refId, val),
                          );
                        }),
                        const Gap(),
                        SectionFive(viewModel: viewModel, state: state),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}
