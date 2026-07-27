import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";

import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/fields/country_name_field.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/fields/custom_field.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/fields/field_lists_table.dart";
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

/// View for mobile
class ViewMobile extends StatelessWidget {
  /// Creates instance
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<AppendixViewModel>()..init(context);

    return BlocBuilder<AppendixViewModel, AppendixState>(
      builder: (context, state) {
        return Layout(
          child: SingleChildScrollView(
            controller: viewModel.scrollController,
            child: BoxLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                    title: "eDigitalFilingFileAttachments.appendix.sectionTitle"
                        .tr(),
                  ),
                  const Gap(),
                  BoxLayout(
                    child: TopSectionDetails(request: Globals.request!),
                  ),
                  BoxLayout(
                    child: _body(context, state, viewModel),
                  ),
                ],
              ),
            ),
          ),
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
        return _buildViewMobile(context, state, viewModel);
      default:
        return _buildViewMobile(context, state, viewModel);
    }
  }

  Widget _buildViewMobile(
    BuildContext context,
    AppendixState state,
    AppendixViewModel viewModel,
  ) {
    // -----------------------------
    // CORPORATE SECTION (MOBILE)
    // -----------------------------
    if (viewModel.showCorporateSection) {
      return Form(
        key: viewModel.formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(),
            BoxLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GroupCorporateStructure(viewModel: viewModel),
                  const Gap(),
                  CustomFieldWidget(viewModel: viewModel),
                  const Gap(),

                  // Action bar stacked / right aligned
                  Align(
                    alignment: Alignment.centerRight,
                    child: ActionBar(viewModel: viewModel),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // -----------------------------
    // FINANCIAL SECTION (MOBILE)
    // -----------------------------
    if (viewModel.showFinancialSection) {
      return Form(
        key: viewModel.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(),

            // SECTION TYPE + RIM stacked
            BoxLayout(
              child: Column(
                children: [
                  LabelWidget(
                    label: "eDigitalFilingFileAttachments.appendix.customerType"
                        .tr(),
                    isRequired: true,
                    child: CustomDropdown<String>(
                      // Full width on mobile
                      semanticLabel: "Select Section Type",
                      showClearIcon: false,
                      items: const [
                        ServerConstants.country,
                        ServerConstants.bigBank,
                      ],
                      hintText: "Select Section",
                      selectedItems: [viewModel.selectedSectionType],
                      onSelected: (labels) {
                        if (labels.isNotEmpty) {
                          viewModel.updateSelectedSectionType(labels.first);
                        }
                      },
                    ),
                  ),
                  const Gap(),
                  if (viewModel.rimNumbers.isNotEmpty)
                    LabelWidget(
                      label: "Select RIM No",
                      isRequired: true,
                      child: CustomDropdown<String>(
                        semanticLabel: "Select RIM No",
                        showClearIcon: false,
                        items: viewModel.rimNumbers,
                        hintText: "Select RIM",
                        selectedItems: viewModel.selectedRimNumber != null
                            ? [viewModel.selectedRimNumber]
                            : [],
                        isEnabled: viewModel.selectedSectionType !=
                            ServerConstants.country,
                        onSelected: (labels) {
                          if (viewModel.selectedSectionType ==
                              ServerConstants.country) {
                            return; // non-editable when Country selected
                          }

                          if (labels.isNotEmpty) {
                            viewModel.onSelectRim(labels.first);
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),

            if (viewModel.showRimNotAvailableMessage)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "eDigitalFilingFileAttachments.appendix.rimNotAvailable".tr(),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            const Gap(),

            // -----------------------------
            // BIG BANK (MOBILE)
            // -----------------------------
            if (viewModel.selectedSectionType == ServerConstants.bigBank) ...[
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  CustomSectionHeader(
                    title:
                        "eDigitalFilingFileAttachments.appendix.fiBankAnnexures"
                            .tr(),
                  ),
                  CustomTooltip(
                    message:
                        "eDigitalFilingFileAttachments.appendix.excelUploadInfo"
                            .tr(),
                    textAlign: TextAlign.start,
                    child: const Icon(
                      Icons.info_outlined,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const Gap(),

              // Key Financial Figures Extracted (Excel)
              BoxLayout(
                child: LabelWidget(
                  label:
                      "eDigitalFilingFileAttachments.appendix.keyFinancialFiguresExtracted"
                          .tr(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectedFilesList(
                        key: const ValueKey("appendix_mobile_excel_files_list"),
                        viewModel: viewModel,
                        files: viewModel.fiExtractXlsxFiles.isNotEmpty
                            ? viewModel.fiExtractXlsxFiles
                            : viewModel.fiKeyFinancialFiguresExcelFiles,
                      ),
                      const Gap(size: GapSize.small),
                      Text(
                        "eDigitalFilingFileAttachments.appendix.allowedExt"
                            .tr(),
                        style: const TextStyle(
                          color: AppColors.darkTooltip,
                          fontSize: AppStyle.fontSizeSmall,
                        ),
                      ),
                      const Gap(size: GapSize.small),
                      if (!viewModel.isAppendixReadOnly)
                        Align(
                          alignment: Alignment.centerRight,
                          child: browseUploadButtonWidget(
                            context,
                            viewModel,
                            isEnabled: !viewModel.isFiRimUnavailable,
                            onPick: viewModel.pickFilesForFiExcel,
                            onUpload: () async {
                              await viewModel.onUploadFiExcel(context);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const Gap(),

              // Upload Key Financial Figures Image
              BoxLayout(
                child: LabelWidget(
                  label:
                      "eDigitalFilingFileAttachments.appendix.uploadKeyFinancialfigures"
                          .tr(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectedFilesList(
                        key: const ValueKey("appendix_mobile_image_files_list"),
                        viewModel: viewModel,
                        files: viewModel.bankFinancialFiles.isNotEmpty
                            ? viewModel.bankFinancialFiles
                            : viewModel.fiKeyFinancialFiguresImageFiles,
                      ),
                      const Gap(size: GapSize.small),
                      Text(
                        "eDigitalFilingFileAttachments.appendix.allowedImgExt"
                            .tr(),
                        style: const TextStyle(
                          color: AppColors.darkTooltip,
                          fontSize: AppStyle.fontSizeSmall,
                        ),
                      ),
                      const Gap(size: GapSize.small),
                      if (!viewModel.isAppendixReadOnly)
                        Align(
                          alignment: Alignment.centerRight,
                          child: browseUploadButtonWidget(
                            context,
                            viewModel,
                            isEnabled: !viewModel.isFiRimUnavailable,
                            onPick: viewModel.pickFilesForFiImage,
                            onUpload: () async {
                              final files =
                                  viewModel.fiKeyFinancialFiguresImageFiles;
                              await viewModel.uploadFirstAppendixImageFrom(
                                sourceFiles: files,
                                customerType: "Bank",
                                imageType: "Financial",
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ]

            // -----------------------------
            // COUNTRY (MOBILE)
            // -----------------------------
            else if (viewModel.selectedSectionType ==
                ServerConstants.country) ...[
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  CustomSectionHeader(
                    title:
                        "eDigitalFilingFileAttachments.appendix.fiCountryAnnexures"
                            .tr(),
                  ),
                  CustomTooltip(
                    message:
                        "eDigitalFilingFileAttachments.appendix.imageUploadInfo"
                            .tr(),
                    textAlign: TextAlign.start,
                    child: const Icon(
                      Icons.info_outlined,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const Gap(),
              BoxLayout(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stacked fields on mobile
                    CountryNameField(viewModel: viewModel),
                    const Gap(),
                    PopulationField(viewModel: viewModel),
                    const Gap(),
                    GDPField(viewModel: viewModel),
                    const Gap(),

                    // Rating
                    CustomCountryRatingDropdown(
                      viewModel: viewModel,
                      selectedRating: viewModel.selectedRating,
                      ratingOptions: viewModel.countryRatingOptions,
                      onRatingChange: (value) => viewModel.setRating(value),
                    ),
                    const Gap(),

                    // Import Partners
                    LabelWidget(
                      label:
                          "eDigitalFilingFileAttachments.appendix.importPartners"
                              .tr(),
                      isRequired: true,
                      child: CustomMultiSelectDropdown<String>(
                        hintText: "Select",
                        isSearchable: true,
                        isEnabled: !viewModel.isAppendixReadOnly,
                        semanticLabel:
                            "eDigitalFilingFileAttachments.appendix.importPartners"
                                .tr(),
                        items: viewModel.countryNames,
                        validationMessage:
                            "common.validation.emptyRequiredField".tr(),
                        selectedItems: viewModel.appendix.importPartners,
                        onSelected: viewModel.updateImportPartners,
                        dropdownBuilder: (context, selected) {
                          final selectedList =
                              viewModel.appendix.importPartners;
                          if (selectedList.isEmpty) {
                            return const SizedBox();
                          }

                          final controller = ScrollController();
                          return multiSelectDropDownBuilderWidget(
                            data: selectedList,
                            controller: controller,
                            height: 72,
                            itemBuilder: (index) {
                              final label = selectedList[index];
                              return Chip(
                                label: Text(label),
                                deleteIcon: const Icon(Icons.close),
                                onDeleted: () {
                                  final newList = List<String>.from(
                                    viewModel.appendix.importPartners,
                                  )..remove(label);
                                  viewModel.updateImportPartners(newList);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const Gap(),

                    // Export Partners
                    LabelWidget(
                      label:
                          "eDigitalFilingFileAttachments.appendix.exportPartners"
                              .tr(),
                      isRequired: true,
                      child: CustomMultiSelectDropdown<String>(
                        isEnabled: !viewModel.isAppendixReadOnly,
                        hintText: "Select",
                        validationMessage:
                            "common.validation.emptyRequiredField".tr(),
                        semanticLabel:
                            "eDigitalFilingFileAttachments.appendix.exportPartners"
                                .tr(),
                        items: viewModel.countryNames,
                        isSearchable: true,
                        selectedItems: viewModel.appendix.exportPartners,
                        onSelected: viewModel.updateExportPartners,
                        dropdownBuilder: (context, selected) {
                          final selectedList =
                              viewModel.appendix.exportPartners;
                          if (selectedList.isEmpty) {
                            return const SizedBox();
                          }

                          final controller = ScrollController();
                          return multiSelectDropDownBuilderWidget(
                            data: selectedList,
                            controller: controller,
                            height: 72,
                            itemBuilder: (index) {
                              final label = selectedList[index];
                              return Chip(
                                label: Text(label),
                                deleteIcon: const Icon(Icons.close),
                                onDeleted: () {
                                  final newList = List<String>.from(
                                    viewModel.appendix.exportPartners,
                                  )..remove(label);
                                  viewModel.updateExportPartners(newList);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const Gap(size: GapSize.large),

                    // Strengths (stacked)
                    FieldListTable(
                      label: "eDigitalFilingFileAttachments.appendix.strengths"
                          .tr(),
                      viewModel: viewModel,
                    ),
                    if (!viewModel.isAppendixReadOnly)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AddItemButton(
                          onTap: viewModel.addStrengthTableRow,
                          isLeftSided: true,
                          child: Text(
                            "eDigitalFilingFileAttachments.appendix.addStrength"
                                .tr(),
                            style: const TextStyle(
                              fontSize: AppStyle.fontSizeSmall,
                            ),
                          ),
                        ),
                      ),

                    const Gap(size: GapSize.large),

                    // Threats (stacked)
                    FieldListTable(
                      label:
                          "eDigitalFilingFileAttachments.appendix.threats".tr(),
                      viewModel: viewModel,
                      useStrengths: false,
                    ),
                    if (!viewModel.isAppendixReadOnly)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AddItemButton(
                          onTap: viewModel.addThreatTableRow,
                          isLeftSided: true,
                          child: Text(
                            "eDigitalFilingFileAttachments.appendix.addThreats"
                                .tr(),
                            style: const TextStyle(
                              fontSize: AppStyle.fontSizeSmall,
                            ),
                          ),
                        ),
                      ),

                    const Gap(size: GapSize.large),

                    // Images stacked
                    ImageRow(
                      title:
                          "eDigitalFilingFileAttachments.appendix.ratingBarImage"
                              .tr(),
                      viewModel: viewModel,
                      type: CountryImage.ratingBar,
                    ),
                    const Gap(),
                    ImageRow(
                      title:
                          "eDigitalFilingFileAttachments.appendix.countryMapImage"
                              .tr(),
                      viewModel: viewModel,
                      type: CountryImage.countryMap,
                    ),
                    const Gap(),
                    ImageRow(
                      title:
                          "eDigitalFilingFileAttachments.appendix.governmentIndicatorsImage"
                              .tr(),
                      viewModel: viewModel,
                      type: CountryImage.governmentIndicators,
                    ),

                    const Gap(size: GapSize.large),

                    if (!viewModel.isAppendixReadOnly)
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          label: "eDigitalFilingFileAttachments.appendix.save"
                              .tr(),
                          onPressed: () => viewModel.onSavePress(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return const SizedBox();
  }
}
