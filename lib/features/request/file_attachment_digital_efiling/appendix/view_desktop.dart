import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/add_item_button.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
// import 'package:wcas_frontend/core/components/form_row.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/fields/country_name_field.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/fields/custom_field.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/fields/field_lists_table.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/fields/gdp_field.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/fields/population_field.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/state.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/widgets/action_bar.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/widgets/browse_upload_buttons.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/widgets/group_corporate_structure.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/widgets/image_row.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/widgets/rating_dropdown.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/widgets/selected_files_list.dart';

import 'model.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<AppendixViewModel>()..init(context);

    return BlocBuilder<AppendixViewModel, AppendixState>(
      builder: (context, state) {
        return Layout(child: _body(context, state, viewModel));
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
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: BoxLayout(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomSectionHeader(
                    title: 'eDigitalFilingFileAttachments.appendix.sectionTitle'
                        .tr()),
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
                  title: 'eDigitalFilingFileAttachments.appendix.sectionTitle'
                      .tr()),
              const Gap(),

              // Dropdown to choose section type
              BoxLayout(
                child: LabelWidget(
                  label: 'eDigitalFilingFileAttachments.appendix.customerType'
                      .tr(),
                  isRequired: true,
                  child: CustomDropdown<String>(
                    width: 320,
                    semanticLabel: 'Select Section Type',
                    showClearIcon: false,
                    items: const ['Country', 'Below Investment Grade - Bank'],
                    hintText: 'Select Section',
                    selectedItems: [viewModel.selectedSectionType],
                    onSelected: (labels) {
                      if (labels.isNotEmpty) {
                        viewModel.updateSelectedSectionType(labels.first);
                      }
                    },
                  ),
                ),
              ),

              const Gap(),

              // Conditionally show Financial Section
              if (viewModel.selectedSectionType ==
                  'Below Investment Grade - Bank') ...[
                Row(
                  children: [
                    CustomSectionHeader(
                      title:
                          'eDigitalFilingFileAttachments.appendix.fiBankAnnexures'
                              .tr(),
                    ), const Gap(direction: Axis.horizontal,) ,const CustomTooltip(
                                            // isRichMessage: widget.isRichMessage,
                                            message: "The excel uploaded from Bank Scope or the image uploaded with Key Financial Figures will be populated under Section 8 of Credit Memo – below investment grade banks ",
                                            textAlign: TextAlign.start,
                                            child: Icon(
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
                       
                      LabelWidget(
                        label: "eDigitalFilingFileAttachments.appendix.keyFinancialFiguresExtracted".tr(),
                        child: Column(
                          children: [
                            if (viewModel.selectedFiles.isNotEmpty)
                        SelectedFilesList(viewModel: viewModel),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'eDigitalFilingFileAttachments.appendix.allowedExt'
                                      .tr(),
                                  style:
                                      const TextStyle(color: AppColors.darkTooltip,fontSize: AppStyle.fontSizeSmall),
                                ),
                                const Gap(),
                                browseUploadButtonWidget(context, viewModel),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Gap(size: GapSize.large,),                const Gap(),

                      
                      LabelWidget(
                        label: "eDigitalFilingFileAttachments.appendix.uploadKeyFinancialfigures".tr(),
                        child: Column(
                          children: [
                            if (viewModel.selectedFiles.isNotEmpty)
                        SelectedFilesList(viewModel: viewModel),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'eDigitalFilingFileAttachments.appendix.allowedImgExt'
                                      .tr(),
                                  style:
                                      const TextStyle(color: AppColors.darkTooltip,fontSize: AppStyle.fontSizeSmall ),
                                ),
                                const Gap(),
                                browseUploadButtonWidget(context, viewModel),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]

              // Conditionally show Financial CF Section
              else if (viewModel.selectedSectionType == 'Country') ...[
                Row(
                  children: [
                    CustomSectionHeader(
                      title:
                          'eDigitalFilingFileAttachments.appendix.fiCountryAnnexures'
                              .tr(),
                    ), const Gap(direction: Axis.horizontal,) ,
                    const CustomTooltip(
                                            // isRichMessage: widget.isRichMessage,
                                            message: "The images/details provided here will be populated under Country Overview and Country Government Key Indicator sections in the Country Paper Form ",
                                            textAlign: TextAlign.start,
                                            child: Icon(
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
                          Expanded(
                              child: CountryNameField(viewModel: viewModel)),
                          const Gap(direction: Axis.horizontal),
                          Expanded(
                              child: PopulationField(viewModel: viewModel)),
                          const Gap(direction: Axis.horizontal),
                          Expanded(child: GDPField(viewModel: viewModel)),
                        ],
                      ),
                      const Gap(),
                      Row(children: [
                        Expanded(
                          child: CustomCountryRatingDropdown(
                            selectedRating: viewModel.rating,
                            ratingOptions: kCountryRatings,
                            onRatingChange: (value) {
                              viewModel.setRating(value);
                            },
                          ),
                        ), const Gap(direction: Axis.horizontal),
                        Expanded(
                          child: LabelWidget(
                            label:
                                'eDigitalFilingFileAttachments.appendix.importPartners'
                                    .tr(),
                            isRequired: true,
                            child: CustomMultiSelectDropdown<String>(
                              hintText: 'Select',
                              semanticLabel:
                                  'eDigitalFilingFileAttachments.appendix.importPartners'
                                      .tr(),
                              items: viewModel.countryNames,
                              key: ValueKey(
                                  'import-${viewModel.selectedImportPartners.join(',')}'),
                              selectedItems: viewModel.selectedImportPartners,
                              onSelected: viewModel.updateImportPartners,
                              dropdownBuilder: (context, selected) {
                                if (selected == null || selected.isEmpty) {
                                  return const SizedBox();
                                }
                                final controller = ScrollController();
                                return multiSelectDropDownBuilderWidget(
                                  data: selected,
                                  controller: controller,
                                  height: 72,
                                  spacing: 4,
                                  runSpacing: 4,
                                  itemBuilder: (index) {
                                    final label = selected[index];
                                    return Chip(
                                      label: Text(label),
                                      onDeleted: () {
                                        final newList =
                                            List<String>.from(selected);
                                        newList.removeAt(index);
                                        viewModel.updateImportPartners(newList);
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ), const Gap(direction: Axis.horizontal),
                        // const Gap(
                        //   direction: Axis.horizontal,
                        // ),
                        Expanded(
                          child: LabelWidget(
                            label:
                                'eDigitalFilingFileAttachments.appendix.exportPartners'
                                    .tr(),
                            isRequired: true,
                            child: CustomMultiSelectDropdown<String>(
                              hintText: 'Select',
                              semanticLabel:
                                  'eDigitalFilingFileAttachments.appendix.exportPartners'
                                      .tr(),
                              items: viewModel.countryNames,
                              key: ValueKey(
                                  'export-${viewModel.selectedExportPartners.join(',')}'),
                              selectedItems: viewModel.selectedExportPartners,
                              onSelected: viewModel.updateExportPartners,
                              dropdownBuilder: (context, selected) {
                                if (selected == null || selected.isEmpty) {
                                  return const SizedBox();
                                }
                                final controller = ScrollController();
                                return multiSelectDropDownBuilderWidget(
                                  data: selected,
                                  controller: controller,
                                  height: 72,
                                  spacing: 4,
                                  runSpacing: 4,
                                  itemBuilder: (index) {
                                    final label = selected[index];
                                    return Chip(
                                      label: Text(label),
                                      onDeleted: () {
                                        final newList =
                                            List<String>.from(selected);
                                        newList.removeAt(index);
                                        viewModel.updateExportPartners(newList);
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ]),
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
                                  label:
                                      'eDigitalFilingFileAttachments.appendix.strengths'
                                          .tr(),
                                  viewModel: viewModel,
                                  onRemove: viewModel.removeStrengthTableRow,
                                  onUpdate: (index, value) {
                                    viewModel.strengths![index] = value;
                                    viewModel
                                        .updateStrengths(viewModel.strengths!);
                                  },
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: AddItemButton(
                                    onTap: () {
                                      viewModel.fieldValues;
                                      viewModel.fieldValues.add('');
                                      viewModel.updateStrengths(
                                          viewModel.fieldValues); // or threats
                                    },
                                    isLeftSided: true,
                                    child: Text(
                                      'eDigitalFilingFileAttachments.appendix.addStrength'
                                          .tr(),
                                      style: const TextStyle(
                                          fontSize: AppStyle.fontSizeSmall),
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
                                  label:
                                      'eDigitalFilingFileAttachments.appendix.threats'
                                          .tr(),
                                  viewModel: viewModel,
                                  onRemove: viewModel.removeThreatTableRow,
                                  onUpdate: (index, value) {
                                    viewModel.threats![index] = value;
                                    viewModel.updateThreats(viewModel.threats!);
                                  },
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: AddItemButton(
                                    onTap: viewModel.addThreatTableRow,
                                    isLeftSided: true,
                                    child: Text(
                                      semanticsLabel:
                                          'eDigitalFilingFileAttachments.appendix.addThreats'
                                              .tr(),
                                      'eDigitalFilingFileAttachments.appendix.addThreats'
                                          .tr(),
                                      style: const TextStyle(
                                          fontSize: AppStyle.fontSizeSmall),
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
                          title:
                              'eDigitalFilingFileAttachments.appendix.ratingBarImage'
                                  .tr(),
                          viewModel: viewModel,
                          context: context,
                        ),
                      ),
                      const Gap(),
                      BoxLayout(
                        child: ImageRow(
                          title:
                              'eDigitalFilingFileAttachments.appendix.countryMapImage'
                                  .tr(),
                          viewModel: viewModel,
                          context: context,
                        ),
                      ),
                      const Gap(),
                      BoxLayout(
                        child: ImageRow(
                          title:
                              'eDigitalFilingFileAttachments.appendix.governmentIndicatorsImage'
                                  .tr(),
                          viewModel: viewModel,
                          context: context,
                        ),
                      ),
                      const Gap(size: GapSize.large),
                      Align(
                        alignment: Alignment.centerRight,
                        child: CustomButton(
                          label: 'eDigitalFilingFileAttachments.appendix.save'
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
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
