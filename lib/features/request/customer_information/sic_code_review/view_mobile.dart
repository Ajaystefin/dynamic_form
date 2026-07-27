import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/customer_dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/fields/account_level_sic_code.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/fields/action.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/fields/sic_code_table.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/model.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/state.dart";
import "package:wcas_frontend/models/request/request.dart";

/// Mobile view for the SIC code review screen.
class ViewMobile extends StatelessWidget {
  /// Creates the mobile view.
  const ViewMobile({super.key});

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

  /// Builds the main SIC code review mobile view.
  Widget buildView(SicCodeReviewState state, SicCodeReviewViewModel viewModel) {
    return SingleChildScrollView(
      child: BoxLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSectionHeader(
              title: "customerInformation.sicCodeReview.title".tr(),
            ),
            const Gap(),
            BoxLayout(
              child: TopSectionDetails(
                request: viewModel.request ?? Request(),
              ),
            ),
            BoxLayout(
              disabled:
                  !viewModel.canEdit && !viewModel.otherCACCPBDPRolesCheck(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (Utils.isGroupApplication())
                    CustomCustomerDropdown(
                      ignoreProvider: true,
                      onCustomerChange: (customer) =>
                          viewModel.onCustomerSeletion(customer),
                      selectedCustomer: (viewModel.customerList ?? []).isEmpty
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
                  ActionButton(viewModel: viewModel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
