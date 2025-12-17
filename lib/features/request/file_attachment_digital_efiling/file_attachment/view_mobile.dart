import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/widgets/document_list.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/widgets/actions.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/widgets/file_tree_access.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/widgets/uploaded_file_details.dart';

import 'fields/application_id_field.dart';
import 'fields/date_field.dart';
import 'fields/language_field.dart';
import 'fields/sub_sub_type_credit_field.dart';
import 'fields/sub_type_credit_field.dart';
import 'fields/document_name_field.dart';
import 'fields/group_rim_field.dart';
import 'model.dart';
import 'state.dart';
import 'fields/company_rim_field.dart';
import 'fields/document_type_field.dart';
import 'fields/sub_sub_type_financial_field.dart';
import 'fields/sub_sub_sub_type_credit_field.dart';
import 'fields/sub_type_credit_lens_field.dart';
import 'fields/sub_type_financial_field.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    // Scale.setup(context, const Size(1080, 1));
    final viewModel = context.read<FileAttachmentViewModel>();
    return BlocBuilder<FileAttachmentViewModel, FileAttachmentState>(
        builder: (context, state) {
      return Layout(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: BoxLayout(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(
                  title: "eDigitalFilingFileAttachments.fileAttachments.title"
                      .tr()),
              const Gap(),
              BoxLayout(
                child: TopSectionDetails(request: Globals.request!),
              ),
              BoxLayout(
                child: _body(context, state, viewModel),
              ),
            ],
          )),
        ),
      );
    });
  }

  Widget _body(BuildContext context, FileAttachmentState state,
      FileAttachmentViewModel viewModel) {
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
        return _buildView(viewModel, context);
    }
  }

  Widget _buildView(FileAttachmentViewModel viewModel, BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Gap(),
      if (viewModel.state.showUploadButton ?? false)
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          CustomButton(
            label: "eDigitalFilingFileAttachments.fileAttachments.uploadFiles"
                .tr(),
            onPressed: () => viewModel.showUploadForm(),
          ),
        ]),
      const Gap(),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FileAccessTree(viewModel.fileAccesses, viewModel),
          const Gap(
            direction: Axis.horizontal,
          ),
          Expanded(
            child: Visibility(
              visible: viewModel.state.showUploadForm ?? false,
              child: BoxLayout(
                child: Form(
                  key: viewModel.formKey,
                  child: Column(
                    children: [
                      DocumentTypeField(
                        label:
                            "eDigitalFilingFileAttachments.fileAttachments.documentType"
                                .tr(),
                        viewModel: viewModel,
                      ),
                      if (viewModel.request.isGroupRequest)
                        GroupRimField(viewModel: viewModel),
                      CompanyRimField(
                        viewModel: viewModel,
                      ),
                      if (viewModel.isConstitutionalDocumentsSelected() ||
                          viewModel.isExternalOpinionsSelected() ||
                          viewModel.isOthersSelected()) ...[
                        ApplicationIdField(
                          viewModel: viewModel,
                        ),
                        DateField(
                          label:
                              "eDigitalFilingFileAttachments.fileAttachments.date"
                                  .tr(),
                          viewModel: viewModel,
                        ),
                        DocumentNameField(
                            initialValue: "",
                            isRequired: viewModel.isCreditApplicationSelected()
                                ? false
                                : true,
                            onSaved: (value) =>
                                viewModel.updateDocumentName(value)),
                      ],
                      if (viewModel.isCreditApplicationSelected()) ...[
                        SubTypeCreditField(viewModel: viewModel),
                        SubSubTypeCreditField(viewModel: viewModel),
                        SubSubSubTypeCreditField(
                            label:
                                "eDigitalFilingFileAttachments.fileAttachments.subSubSubType"
                                    .tr(),
                            viewModel: viewModel),
                      ],
                      if (viewModel.isCreditLensSelected()) ...[
                        SubTypeCreditLensField(
                          label:
                              "eDigitalFilingFileAttachments.fileAttachments.subType"
                                  .tr(),
                          viewModel: viewModel,
                        ),
                        ApplicationIdField(
                          viewModel: viewModel,
                        ),
                        DateField(
                          label:
                              "eDigitalFilingFileAttachments.fileAttachments.periodEndDate"
                                  .tr(),
                          viewModel: viewModel,
                        ),
                      ],
                      if (viewModel.isFinancialStatementsSelected()) ...[
                        SubTypeFinancialField(viewModel: viewModel),
                        SubSubTypeFinancialField(
                            label:
                                "eDigitalFilingFileAttachments.fileAttachments.subSubType"
                                    .tr(),
                            viewModel: viewModel),
                        ApplicationIdField(
                          viewModel: viewModel,
                        ),
                      ],
                      if (viewModel.isCreditApplicationSelected()) ...[
                        ApplicationIdField(
                          viewModel: viewModel,
                        ),
                        DateField(
                          label:
                              "eDigitalFilingFileAttachments.fileAttachments.date"
                                  .tr(),
                          viewModel: viewModel,
                          readOnly: true,
                          initialDateTime: DateTime.now(),
                        ),
                        DocumentNameField(
                            isRequired: viewModel.isCreditApplicationSelected()
                                ? false
                                : true,
                            initialValue: "",
                            onSaved: (value) =>
                                viewModel.updateDocumentName(value)),
                      ],
                      if (viewModel.isFinancialStatementsSelected()) ...[
                        DateField(
                          label:
                              "eDigitalFilingFileAttachments.fileAttachments.periodEndDate"
                                  .tr(),
                          viewModel: viewModel,
                        ),
                        LanguageField(
                          viewModel: viewModel,
                          label:
                              "eDigitalFilingFileAttachments.fileAttachments.language"
                                  .tr(),
                        ),
                        if (viewModel.selectedSubSubType?.id ==
                            ServerConstants.subSubTypeFinancialProjection)
                          DocumentNameField(
                              isRequired:
                                  viewModel.isCreditApplicationSelected()
                                      ? false
                                      : true,
                              initialValue: "",
                              onSaved: (value) =>
                                  viewModel.updateDocumentName(value)),
                      ],
                      const Gap(),
                      saveCancelButtonWidget(context, viewModel),
                      const Gap(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      const Gap(
        size: GapSize.large,
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        CustomSelectableText(
          text:
              "eDigitalFilingFileAttachments.fileAttachments.uploadedFileDetails"
                  .tr(),
          textAlign: TextAlign.left,
          style: AppStyle.tableHeaderStyle,
        ),
      ]),
      const Gap(),
      UploadedFileDetails(
        viewModel: viewModel,
      ),
      const Gap(
        size: GapSize.large,
      ),
      CustomSectionHeader(
          title:
              "eDigitalFilingFileAttachments.fileAttachments.digitalFilingView"
                  .tr()),
      const Gap(),
      rimListAccordian(viewModel),
      const Gap(),
      actionButtons(viewModel, context),
      const Gap(),
    ]);
  }
}
