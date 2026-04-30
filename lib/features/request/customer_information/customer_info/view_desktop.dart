import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/customer_dropdown.dart";
import "package:wcas_frontend/core/components/form_row.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/action.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/address_line_one.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/address_line_three.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/address_line_two.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/borrowing_relationship_from.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/cbd_cbrb_classification.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/cbd_relationship_start_date.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/ccc_status.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/consolidated_cbrb.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/correspondence_address.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/countries_of_bussiness_operation.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/countries_traded_with.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/country_of_incorporation.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/country_of_risk.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/date_of_establishment.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/deviation_breach_justification.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/email_address.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/exception_table.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/fi_bank_proposed_limit.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/fi_category.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/fi_country_rank.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/fi_world_rank.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/ifrs_staging.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/industry_description.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/industry_sic_code.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/legal_status.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/location_address_title.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/ownership_details_table.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/phone.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/po_box.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/policy_deviations.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/primary_business_activity.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/proposed_sic_code.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/reason_for_deferral_waiver.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/trade_licence_expiry_date.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/trade_licence_issuing_authority.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/fields/trade_licence_no.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/state.dart";

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final CustomerInfoViewModel viewModel =
        context.read<CustomerInfoViewModel>();

    return BlocBuilder<CustomerInfoViewModel, CustomerInfoState>(
      builder: (context, state) {
        return Layout(
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    CustomerInfoState state,
    CustomerInfoViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case LoadingStatus.error:
        return const Center(
          child: CircularProgressIndicator(),
        );
      default:
        return buildView(context, state, viewModel);
    }
  }

  Widget buildView(
    BuildContext context,
    CustomerInfoState state,
    CustomerInfoViewModel viewModel,
  ) {
    return SingleChildScrollView(
      child: BoxLayout(
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(
                title: "customerInformation."
                        "customerInformation.customerInformation"
                    .tr(),
              ),
              const Gap(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BoxLayout(
                    child: TopSectionDetails(request: Globals.request!),
                  ),
                  BoxLayout(
                    extraPadding: true,
                    child: Column(
                      children: [
                        CustomCustomerDropdown(
                          onCustomerChange: (customer) =>
                              viewModel.onCustomerSeletion(customer),
                          selectedCustomer:
                              (viewModel.customerList ?? []).isEmpty
                                  ? viewModel.selectedCustomer
                                  : viewModel.customerList?.first ??
                                      viewModel.selectedCustomer,
                          customerList: viewModel.customerList,
                          onRefresh: () =>
                              viewModel.onRefreshButtonPressed(context),
                        ),
                        const Gap(),
                        buildUserNameChangeLoader(state, viewModel),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUserNameChangeLoader(
    CustomerInfoState state,
    CustomerInfoViewModel viewModel,
  ) {
    return switch (state.userNameChangeLoader) {
      LoadingStatus.loading => const Center(child: CircularProgressIndicator()),
      LoadingStatus.empty => const SizedBox.shrink(),
      _ => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(),
                        Builder(
              builder: (_) {
                // Extract key for line-length compliance
                const String custKey =
                    "customerInformation.customerInformation"
                    ".customerName";
                final String custName =
                    viewModel.customerInformation?.customerName ?? "";
                final String rimNo =
                    viewModel.customerInformation?.customerRimNo
                            ?.toString() ??
                        "";
                return CustomSelectableText(
                  semanticsLabel: "${custKey.tr()} : $custName ",
                  text: "${custKey.tr()} : $custName ($rimNo)",
                  style: AppStyle.boldLabel,
                );
              },
            ),
            const Gap(
              size: GapSize.large,
            ),
            FormRow(
              children: [
                TradeLicenceNoField(viewModel: viewModel),
                TradeLicenceIssuingAuthorityField(viewModel: viewModel),
                TradeLicenceExpiryDateField(viewModel: viewModel),
              ],
            ),
            const Gap(),
            FormRow(
              children: [
                IndustrySICCodeField(
                  viewModel: viewModel,
                ),
                ProposedSicCodeFeild(viewModel: viewModel),
                IndustryDescriptionField(
                  viewModel: viewModel,
                ),
              ],
            ),
            const Gap(),
            FormRow(
              children: [
                LegalStatusField(viewModel: viewModel),
                PrimaryBusinessActivity(viewModel: viewModel),
                CountryOfIncoporationField(viewModel: viewModel),
              ],
            ),
            const Gap(),
            FormRow(
              children: [
                CountryOfRisk(viewModel: viewModel),
                CountriesOfBussinessOperationField(viewModel: viewModel),
                CountriesTradedWithField(viewModel: viewModel),
              ],
            ),
            const Gap(),
            FormRow(
              children: [
                DateOfEstablishmentField(viewModel: viewModel),
                CBDRelationshipStartDateField(viewModel: viewModel),
                BorrowingRelationshipFromField(viewModel: viewModel),
              ],
            ),
            const Gap(),
            FormRow(
              children: [
                ConsolidatedCBRDField(viewModel: viewModel),
                CbdCbrbClassificationField(viewModel: viewModel),
                CccStatusField(viewModel: viewModel),
              ],
            ),
            const Gap(),
            FormRow(
              children: [
                IfrsStaging(viewModel: viewModel),
                (viewModel.isFI)
                    ? FiCategory(viewModel: viewModel)
                    : const SizedBox(),
                const SizedBox(),
              ],
            ),
            const Gap(),
            (viewModel.isFI)
                ? FormRow(
                    children: [
                      FiWorldRank(viewModel: viewModel),
                      FiCountryRank(viewModel: viewModel),
                      FiBankProposedLimit(viewModel: viewModel),
                    ],
                  )
                : Container(),
            const Gap(),
            Align(
              alignment: AlignmentDirectional.topStart,
              child: LocationAddressTitle(viewModel: viewModel),
            ),
            const Gap(),
            FormRow(
              children: [
                PoBox(viewModel: viewModel),
                AddressLineOne(viewModel: viewModel),
                AddressLineTwo(viewModel: viewModel),
              ],
            ),
            const Gap(),
            FormRow(
              children: [
                AddressLineThree(
                  viewModel: viewModel,
                ),
                EmailAddress(viewModel: viewModel),
                Phone(viewModel: viewModel),
              ],
            ),
            const Gap(),
            FormRow(
              children: [
                CorrespondenceAddressField(viewModel: viewModel),
                const Gap(),
              ],
            ),
            const Gap(),
            OwnershipDetailsTable(
              viewModel: viewModel,
              row: viewModel.customerOwnerShipInfo,
            ),
            const Gap(),
            if (viewModel.canEdit)
              AddItemButton(
                onTap: () => viewModel.addOwnershipTableRow(),
                isLeftSided: true,
                child: Text(
                  semanticsLabel:
                      "customerInformation.customerInformation.addUser".tr(),
                  "customerInformation.customerInformation.addUser".tr(),
                  style: const TextStyle(fontSize: AppStyle.fontSizeSmall),
                ),
              ),
            const Gap(),
            FormRow(
              children: [
                PolicyDeviations(
                  viewModel: viewModel,
                ),
                if (state.isPolicyDeviation == true)
                  DeviationBreachJustification(viewModel: viewModel)
                else
                  Container(),
              ],
            ),
            const Gap(),
            ExceptionTable(
              viewModel: viewModel,
              row: viewModel.customerException,
            ),
            const Gap(),
            if (viewModel.canEdit)
              AddItemButton(
                onTap: () => viewModel.addExcptionTableRow(),
                isLeftSided: true,
                child: Text(
                  semanticsLabel:
                      "customerInformation.customerInformation.addException"
                          .tr(),
                  "customerInformation.customerInformation.addException".tr(),
                  style: const TextStyle(fontSize: AppStyle.fontSizeSmall),
                ),
              ),
            const Gap(),
            ReasonForDeferralWaiver(
              viewModel: viewModel,
            ),
            const Gap(),
            ActionButton(viewModel: viewModel),
          ],
        )
    };
  }
}
