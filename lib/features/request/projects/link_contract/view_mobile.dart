import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/contract_value.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/converted_contract_amount.dart';
import 'model.dart';
import 'state.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/borrower_search_name.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/search_header_section.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/search_rimno.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/actions.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/borrower_role.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/completion_percent.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/contract_scope.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/expected_end_date.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/expected_start_date.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/link_customer_name.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/link_customer_rim.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/paymaster_name.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/project_tenor.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});
  @override
  Widget build(BuildContext context) {
    LinkContractViewModel viewModel = context.read<LinkContractViewModel>();
    return BlocBuilder<LinkContractViewModel, LinkContractState>(
        builder: (context, state) {
      return Layout(
        child: _body(context, state, viewModel),
      );
    });
  }

  Widget _body(BuildContext context, LinkContractState state,
      LinkContractViewModel viewModel) {
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
        return SingleChildScrollView(
            child: BoxLayout(
                extraPadding: true,
                child: Focus(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      // Header + Back button
                      const SearchHeaderSection(),
                      const Gap(),
                      // RIM No | Name | Proceed
                      BoxLayout(
                        extraPadding: true,
                        child: Column(children: [
                          // 1) RIM No
                          SearchRimno(viewModel: viewModel),
                          // 2) Name
                          BorrowerSearchName(viewModel: viewModel),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: AppStyle.linkContractProceedButton),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: CustomButton(
                                label: "project.linkContract.proceed".tr(),
                                onPressed: () async {
                                  viewModel.onProceed();
                                },
                              ),
                            ),
                          ),
                        ]),
                      ),
                      const Gap(size: GapSize.large),
                      CustomSectionHeader(
                          title: "project.linkContract.title".tr()),
                      const Gap(size: GapSize.medium),
                      BoxLayout(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //rim + name + role
                            LinkCustomerName(viewModel: viewModel),
                            LinkCustomerRim(viewModel: viewModel),
                            BorrowerRole(viewModel: viewModel),
                            const Gap(),
                            //contract value + amount + converted amount
                            ContractValue(viewModel: viewModel),
                            if (viewModel.selectedCurrencyLabel != 'AED')
                              ConvertedContractAmount(viewModel: viewModel),
                            const Gap(),
                            //Paymaster Name
                            PaymasterName(viewModel: viewModel),
                            const Gap(),
                            //contract scope
                            ContractScope(viewModel: viewModel),
                            const Gap(),
                            // Dates + Tenor
                            ExpectedStartDate(viewModel: viewModel),
                            ExpectedEndDate(viewModel: viewModel),
                            ProjectTenor(viewModel: viewModel),
                            const Gap(),
                            //completion%
                            CompletionPercent(viewModel: viewModel),
                          ],
                        ),
                      ),
                      const Gap(size: GapSize.medium),
                      ActionsSection(viewModel: viewModel),
                      const Gap(size: GapSize.medium),
                    ]))));
    }
  }
}
