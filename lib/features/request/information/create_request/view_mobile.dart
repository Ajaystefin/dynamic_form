import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/information/create_request/fields/application_type.dart';
import 'package:wcas_frontend/features/request/information/create_request/fields/business_segment.dart';
import 'package:wcas_frontend/features/request/information/create_request/fields/customer_name.dart';
import 'package:wcas_frontend/features/request/information/create_request/fields/customer_rim_no.dart';
import 'package:wcas_frontend/features/request/information/create_request/fields/customer_type.dart';
import 'package:wcas_frontend/features/request/information/create_request/fields/group_id.dart';
import 'package:wcas_frontend/features/request/information/create_request/fields/group_name.dart';
import 'package:wcas_frontend/features/request/information/create_request/fields/request_type.dart';
import 'package:wcas_frontend/features/request/information/create_request/widgets/action_widgets.dart';
import 'package:wcas_frontend/features/request/information/create_request/widgets/select_dialog.dart';

import 'model.dart';
import 'state.dart';

class ViewMobile extends StatefulWidget {
  const ViewMobile({super.key});

  @override
  State<ViewMobile> createState() => _ViewMobileState();
}

class _ViewMobileState extends State<ViewMobile> {
  @override
  Widget build(BuildContext context) {
    CreateRequestViewModel viewModel = context.read<CreateRequestViewModel>();
    return BlocConsumer<CreateRequestViewModel, CreateRequestState>(
        listener: (context, state) {
      if (state.showSelectDialog) {
        DialogHelper.showCustomDialog(
            barrierDismissible: false,
            onClosePressed: () {
              Navigator.pop(context);
              viewModel.onSelectionCancelButtonPress();
            },
            context: context,
            content: SelectDialog(
              viewModel: viewModel,
            ),
            title: viewModel.isGroupNameSelection
                ? "requestInformation.createRequest.selectGroupName".tr()
                : "requestInformation.createRequest.selectCustomerName".tr());
      }
    }, builder: (context, state) {
      return Scaffold(
        body: SingleChildScrollView(child: _body(context, state, viewModel)),
      );
    });
  }

  Widget _body(BuildContext context, CreateRequestState state,
      CreateRequestViewModel viewModel) {
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
        return _buildWidgets(viewModel);
    }
  }

  final FocusNode formFocusNode = FocusNode();
  @override
  void dispose() {
    formFocusNode.dispose();
    super.dispose();
  }

  Widget _buildWidgets(CreateRequestViewModel viewModel) {
    return BoxLayout(
      child: Focus(
        focusNode: formFocusNode,
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: AppStyle.spacing),
                child: CustomSectionHeader(
                    title: "requestInformation.createRequest.createNewRequest"
                        .tr()),
              ),
              BoxLayout(
                child: ValueListenableBuilder<Map<ControlFields, bool>>(
                    valueListenable: viewModel.fieldCntrl,
                    builder: (context, contrlValue, _) {
                      return Column(
                        spacing: AppStyle.spacing,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BussinessSegmentField(viewModel: viewModel),
                          if (viewModel.iFinancialInstitutionSelected())
                            CustomerTypeField(viewModel: viewModel),
                          RequestTypeField(viewModel: viewModel),
                          ApplicationTypeField(viewModel: viewModel),
                          CustomerRimNoField(viewModel: viewModel),
                          CustomerNameField(viewModel: viewModel),
                          GroupIdField(viewModel: viewModel),
                          GroupNameField(viewModel: viewModel),
                          const SizedBox(height: 20),
                          ActionWidgets(viewModel: viewModel),
                          const SizedBox(height: 20),
                        ],
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
