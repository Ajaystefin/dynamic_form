import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/add_item_button.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/top_section/fields/application_no.dart';
import 'package:wcas_frontend/core/components/top_section/fields/customer_name.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/components/top_section/fields/request_type.dart'
    as top_section;

import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/borrower_subsidiary.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/capital.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/emirate_license.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/emirates_establishment.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/emirates_id_expiry_date.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/emirates_id_partner.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/gender.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/group_immediate_parent.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/group_ultimate_parent.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/legal_entity_identifier.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/legal_status_partner.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/lei_number.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/lei_number_partner.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/nationality_partner.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/networth_partner.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/p_s_lei.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/partner_english.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/passport_expriy_date.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/passport_number.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/place_of_issue.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/shareholder_type.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/shareholding.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/trade_licence_no_partner.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/turnover.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/widget/partner_details.dart';
import 'package:wcas_frontend/models/request/request.dart';

import 'model.dart';
import 'state.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    CustomerInformationViewModel viewModel =
        context.read<CustomerInformationViewModel>();
    return BlocBuilder<CustomerInformationViewModel, CustomerInformationState>(
        builder: (context, state) {
      return Layout(
        child: _body(context, state, viewModel),
      );
    });
  }

  Widget _body(BuildContext context, CustomerInformationState state,
      CustomerInformationViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case LoadingStatus.error:
        return Center(
          child: Text('common.serverError'.tr()),
        );
      default:
        return SingleChildScrollView(
          child: BoxLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSectionHeader(
                    title:
                        "ccsys.customerInformation.customerInformation".tr()),
                const Gap(),
                BoxLayout(
                    child: Column(
                  children: [
                    ApplicationNo(
                      request: Globals.request ?? Request(),
                    ),
                    const Gap(),
                    CustomerName(
                      request: Globals.request ?? Request(),
                    ),
                    const Gap(),
                    top_section.RequestType(
                        request: Request(
                      applicationType: viewModel.applicationTypes.first,
                    ))
                  ],
                )),
                BoxLayout(
                  extraPadding: true,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          "${'ccsys.customerInformation.customerName'.tr()} : ${viewModel.customer?.customerName}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(size: GapSize.large),
                        BorrowerSubsidiary(viewModel: viewModel),
                        const Gap(),
                        GroupUltimateParent(viewModel: viewModel),
                        const Gap(),
                        GroupImmediateParent(viewModel: viewModel),
                        const Gap(),
                        LegalEntityIdentifier(viewModel: viewModel),
                        const Gap(),
                        LeiNumber(viewModel: viewModel),
                        const Gap(),
                        EmirateEstablishment(viewModel: viewModel),
                        const Gap(),
                        EmirateLicense(viewModel: viewModel),
                        const Gap(),
                        Capital(viewModel: viewModel),
                        const Gap(),
                        Turnover(viewModel: viewModel),
                        const Gap(),
                        PartnerEnglish(viewModel: viewModel),
                        const Gap(),
                        ShareholderType(viewModel: viewModel),
                        const Gap(),
                        Shareholding(viewModel: viewModel),
                        const Gap(),
                        NetworkPartner(viewModel: viewModel),
                        const Gap(),
                        LegalStatusPartner(viewModel: viewModel),
                        const Gap(),
                        EmiratesIdPartner(viewModel: viewModel),
                        const Gap(),
                        EmiratesIdExpiry(viewModel: viewModel),
                        const Gap(),
                        PassportNumber(viewModel: viewModel),
                        const Gap(),
                        PassportExpiryDate(viewModel: viewModel),
                        const Gap(),
                        NationalityPartner(viewModel: viewModel),
                        const Gap(),
                        NationalityPartner(viewModel: viewModel),
                        const Gap(),
                        TradeLicenceNumberPartner(viewModel: viewModel),
                        const Gap(),
                        PlaceOfIssue(viewModel: viewModel),
                        const Gap(),
                        PSLei(viewModel: viewModel),
                        const Gap(),
                        LeiNumberPartner(viewModel: viewModel),
                        const Gap(),
                        Gender(viewModel: viewModel),
                        const Gap(),
                        PartnerDetails(
                          viewModel: viewModel,
                        ),
                        AddItemButton(
                            isLeftSided: true,
                            child: Text(
                                semanticsLabel:
                                    'Add Partner / Shareholder'.tr(),
                                'Add Partner / Shareholder'.tr(),
                                style: const TextStyle(
                                    fontSize: AppStyle.fontSizeSmall))),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              CustomButton(
                                  label: "ccsys.customerInformation.save".tr(),
                                  onPressed: () {}),
                              const Gap(
                                direction: Axis.horizontal,
                              ),
                              CustomButton(
                                  label:
                                      "ccsys.customerInformation.saveAndContinue"
                                          .tr(),
                                  onPressed: () {}),
                            ],
                          ),
                        )
                      ]),
                ),
              ],
            ),
          ),
        );
    }
  }
}
