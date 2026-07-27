import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/form_row.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/fields/comments.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/fields/limit_description.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/fields/limit_type.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/fields/nature_of_fund.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/fields/product_code.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/fields/product_type.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/fields/subtype.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/state.dart";

/// Desktop layout for displaying and managing the others limit dialog.
class ViewDesktop extends StatelessWidget {
  /// Creates a desktop others limit dialog view.
  const ViewDesktop({
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
          child: SingleChildScrollView(
            child: BoxLayout(
              extraPadding: true,
              child: Form(
                key: viewModel.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormRow(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProductType(viewModel: viewModel),
                        NatureOfFund(viewModel: viewModel),
                        LimitType(viewModel: viewModel),
                      ],
                    ),
                    const Gap(),
                    FormRow(
                      children: [
                        LimitDescription(viewModel: viewModel),
                        ProductCode(viewModel: viewModel),
                        Subtype(viewModel: viewModel),
                      ],
                    ),
                    const Gap(),
                    Comments(viewModel: viewModel),
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

  Row _onSaveCancelButtonWidget(
    OthersLimitDialogViewModel viewModel,
    BuildContext context,
    OthersLimitDialogState state,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          label: "facilities.facilitySummary.createFacilityBtn".tr(),
          semanticLabel: "common.save".tr(),
          isLoading: state.saveButtonStatus == LoadingStatus.loading,
          onPressed: () {
            viewModel.onSaveButtonClick(context);
          },
        ),
        const Gap(direction: Axis.horizontal),
        CustomButton(
          label: "common.cancel".tr(),
          semanticLabel: "common.cancel".tr(),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ],
    );
  }
}
