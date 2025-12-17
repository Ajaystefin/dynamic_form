import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/form_row.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/fields/customer_name_field.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/fields/customer_rim_field.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/fields/group_name_field.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/fields/group_rim_field.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/widgets/accordian_rim_list.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/widgets/actions.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/fields/application_id_field.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/widgets/select_dialog.dart';

import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    DigitalEfilingViewModel viewModel = context.read<DigitalEfilingViewModel>();
    return BlocConsumer<DigitalEfilingViewModel, DigitalEfilingState>(
        listener: (context, state) {
      if (state.showSelectDialog) {
        DialogHelper.showCustomDialog(
            barrierDismissible: false,
            onClosePressed: () {
              Navigator.pop(context);
              viewModel.onSelectionCancelButtonPress();
            },
            context: context,
            width: context.isDesktop ? 600.w : null,
            content: SelectDialog(
              viewModel: viewModel,
            ),
            title: viewModel.isGroupNameSelection
                ? "requestInformation.createRequest.selectGroupName".tr()
                : "requestInformation.createRequest.selectCustomerName".tr());
      }
    }, builder: (context, state) {
      return Scaffold(
        body: Layout(
          hideSideMenu: true,
          child: BoxLayout(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: BoxLayout(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _body(context, state, viewModel),
                ],
              )),
            ),
          ),
        ),
      );
    });
  }

  Widget _body(BuildContext context, DigitalEfilingState state,
      DigitalEfilingViewModel viewModel) {
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
        return _buildView(viewModel, context, state);
    }
  }

  Widget _buildView(
    DigitalEfilingViewModel viewModel,
    BuildContext context,
    DigitalEfilingState state,
  ) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Gap(),
      CustomSectionHeader(
          title: "eDigitalFilingFileAttachments.digitalEfiling.title".tr()),
      const Gap(),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: BoxLayout(
                child: Form(
                    key: viewModel.formKey,
                    child: Column(
                      children: [
                        _buildRowWidgets([
                          GroupIdField(viewModel: viewModel),
                          GroupNameField(viewModel: viewModel)
                        ]),
                        const Gap(),
                        _buildRowWidgets([
                          CustomerRimNoField(
                            viewModel: viewModel,
                          ),
                          CustomerNameField(
                            viewModel: viewModel,
                          ),
                        ]),
                        FormRow(
                          children: [
                            ApplicationIdField(
                              controller: viewModel.applicationIdController,
                              onSaved: viewModel.updateApplicationId,
                              readOnly: false,
                            ),
                            const SizedBox()
                          ],
                        ),
                        const Gap(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomButton(
                                onPressed: () {
                                  viewModel.onResetButtonPress();
                                },
                                label: "requestInformation.createRequest.reset"
                                    .tr(),
                              ),
                              const Gap(
                                direction: Axis.horizontal,
                              ),
                              CustomButton(
                                isLoading: state.searchLoaderStatus ==
                                        LoadingStatus.loading
                                    ? true
                                    : false,
                                onPressed: () async {
                                  viewModel.formKey.currentState?.save();
                                  // bool isValidate = viewModel
                                  //         .formKey.currentState
                                  //         ?.validate() ??
                                  // false;
                                  viewModel.doSearch();
                                },
                                label:
                                    'eDigitalFilingFileAttachments.digitalEfiling.search'
                                        .tr(),
                              ),
                            ])
                      ],
                    ))),
          ),
        ],
      ),
      if (viewModel.isSearched && viewModel.fileUploadDatas.isNotEmpty)
        const Gap(size: GapSize.large),
      if (viewModel.isSearched && viewModel.fileUploadDatas.isNotEmpty)
        CustomSectionHeader(
            title:
                "eDigitalFilingFileAttachments.digitalEfiling.digitalFilingView"
                    .tr()),
      if (viewModel.isSearched && viewModel.fileUploadDatas.isNotEmpty)
        const Gap(),
      if (viewModel.isSearched && viewModel.fileUploadDatas.isNotEmpty)
        rimListAccordian(viewModel),
      if (viewModel.isSearched && viewModel.fileUploadDatas.isNotEmpty)
        const Gap(),
      if (viewModel.isSearched && viewModel.fileUploadDatas.isNotEmpty)
        actionButtons(viewModel, context),
      const Gap(),
    ]);
  }

  //function to show two widgets in a row with responsive size
  Widget _buildRowWidgets(List<Widget> childrens) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
          spacing: AppStyle.spacingLarge, // Add spacing between the widgets
          children: List.generate(
              childrens.length,
              (index) => Expanded(
                    child: childrens[index],
                  ))),
    );
  }
}
