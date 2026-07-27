import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/fields/comments.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/fields/limit_description.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/fields/limit_type.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/fields/nature_of_fund.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/fields/product_type.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/fields/subtype.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/state.dart";

/// Mobile layout for displaying and managing the others limit dialog.
class ViewMobile extends StatelessWidget {
  /// Creates a mobile others limit dialog view.
  const ViewMobile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final OthersLimitDialogViewModel viewModel =
        context.read<OthersLimitDialogViewModel>();
    return BlocBuilder<OthersLimitDialogViewModel, OthersLimitDialogState>(
      builder: (context, state) {
        return _body(context, state, viewModel);
      },
    );
  }

  Widget _body(
    BuildContext context,
    OthersLimitDialogState state,
    OthersLimitDialogViewModel viewModel,
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
                            Expanded(child: LimitType(viewModel: viewModel)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          spacing: 20,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: LimitDescription(viewModel: viewModel),
                            ),
                            Expanded(child: ProductType(viewModel: viewModel)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          spacing: 20,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Subtype(viewModel: viewModel)),
                            Expanded(child: Comments(viewModel: viewModel)),
                          ],
                        ),
                        NatureOfFund(viewModel: viewModel),
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
    OthersLimitDialogViewModel viewModel,
    BuildContext context,
    OthersLimitDialogState state,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 10,
      children: [
        CustomButton(
          label: "common.save".tr(),
          isLoading: state.saveButtonStatus == LoadingStatus.loading,
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
