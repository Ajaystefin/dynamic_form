import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/fields/application_id_field.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/fields/attachment_date_field.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/fields/country_name_field.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/fields/custom_field.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/fields/custom_text_field.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/fields/gdp_field.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/fields/population_field.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/state.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/widgets/action_bar.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/widgets/browse_upload_buttons.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/widgets/group_corporate_structure.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/widgets/image_row.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/widgets/rating_dropdown.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/widgets/selected_files_list.dart";

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<AppendixViewModel>();

    return BlocBuilder<AppendixViewModel, AppendixState>(
      builder: (context, state) {
        return Layout(
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    AppendixState state,
    AppendixViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadingStatus.loaded:
        return _buildView(context, state, viewModel);
      default:
        return _buildView(context, state, viewModel);
    }
  }

  Widget _buildView(
    BuildContext context,
    AppendixState state,
    AppendixViewModel viewModel,
  ) {
    if (viewModel.showCorporateSection) {
      return Form(
        key: viewModel.formKey,
        child: BoxLayout(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomSectionHeader(
                  title: "eDigitalFilingFileAttachments.appendix.sectionTitle"
                      .tr(),
                ),
                const Gap(),
                BoxLayout(
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GroupCorporateStructure(viewModel: viewModel),
                          const Gap(),
                          CustomFieldWidget(viewModel: viewModel),
                          const Gap(),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ActionBar(viewModel: viewModel),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (viewModel.showFinancialSection) {
      return Form(
        key: viewModel.formKey,
        child: BoxLayout(
          child: ListView(
            shrinkWrap: true,
            children: [
              CustomSectionHeader(
                title: "eDigitalFilingFileAttachments.appendix.fiBankAnnexures"
                    .tr(),
              ),
              const Gap(),
              BoxLayout(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Application ID
                        Expanded(
                          child: ApplicationIdField(
                            viewModel: viewModel,
                          ),
                        ),
                        const Gap(direction: Axis.horizontal),
                        Expanded(
                          child: AttachmentDateField(
                            label: "eDigitalFilingFileAttachments."
                                    "appendix.periodEndDate"
                                .tr(),
                            initialValue: viewModel.selectedDate,
                          ),
                        ),
                      ],
                    ),
                    const Gap(),
                    if (viewModel.selectedFiles.isNotEmpty)
                      SelectedFilesList(
                        viewModel: viewModel,
                        files: viewModel.fiKeyFinancialFiguresExcelFiles,
                      ),

                    // File picker row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "eDigitalFilingFileAttachments.appendix.allowedExt"
                              .tr(),
                          style: const TextStyle(color: AppColors.darkTooltip),
                        ),
                        const Gap(),
                        browseUploadButtonWidget(
                          context,
                          viewModel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (viewModel.showFinancialCFSection) {
      return Form(
        key: viewModel.formKey,
        child: BoxLayout(
          child: ListView(
            shrinkWrap: true,
            children: [
              CustomSectionHeader(
                title:
                    "eDigitalFilingFileAttachments.appendix.fiCountryAnnexures"
                        .tr(),
              ),
              const Gap(),
              BoxLayout(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CountryNameField(
                            viewModel: viewModel,
                          ),
                        ),
                        const Gap(
                          direction: Axis.horizontal,
                        ),
                        Expanded(
                          child: CustomCountryRatingDropdown(
                            viewModel: viewModel,
                            selectedRating: viewModel.appendix.rating,
                            ratingOptions: ServerConstants.kCountryRatings,
                            onRatingChange: (value) {
                              viewModel.setRating(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const Gap(),

                    Row(
                      children: [
                        Expanded(
                          child: PopulationField(
                            viewModel: viewModel,
                          ),
                        ),
                        const Gap(
                          direction: Axis.horizontal,
                        ),
                        Expanded(
                          child: GDPField(
                            viewModel: viewModel,
                          ),
                        ),
                      ],
                    ),
                    const Gap(),

                    // Export Partners
                    CustomTextField(
                      label: "eDigitalFilingFileAttachments."
                              "appendix.exportPartners"
                          .tr(),
                    ),
                    const Gap(),

                    // Import Partners
                    CustomTextField(
                      label: "eDigitalFilingFileAttachments."
                              "appendix.importPartners"
                          .tr(),
                    ),
                    const Gap(),

                    // Strengths
                    CustomTextField(
                      label: "eDigitalFilingFileAttachments.appendix.strengths"
                          .tr(),
                    ),
                    const Gap(),

                    // Threats
                    CustomTextField(
                      label:
                          "eDigitalFilingFileAttachments.appendix.threats".tr(),
                    ),
                    const Gap(
                      size: GapSize.large,
                    ),
                    BoxLayout(
                      child: ImageRow(
                        title: "eDigitalFilingFileAttachments."
                                "appendix.ratingBarImage"
                            .tr(),
                        viewModel: viewModel,

                        type: CountryImage.ratingBar, // add this
                      ),
                    ),
                    BoxLayout(
                      child: ImageRow(
                        title: "eDigitalFilingFileAttachments."
                                "appendix.countryMapImage"
                            .tr(),
                        viewModel: viewModel,

                        type: CountryImage.countryMap, // add this
                      ),
                    ),
                    BoxLayout(
                      child: ImageRow(
                        title: "eDigitalFilingFileAttachments."
                                "appendix.governmentIndicatorsImage"
                            .tr(),
                        viewModel: viewModel,

                        type: CountryImage.governmentIndicators, // add this
                      ),
                    ),
                    const Gap(
                      size: GapSize.large,
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: CustomButton(
                        label:
                            "eDigitalFilingFileAttachments.appendix.save".tr(),
                        onPressed: () {
                          viewModel.onSavePress(isContinue: false);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
