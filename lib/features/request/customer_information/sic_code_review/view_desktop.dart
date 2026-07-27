import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/customer_dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/fields/account_level_sic_code.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/fields/action.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/fields/sic_code_table.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/model.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/state.dart";
import "package:wcas_frontend/models/request/request.dart";

/// Desktop view for the SIC code review screen.
class ViewDesktop extends StatelessWidget {
  /// Creates the desktop view.
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final SicCodeReviewViewModel viewModel =
        context.read<SicCodeReviewViewModel>();
    return BlocBuilder<SicCodeReviewViewModel, SicCodeReviewState>(
      builder: (context, state) {
        return Layout(
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    SicCodeReviewState state,
    SicCodeReviewViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.error:
        return Center(
          child: Text("common.errorState".tr()),
        );
      default:
        return buildView(state, viewModel);
    }
  }

  /// Builds the main SIC code review desktop view.
  Widget buildView(SicCodeReviewState state, SicCodeReviewViewModel viewModel) {
    return SingleChildScrollView(
      child: BoxLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(),
            CustomSectionHeader(
              title: "customerInformation.sicCodeReview.title".tr(),
            ),
            const Gap(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(),
                BoxLayout(
                  child: TopSectionDetails(
                    request: viewModel.request ?? Request(),
                  ),
                ),
                BoxLayout(
                  disabled: !viewModel.canEdit &&
                      !viewModel.otherCACCPBDPRolesCheck(),
                  child: Form(
                    key: viewModel.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (Utils.isGroupApplication())
                          CustomCustomerDropdown(
                            ignoreProvider: true,
                            onCustomerChange: (customer) =>
                                viewModel.onCustomerSeletion(customer),
                            selectedCustomer:
                                (viewModel.customerList ?? []).isEmpty
                                    ? viewModel.selectedCustomer
                                    : viewModel.customerList?.first ??
                                        viewModel.selectedCustomer,
                            customerList: viewModel.customerList,
                            onRefresh: () {},
                            // viewModel.onRefreshButtonPressed(context),
                          )
                        else
                          const SizedBox(),
                        const Gap(),
                        SicCodeTableField(
                          viewModel: viewModel,
                        ),
                        const Gap(),
                        AccountLevelSicCode(
                          viewModel: viewModel,
                        ),
                        const Gap(),
                        if (!Utils.checkApplicationType(
                          ApplicationType.cancellation,
                        ))
                          ActionButton(viewModel: viewModel),
                      ],
                    ),
                  ),
                ),
                if (Utils.checkApplicationType(
                      ApplicationType.cancellation,
                    ) &&
                    !viewModel.canEdit &&
                    !viewModel.otherCACCPBDPRolesCheck())
                  Padding(
                    padding: const EdgeInsets.all(AppStyle.spacing),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButton(
                          semanticLabel:
                              "customerInformation.customerInformation.continue",
                          label:
                              "customerInformation.customerInformation.continue"
                                  .tr(), // "Save & Continue",
                          onPressed: () async {
                            LayoutViewModel().goToNextRoute();
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
