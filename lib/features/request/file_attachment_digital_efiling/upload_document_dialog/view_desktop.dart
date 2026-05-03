import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/form_row.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/fields/application_id_field.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/fields/attachment_date_field.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/fields/attachment_language_field.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/fields/company_rim_field.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/fields/document_name_field.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/fields/document_type_field.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/fields/entity_id_field.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/fields/group_rim_field.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/fields/sub_sub_type_financial_field.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/fields/sub_type_credit_lens_field.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/fields/sub_type_financial_field.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/model.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/state.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/widgets/browse_upload_buttons.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/widgets/selected_files_list.dart";

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final UploadDocumentDialogViewModel viewModel =
        context.read<UploadDocumentDialogViewModel>();
    return BlocBuilder<UploadDocumentDialogViewModel,
        UploadDocumentDialogState>(
      builder: (context, state) {
        return _body(context, state, viewModel);
      },
    );
  }

  Widget _body(
    BuildContext context,
    UploadDocumentDialogState state,
    UploadDocumentDialogViewModel viewModel,
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
        return _buildView(context, state, viewModel);
    }
  }

  Widget _buildView(
    BuildContext context,
    UploadDocumentDialogState state,
    UploadDocumentDialogViewModel viewModel,
  ) {
    return SingleChildScrollView(
      child: Form(
        key: viewModel.formKey,
        child: BoxLayout(
          child: Column(
            children: [
              FormRow(
                children: [
                  DocumentTypeField(
                    label: "eDigitalFilingFileAttachments."
                            "fileAttachments.documentType"
                        .tr(),
                    viewModel: viewModel,
                  ),
                  if (Utils.isGroupApplication()) ...[
                    GroupRimField(viewModel: viewModel),
                    if (viewModel.selectedDocumentType != null)
                      CompanyRimField(viewModel: viewModel),
                  ] else ...[
                    if (viewModel.selectedDocumentType != null)
                      CompanyRimField(viewModel: viewModel),
                    const Gap(),
                  ],
                ],
              ),
              const Gap(),
              if (viewModel.isConstitutionalDocumentsSelected() ||
                  viewModel.isExternalOpinionsSelected() ||
                  viewModel.isOthersSelected())
                FormRow(
                  children: [
                    ApplicationIdField(
                      viewModel: viewModel,
                      onSaved: (value) => viewModel.updateApplicationId(value),
                    ),
                    AttachmentDateField(
                      label:
                          "eDigitalFilingFileAttachments.fileAttachments.date"
                              .tr(),
                      viewModel: viewModel,
                    ),
                    DocumentNameField(
                      isRequired: true,
                      initialValue: "",
                      viewModel: viewModel,
                      onSaved: (value) => viewModel.updateDocumentName(value),
                    ),
                  ],
                ),
              if (viewModel.isConstitutionalDocumentsSelected() ||
                  viewModel.isExternalOpinionsSelected() ||
                  viewModel.isOthersSelected())
                const Gap(),
              if (viewModel.isCreditLensSelected())
                FormRow(
                  children: [
                    SubTypeCreditLensField(
                      label: "eDigitalFilingFileAttachments."
                              "fileAttachments.subType"
                          .tr(),
                      viewModel: viewModel,
                    ),
                    ApplicationIdField(
                      viewModel: viewModel,
                      onSaved: (value) => viewModel.updateApplicationId(value),
                    ),
                    AttachmentDateField(
                      label: "eDigitalFilingFileAttachments."
                              "fileAttachments.periodEndDate"
                          .tr(),
                      viewModel: viewModel,
                    ),
                  ],
                ),
              if (viewModel.isCreditLensSelected()) const Gap(),
              if (viewModel.isFinancialStatementsSelected())
                FormRow(
                  children: [
                    SubTypeFinancialField(viewModel: viewModel),
                    SubSubTypeFinancialField(
                      label: "eDigitalFilingFileAttachments."
                              "fileAttachments.subSubType"
                          .tr(),
                      viewModel: viewModel,
                    ),
                    ApplicationIdField(
                      viewModel: viewModel,
                      onSaved: (value) => viewModel.updateApplicationId(value),
                    ),
                  ],
                ),
              if (viewModel.isFinancialStatementsSelected()) const Gap(),
              if (viewModel.isFinancialStatementsSelected()) ...[
                FormRow(
                  children: [
                    AttachmentDateField(
                      label: "eDigitalFilingFileAttachments."
                              "fileAttachments.periodEndDate"
                          .tr(),
                      viewModel: viewModel,
                    ),
                    AttachmentLanguageField(
                      viewModel: viewModel,
                      label: "eDigitalFilingFileAttachments."
                              "fileAttachments.language"
                          .tr(),
                    ),
                    if (viewModel.selectedSubSubTypeFinancial?.id ==
                        ServerConstants.subSubTypeFinancialProjection)
                      DocumentNameField(
                        isRequired: true,
                        initialValue: "",
                        viewModel: viewModel,
                        onSaved: (value) => viewModel.updateDocumentName(value),
                      )
                    else
                      const Gap(),
                  ],
                ),
                const Gap(),
                if (viewModel.selectedLanguageType?.id ==
                        ServerConstants.languageEnglish ||
                    viewModel.selectedLanguageType?.id ==
                        ServerConstants.languageArabic)
                  FormRow(
                    children: [
                      EntityIdField(
                        isRequired: true,
                        initialValue: "",
                        viewModel: viewModel,
                        onSaved: (value) => viewModel.updateEntityId(value),
                      ),
                    ],
                  ),
              ],
              if (viewModel.selectedDocuments.isNotEmpty)
                SelectedFilesList(viewModel: viewModel),
              browseUploadButtonWidget(context, viewModel, state),
              const Gap(),
            ],
          ),
        ),
      ),
    );
  }
}
