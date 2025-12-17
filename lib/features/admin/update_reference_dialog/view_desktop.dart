import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/form_row.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/admin/update_reference_dialog/fields/data_id.dart';
import 'package:wcas_frontend/features/admin/update_reference_dialog/fields/description.dart';
import 'package:wcas_frontend/features/admin/update_reference_dialog/fields/name.dart';
import 'package:wcas_frontend/features/admin/update_reference_dialog/fields/reference_1.dart';
import 'package:wcas_frontend/features/admin/update_reference_dialog/fields/reference_2.dart';
import 'package:wcas_frontend/features/admin/update_reference_dialog/fields/reference_3.dart';
import 'package:wcas_frontend/features/admin/update_reference_dialog/fields/reference_4.dart';
import 'package:wcas_frontend/features/admin/update_reference_dialog/fields/reference_5.dart';
import 'package:wcas_frontend/features/admin/update_reference_dialog/fields/reference_status.dart';
import 'package:flutter/material.dart';
import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    UpdateReferenceDialogViewModel viewModel =
        context.read<UpdateReferenceDialogViewModel>();
    return BlocBuilder<UpdateReferenceDialogViewModel,
        UpdateReferenceDialogState>(builder: (context, state) {
      return _body(context, state, viewModel);
    });
  }

  Widget _body(BuildContext context, UpdateReferenceDialogState state,
      UpdateReferenceDialogViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text('common.emptyState'.tr()),
        );
      default:
        return Focus(
          focusNode: viewModel.formFocusNode,
          child: SingleChildScrollView(
            child: BoxLayout(
              extraPadding: true,
              child: Form(
                key: viewModel.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(),
                    FormRow(
                      children: [
                        DataId(viewModel: viewModel),
                        Name(viewModel: viewModel),
                        Description(viewModel: viewModel),
                      ],
                    ),
                    const Gap(),
                    FormRow(
                      children: [
                        Reference1(viewModel: viewModel),
                        Reference2(viewModel: viewModel),
                        Reference3(viewModel: viewModel),
                      ],
                    ),
                    const Gap(),
                    FormRow(
                      children: [
                        Reference4(viewModel: viewModel),
                        Reference5(viewModel: viewModel),
                        ReferenceStatus(viewModel: viewModel),
                      ],
                    ),
                    const Gap(),
                    _onSaveCancelButtonWidget(viewModel, context, state),
                  ],
                ),
              ),
            ),
          ),
        );
    }
  }

  Row _onSaveCancelButtonWidget(UpdateReferenceDialogViewModel viewModel,
      BuildContext context, UpdateReferenceDialogState state) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      CustomButton(
          label: "common.save".tr(),
          semanticLabel: "common.save".tr(),
          isLoading:
              state.saveButtonStatus == LoadingStatus.loading ? true : false,
          onPressed: () {
            viewModel.onSaveButtonClick(context);
          }),
      const Gap(direction: Axis.horizontal),
      CustomButton(
          label: "common.cancel".tr(),
          semanticLabel: "common.cancel".tr(),
          onPressed: () {
            Navigator.of(context).pop(false);
          })
    ]);
  }
}
