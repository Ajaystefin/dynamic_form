import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/customer_dropdown.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/add_item_button.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/address_line_one.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/address_line_three.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/address_line_two.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/borrowing_relationship_from.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/cbd_cbrb_classification.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/cbd_relationship_start_date.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/ccc_status.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/consolidated_cbrb.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/correspondence_address.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/countries_of_bussiness_operation.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/countries_traded_with.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/country_of_incorporation.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/date_of_establishment.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/email_address.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/fi_bank_proposed_limit.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/fi_country_rank.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/fi_world_rank.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/ifrs_staging.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/industry_description.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/industry_sic_code.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/po_box.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/location_address_title.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/ownership_details_table.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/phone.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/proposed_sic_code.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/trade_licence_expiry_date.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/trade_licence_issuing_authority.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/trade_licence_no.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/action.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/country_of_risk.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/deviation_breach_justification.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/exception_table.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/fi_category.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/legal_status.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/policy_deviations.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/primary_business_activity.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/fields/reason_for_deferral_waiver.dart';
import 'package:wcas_frontend/models/request/request.dart';

import 'model.dart';
import 'state.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    CustomerInfoViewModel viewModel = context.read<CustomerInfoViewModel>();
    return BlocBuilder<CustomerInfoViewModel, CustomerInfoState>(
        builder: (context, state) {
      return Layout(
        child: _body(context, state, viewModel),
      );
    });
  }

  Widget _body(BuildContext context, CustomerInfoState state,
      CustomerInfoViewModel viewModel) {
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

  Widget buildView(BuildContext context, CustomerInfoState state,
      CustomerInfoViewModel viewModel) {
    return SingleChildScrollView(
      child: BoxLayout(
        child: Form(
          key: viewModel.formKey,
          child: Padding(
            padding: const EdgeInsets.all(AppStyle.spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSectionHeader(
                    title:
                        "customerInformation.customerInformation.customerInformation"
                            .tr()),
                const Gap(),
                BoxLayout(
                  child:
                      TopSectionDetails(request: Globals.request ?? Request()),
                ),
                BoxLayout(
                  child: Column(
                    children: [
                      CustomCustomerDropdown(
                        onCustomerChange: (customer) =>
                            viewModel.onCustomerSeletion(customer),
                        selectedCustomer: (viewModel.customerList ?? []).isEmpty
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
          ),
        ),
      ),
    );
  }

  Widget buildUserNameChangeLoader(
      CustomerInfoState state, CustomerInfoViewModel viewModel) {
    return switch (state.userNameChangeLoader) {
      LoadingStatus.loading => const Center(child: CircularProgressIndicator()),
      LoadingStatus.empty => const SizedBox.shrink(),
      _ => Column(
          children: [
            const Gap(),
            Align(
              alignment: AlignmentDirectional.topStart,
              child: CustomSelectableText(
                semanticsLabel:
                    "${'customerInformation.customerInformation.customerName'.tr()} : ${viewModel.customerInformation?.customerName} ",
                text:
                    "${'customerInformation.customerInformation.customerName'.tr()} : ${viewModel.customerInformation?.customerName} ",
                style: AppStyle.boldLabel,
              ),
            ),
            const Gap(
              size: GapSize.large,
              direction: Axis.vertical,
            ),
            TradeLicenceNoField(viewModel: viewModel),
            const Gap(
              direction: Axis.vertical,
            ),
            TradeLicenceIssuingAuthorityField(
              viewModel: viewModel,
            ),
            const Gap(
              direction: Axis.vertical,
            ),
            TradeLicenceExpiryDateField(viewModel: viewModel),
            const Gap(
              direction: Axis.vertical,
            ),
            IndustrySICCodeField(
              viewModel: viewModel,
            ),
            const Gap(
              direction: Axis.vertical,
            ),
            IndustryDescriptionField(
              viewModel: viewModel,
            ),
            const Gap(
              direction: Axis.vertical,
            ),
            ProposedSicCodeFeild(viewModel: viewModel),
            const Gap(
              direction: Axis.vertical,
            ),
            LegalStatusField(viewModel: viewModel),
            const Gap(
              direction: Axis.vertical,
            ),
            PrimaryBusinessActivity(viewModel: viewModel),
            const Gap(
              direction: Axis.vertical,
            ),
            CountryOfIncoporationField(viewModel: viewModel),
            const Gap(
              direction: Axis.vertical,
            ),
            CountryOfRisk(viewModel: viewModel),
            const Gap(
              direction: Axis.vertical,
            ),
            CountriesOfBussinessOperationField(
              viewModel: viewModel,
            ),
            const Gap(
              direction: Axis.vertical,
            ),
            CountriesTradedWithField(viewModel: viewModel),
            const Gap(
              direction: Axis.vertical,
            ),
            DateOfEstablishmentField(viewModel: viewModel),
            const Gap(
              direction: Axis.vertical,
            ),
            CBDRelationshipStartDateField(
              viewModel: viewModel,
            ),
            const Gap(
              direction: Axis.vertical,
            ),
            BorrowingRelationshipFromField(viewModel: viewModel),
            const Gap(
              direction: Axis.vertical,
            ),
            ConsolidatedCBRDField(viewModel: viewModel),
            const Gap(
              direction: Axis.vertical,
            ),
            CbdCbrbClassificationField(
              viewModel: viewModel,
            ),
            const Gap(
              direction: Axis.vertical,
            ),
            CccStatusField(viewModel: viewModel),
            const Gap(
              direction: Axis.vertical,
            ),
            IfrsStaging(viewModel: viewModel),
            const Gap(
              direction: Axis.vertical,
            ),
            (viewModel.showCurrentFiCreditRisk)
                ? FiCategory(viewModel: viewModel)
                : Container(),
            const Gap(
              direction: Axis.vertical,
            ),
            if (viewModel.showCurrentFiCreditRisk) ...[
              Column(
                children: [
                  const Gap(
                    direction: Axis.vertical,
                  ),
                  FiWorldRank(viewModel: viewModel),
                  const Gap(
                    direction: Axis.vertical,
                  ),
                  FiCountryRank(viewModel: viewModel),
                  const Gap(
                    direction: Axis.vertical,
                  ),
                  FiBankProposedLimit(viewModel: viewModel),
                ],
              )
            ],
            const Gap(
              direction: Axis.vertical,
            ),
            Align(
              alignment: AlignmentDirectional.topStart,
              child: LocationAddressTitle(viewModel: viewModel),
            ),
            const Gap(),
            PoBox(viewModel: viewModel),
            const Gap(
              direction: Axis.vertical,
            ),
            AddressLineOne(viewModel: viewModel),
            const Gap(
              direction: Axis.vertical,
            ),
            AddressLineTwo(viewModel: viewModel),
            AddressLineThree(
              viewModel: viewModel,
            ),
            const Gap(
              direction: Axis.vertical,
            ),
            EmailAddress(viewModel: viewModel),
            const Gap(
              direction: Axis.vertical,
            ),
            Phone(viewModel: viewModel),
            const Gap(
              direction: Axis.vertical,
            ),
            CorrespondenceAddressField(viewModel: viewModel),
            const Gap(
              direction: Axis.vertical,
            ),
            OwnershipDetailsTable(
              viewModel: viewModel,
              row: viewModel.customerOwnerShipInfo,
            ),
            const Gap(
              direction: Axis.vertical,
            ),
            if (viewModel.canEdit)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: AddItemButton(
                    onTap: () {},
                    isLeftSided: true,
                    child: Text(
                        semanticsLabel:
                            'customerInformation.customerInformation.addUser'
                                .tr(),
                        'customerInformation.customerInformation.addUser'.tr(),
                        style:
                            const TextStyle(fontSize: AppStyle.fontSizeSmall))),
              ),
            const Gap(
              direction: Axis.vertical,
            ),
            PolicyDeviations(viewModel: viewModel),
            const Gap(
              direction: Axis.vertical,
            ),
            (state.isPolicyDeviation == true)
                ? DeviationBreachJustification(viewModel: viewModel)
                : Container(),
            const Gap(
              direction: Axis.vertical,
            ),
            ExceptionTable(
              viewModel: viewModel,
              row: viewModel.customerException,
            ),
            const Gap(
              direction: Axis.vertical,
            ),
            if (viewModel.canEdit)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: AddItemButton(
                    onTap: () => viewModel.addExcptionTableRow(),
                    isLeftSided: true,
                    child: Text(
                        'customerInformation.customerInformation.addException'
                            .tr(),
                        style:
                            const TextStyle(fontSize: AppStyle.fontSizeSmall))),
              ),
            const Gap(
              direction: Axis.vertical,
            ),
            ReasonForDeferralWaiver(
              viewModel: viewModel,
            ),
            const Gap(
              size: GapSize.large,
              direction: Axis.vertical,
            ),
            Align(
                alignment: AlignmentDirectional.center,
                child: ActionButton(viewModel: viewModel)),
            const Gap(
              direction: Axis.vertical,
            )
          ],
        ), // default case
    };
  }
}
