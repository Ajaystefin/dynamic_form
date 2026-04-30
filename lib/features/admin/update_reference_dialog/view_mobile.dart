import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/fields/data_id.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/fields/description.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/fields/name.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/fields/reference_1.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/fields/reference_2.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/fields/reference_3.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/fields/reference_4.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/fields/reference_5.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/fields/reference_status.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/model.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/state.dart";

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final UpdateReferenceDialogViewModel viewModel =
        context.read<UpdateReferenceDialogViewModel>();
    return BlocBuilder<UpdateReferenceDialogViewModel,
        UpdateReferenceDialogState>(
      builder: (context, state) {
        return _body(context, state, viewModel);
      },
    );
  }

  Widget _body(
    BuildContext context,
    UpdateReferenceDialogState state,
    UpdateReferenceDialogViewModel viewModel,
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
      default:
        return Focus(
          focusNode: viewModel.formFocusNode,
          child: Form(
            key: viewModel.formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BoxLayout(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 20,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: DataId(viewModel: viewModel)),
                            Expanded(child: Name(viewModel: viewModel)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          spacing: 20,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Description(viewModel: viewModel)),
                            Expanded(child: Reference1(viewModel: viewModel)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          spacing: 20,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Reference2(viewModel: viewModel)),
                            Expanded(child: Reference3(viewModel: viewModel)),
                          ],
                        ),
                        Row(
                          spacing: 20,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Reference4(viewModel: viewModel)),
                            Expanded(child: Reference5(viewModel: viewModel)),
                          ],
                        ),
                        ReferenceStatus(viewModel: viewModel),
                        const SizedBox(height: 30),
                        _onSaveCancelButtonWidget(viewModel, context, state),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  Row _onSaveCancelButtonWidget(
    UpdateReferenceDialogViewModel viewModel,
    BuildContext context,
    UpdateReferenceDialogState state,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 10,
      children: [
        CustomButton(
          label: "common.save".tr(),
          isLoading:
              state.saveButtonStatus == LoadingStatus.loading ? true : false,
          onPressed: () {
            viewModel.onSaveButtonClick(context);
          },
        ),
        CustomButton(
          label: "common.cancel".tr(),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
