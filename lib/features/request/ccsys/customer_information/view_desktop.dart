import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/add_item_button.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/form_row.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/top_section/fields/application_no.dart';
import 'package:wcas_frontend/core/components/top_section/fields/customer_name.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:wcas_frontend/core/components/top_section/fields/request_type.dart'
    as top_section;
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/auditor.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/borrower_subsidiary.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/capital.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/country_risk.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/date_audited_fs.dart';
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
import 'package:wcas_frontend/features/request/ccsys/customer_information/fields/number_employees.dart';
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

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

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
                const Gap(),
                CustomSectionHeader(
                    title:
                        "ccsys.customerInformation.customerInformation".tr()),
                const Gap(),
                BoxLayout(
                  child: FormRow(
                    children: [
                      ApplicationNo(
                        request: Globals.request ?? Request(),
                      ),
                      CustomerName(
                        request: Globals.request ?? Request(),
                      ),
                      top_section.RequestType(
                          request: Request(
                        applicationType: viewModel.applicationTypes.first,
                      ))
                    ],
                  ),
                ),
                BoxLayout(
                    extraPadding: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText(
                                "${'ccsys.customerInformation.customerName'.tr()} : ${viewModel.customer?.customerName}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Gap(size: GapSize.large),
                              FormRow(
                                children: [
                                  BorrowerSubsidiary(viewModel: viewModel),
                                  GroupUltimateParent(viewModel: viewModel),
                                  GroupImmediateParent(viewModel: viewModel),
                                ],
                              ),
                              const Gap(),
                              FormRow(
                                children: [
                                  LegalEntityIdentifier(viewModel: viewModel),
                                  LeiNumber(viewModel: viewModel),
                                  EmirateEstablishment(viewModel: viewModel),
                                ],
                              ),
                              const Gap(),
                              FormRow(
                                children: [
                                  EmirateLicense(viewModel: viewModel),
                                  Capital(viewModel: viewModel),
                                  Turnover(viewModel: viewModel),
                                ],
                              ),
                              const Gap(),
                              FormRow(
                                children: [
                                  Auditor(viewModel: viewModel),
                                  DateAuditedFS(viewModel: viewModel),
                                  NumberEmployees(viewModel: viewModel),
                                ],
                              ),
                              const Gap(),
                              FormRow(
                                children: [
                                  PartnerEnglish(viewModel: viewModel),
                                  ShareholderType(viewModel: viewModel),
                                  Shareholding(viewModel: viewModel),
                                ],
                              ),
                              const Gap(),
                              FormRow(
                                children: [
                                  NetworkPartner(viewModel: viewModel),
                                  LegalStatusPartner(viewModel: viewModel),
                                  EmiratesIdPartner(viewModel: viewModel),
                                ],
                              ),
                              const Gap(),
                              FormRow(
                                children: [
                                  EmiratesIdExpiry(viewModel: viewModel),
                                  PassportNumber(viewModel: viewModel),
                                  PassportExpiryDate(viewModel: viewModel),
                                ],
                              ),
                              const Gap(),
                              FormRow(
                                children: [
                                  NationalityPartner(viewModel: viewModel),
                                  TradeLicenceNumberPartner(
                                      viewModel: viewModel),
                                  PlaceOfIssue(viewModel: viewModel),
                                ],
                              ),
                              const Gap(),
                              FormRow(
                                children: [
                                  PSLei(viewModel: viewModel),
                                  LeiNumberPartner(viewModel: viewModel),
                                  Gender(viewModel: viewModel),
                                ],
                              ),
                              const Gap(),
                              FormRow(
                                children: [
                                  CountryRisk(viewModel),
                                  const SizedBox(),
                                  const SizedBox(),
                                ],
                              ),
                              const Gap(
                                size: GapSize.medium,
                              ),
                              PartnerDetails(
                                viewModel: viewModel,
                              ),
                              AddItemButton(
                                  isLeftSided: true,
                                  onTap: () {},
                                  child: Text(
                                      semanticsLabel:
                                          'Add Partner / Shareholder'.tr(),
                                      'Add Partner / Shareholder'.tr(),
                                      style: const TextStyle(
                                          fontSize: AppStyle.fontSizeSmall))),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomButton(
                                      label:
                                          "ccsys.customerInformation.save".tr(),
                                      onPressed: () {
                                        viewModel.saveCustomerInformation();
                                      }),
                                  const Gap(
                                    direction: Axis.horizontal,
                                  ),
                                  CustomButton(
                                      label:
                                          "ccsys.customerInformation.saveAndContinue"
                                              .tr(),
                                      onPressed: () {
                                        viewModel.saveCustomerInformation();
                                      }),
                                ],
                              )
                            ]),
                      ],
                    ))
              ],
            ),
          ),
        );
    }
  }
}
