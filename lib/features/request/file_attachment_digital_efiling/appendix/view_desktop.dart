import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
// import 'package:wcas_frontend/core/components/form_row.dart';
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

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<AppendixViewModel>()..init(context);

    return BlocBuilder<AppendixViewModel, AppendixState>(
      builder: (context, state) {
        return Layout(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
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
        autovalidateMode: AutovalidateMode.disabled,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
      );
    } else if (viewModel.showFinancialSection) {
      return Form(
        key: viewModel.formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            const Gap(),

            // Dropdown to choose section type
            BoxLayout(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -----------------------------
                  // SECTION TYPE DROPDOWN
                  // -----------------------------
                  Expanded(
                    child: LabelWidget(
                      label:
                          "eDigitalFilingFileAttachments.appendix.customerType"
                              .tr(),
                      isRequired: true,
                      child: CustomDropdown<String>(
                        width: 320,
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
                  ),

                  // -----------------------------
                  // RIM NUMBER DROPDOWN
                  // -----------------------------

                  if (viewModel.selectedSectionType != ServerConstants.country)
                    Expanded(
                      child: LabelWidget(
                        label: "Select RIM No",
                        isRequired: true,
                        child: CustomDropdown<String>(
                          width: 320,
                          semanticLabel: "Select RIM No",
                          showClearIcon: false,
                          items: viewModel.rimNumbers,
                          hintText: "Select RIM",
                          selectedItems: viewModel.selectedRimNumber != null
                              ? [viewModel.selectedRimNumber]
                              : [],
                          onSelected: (labels) {
                            if (labels.isNotEmpty) {
                              viewModel.onSelectRim(labels.first);
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Gap(),

            // Conditionally show Financial Section
            if (viewModel.selectedSectionType == ServerConstants.bigBank) ...[
              Row(
                children: [
                  CustomSectionHeader(
                    title:
                        "eDigitalFilingFileAttachments.appendix.fiBankAnnexures"
                            .tr(),
                  ),
                  const Gap(
                    direction: Axis.horizontal,
                  ),
                  CustomTooltip(
                    // isRichMessage: widget.isRichMessage,
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
              Column(
                children: [
                  // Key Financial Figures Extracted (Excel)
                  BoxLayout(
                    child: LabelWidget(
                      label: "eDigitalFilingFileAttachments."
                              "appendix.keyFinancialFiguresExtracted"
                          .tr(),
                      child: Column(
                        children: [
                          if (viewModel
                              .fiKeyFinancialFiguresExcelFiles.isNotEmpty)
                            SelectedFilesList(
                              // Update SelectedFilesList to accept a
                              // List<PlatformFile>? files param if needed
                              viewModel: viewModel,
                              files: viewModel.fiKeyFinancialFiguresExcelFiles,
                            ),
                          SelectedFilesList(
                            // Update SelectedFilesList to accept a
                            // List<PlatformFile>? files param if needed
                            viewModel: viewModel,
                            files: viewModel.fiKeyFinancialFiguresExcelFiles,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "eDigitalFilingFileAttachments."
                                        "appendix.allowedExt"
                                    .tr(),
                                style: const TextStyle(
                                  color: AppColors.darkTooltip,
                                  fontSize: AppStyle.fontSizeSmall,
                                ),
                              ),
                              const Gap(),
                              // Provide a button that calls the FI Excel picker
                              if (!viewModel.isAppendixReadOnly)
                                browseUploadButtonWidget(
                                  context,
                                  viewModel,
                                  onPick: viewModel.pickFilesForFiExcel,
                                  onUpload: () async {
                                    await viewModel.onUploadFiExcel(context);
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(),
                  // Upload Key Financial Figures Image
                  BoxLayout(
                    child: LabelWidget(
                      label: "eDigitalFilingFileAttachments."
                              "appendix.uploadKeyFinancialfigures"
                          .tr(),
                      child: Column(
                        children: [
                          if (viewModel.bankFinancialFiles.isNotEmpty)
                            SelectedFilesList(
                              viewModel: viewModel,
                              files: viewModel.bankFinancialFiles,
                            ),
                          if (viewModel.bankFinancialFiles.isNotEmpty)
                            SelectedFilesList(
                              viewModel: viewModel,
                              files: viewModel.bankFinancialFiles,
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "eDigitalFilingFileAttachments."
                                        "appendix.allowedImgExt"
                                    .tr(),
                                style: const TextStyle(
                                  color: AppColors.darkTooltip,
                                  fontSize: AppStyle.fontSizeSmall,
                                ),
                              ),
                              const Gap(),
                              if (!viewModel.isAppendixReadOnly)
                                browseUploadButtonWidget(
                                  context,
                                  viewModel,
                                  onPick: viewModel.pickFilesForFiImage,
                                  onUpload: () async {
                                    final files = viewModel
                                        .fiKeyFinancialFiguresImageFiles;

                                    await viewModel
                                        .uploadFirstAppendixImageFrom(
                                      sourceFiles: files,
                                      customerType: "Bank",
                                      imageType: "Financial",
                                    );
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ]

            // Conditionally show Financial CF Section
            else if (viewModel.selectedSectionType ==
                ServerConstants.country) ...[
              Row(
                children: [
                  CustomSectionHeader(
                    title: "eDigitalFilingFileAttachments."
                            "appendix.fiCountryAnnexures"
                        .tr(),
                  ),
                  const Gap(
                    direction: Axis.horizontal,
                  ),
                  CustomTooltip(
                    // isRichMessage: widget.isRichMessage,
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
                  children: [
                    const Gap(),
                    Row(
                      children: [
                        Expanded(child: CountryNameField(viewModel: viewModel)),
                        const Gap(direction: Axis.horizontal),
                        Expanded(child: PopulationField(viewModel: viewModel)),
                        const Gap(direction: Axis.horizontal),
                        Expanded(child: GDPField(viewModel: viewModel)),
                      ],
                    ),
                    const Gap(),
                    Row(
                      children: [
                        Expanded(
                          child: CustomCountryRatingDropdown(
                            viewModel: viewModel,
                            selectedRating: viewModel.selectedRating,
                            ratingOptions: viewModel.countryRatingOptions,
                            onRatingChange: (value) {
                              viewModel.setRating(value);
                            },
                          ),
                        ),
                        const Gap(direction: Axis.horizontal),

                        Expanded(
                          child: LabelWidget(
                            label: "eDigitalFilingFileAttachments."
                                    "appendix.importPartners"
                                .tr(),
                            isRequired: true,
                            child: CustomMultiSelectDropdown<String>(
                              hintText: "Select", isSearchable: true,
                              isEnabled: !viewModel.isAppendixReadOnly,

                              semanticLabel: "eDigitalFilingFileAttachments."
                                      "appendix.importPartners"
                                  .tr(),
                              items: viewModel.countryNames,
                              validationMessage:
                                  "common.validation.emptyRequiredField".tr(),

                              selectedItems: viewModel.appendix
                                  .importPartners, // <- source of truth
                              onSelected: viewModel
                                  .updateImportPartners, // <- VM method
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
                                  spacing: 4,
                                  runSpacing: 4,
                                  itemBuilder: (index) {
                                    final label = selectedList[index];
                                    return Chip(
                                      label: Text(label),
                                      // (Optional) Force a visible delete icon
                                      deleteIcon: const Icon(Icons.close),
                                      onDeleted: () {
                                        final newList = List<String>.from(
                                          viewModel.appendix.importPartners,
                                        );
                                        newList.remove(
                                          label,
                                        );
                                        viewModel.updateImportPartners(
                                          newList,
                                        ); // <- triggers rebuild
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),

                        const Gap(direction: Axis.horizontal),
                        // const Gap(
                        //   direction: Axis.horizontal,
                        // ),

                        Expanded(
                          child: LabelWidget(
                            label: "eDigitalFilingFileAttachments."
                                    "appendix.exportPartners"
                                .tr(),
                            isRequired: true,
                            child: CustomMultiSelectDropdown<String>(
                              isEnabled: !viewModel.isAppendixReadOnly,
                              hintText: "Select",
                              validationMessage:
                                  "common.validation.emptyRequiredField".tr(),
                              semanticLabel: "eDigitalFilingFileAttachments."
                                      "appendix.exportPartners"
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
                                  spacing: 4,
                                  runSpacing: 4,
                                  itemBuilder: (index) {
                                    final label = selectedList[index];
                                    return Chip(
                                      label: Text(label),
                                      deleteIcon: const Icon(Icons.close),
                                      onDeleted: () {
                                        final newList = List<String>.from(
                                          viewModel.appendix.exportPartners,
                                        );
                                        newList.remove(label);
                                        viewModel.updateExportPartners(newList);
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Gap(),
                        Row(
                          children: [],
                        ),
                      ],
                    ),
                    const Gap(
                      size: GapSize.large,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              FieldListTable(
                                label: "eDigitalFilingFileAttachments."
                                        "appendix.strengths"
                                    .tr(),
                                viewModel: viewModel,
                                useStrengths: true,
                              ),
                              if (!viewModel.isAppendixReadOnly)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: AddItemButton(
                                    onTap: viewModel.addStrengthTableRow,
                                    isLeftSided: true,
                                    child: Text(
                                      "eDigitalFilingFileAttachments."
                                              "appendix.addStrength"
                                          .tr(),
                                      style: const TextStyle(
                                        fontSize: AppStyle.fontSizeSmall,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Gap(
                          direction: Axis.horizontal,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              FieldListTable(
                                label: "eDigitalFilingFileAttachments."
                                        "appendix.threats"
                                    .tr(),
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
                                      semanticsLabel:
                                          "eDigitalFilingFileAttachments."
                                                  "appendix.addThreats"
                                              .tr(),
                                      "eDigitalFilingFileAttachments."
                                              "appendix.addThreats"
                                          .tr(),
                                      style: const TextStyle(
                                        fontSize: AppStyle.fontSizeSmall,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Gap(size: GapSize.large),
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
                    const Gap(size: GapSize.large),
                    if (!viewModel.isAppendixReadOnly)
                      Align(
                        alignment: Alignment.centerRight,
                        child: CustomButton(
                          label: "eDigitalFilingFileAttachments.appendix.save"
                              .tr(),
                          onPressed: () {
                            viewModel.onSavePress(isContinue: false);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
