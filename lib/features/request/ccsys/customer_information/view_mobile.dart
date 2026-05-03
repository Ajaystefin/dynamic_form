import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/fields/auditor.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/fields/borrower_subsidiary.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/fields/capital.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/fields/country_risk.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/fields/date_audited_fs.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/fields/emirate_license.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/fields/emirates_establishment.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/fields/group_immediate_parent.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/fields/group_ultimate_parent.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/fields/legal_entity_identifier.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/fields/lei_number.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/fields/number_employees.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/fields/turnover.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/state.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/widgets/partner_details.dart";
import "package:wcas_frontend/models/request/request.dart";

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final CustomerInformationViewModel viewModel =
        context.read<CustomerInformationViewModel>();
    return BlocBuilder<CustomerInformationViewModel, CustomerInformationState>(
      builder: (context, state) {
        return Layout(
          hideSideMenu: false,
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    CustomerInformationState state,
    CustomerInformationViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case LoadingStatus.error:
        return Center(
          child: Text("common.serverError".tr()),
        );
      default:
        return SingleChildScrollView(
          child: Focus(
            focusNode: viewModel.formFocusNode,
            child: Form(
              key: viewModel.formKey,
              child: BoxLayout(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSectionHeader(
                      title:
                          "ccsys.customerInformation.customerInformation".tr(),
                    ),
                    const Gap(),
                    BoxLayout(
                      child: TopSectionDetails(
                        request: Globals.request ?? Request(),
                      ),
                    ),
                    BoxLayout(
                      extraPadding: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(
                            builder: (context) {
                              // Resolve customer name from
                              // local info or request
                              final String displayName =
                                  viewModel.customerInformation.customerName ??
                                      Globals.request?.customerName ??
                                      "";
                              // Extract translation key to local var
                              final String custLabel =
                                  "ccsys.customerInformation"
                                          ".customerName"
                                      .tr();
                              return SelectableText(
                                "$custLabel : $displayName",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                          const Gap(size: GapSize.large),
                          BorrowerSubsidiary(viewModel: viewModel),
                          const Gap(),
                          GroupUltimateParent(
                            viewModel: viewModel,
                            state: state,
                          ),
                          const Gap(),
                          GroupImmediateParent(
                            viewModel: viewModel,
                            state: state,
                          ),
                          const Gap(),
                          LegalEntityIdentifier(viewModel: viewModel),
                          const Gap(),
                          LeiNumber(
                            viewModel: viewModel,
                            state: state,
                          ),
                          const Gap(),
                          EmirateEstablishment(
                            viewModel: viewModel,
                            state: state,
                          ),
                          const Gap(),
                          EmirateLicense(
                            viewModel: viewModel,
                            state: state,
                          ),
                          const Gap(),
                          Capital(viewModel: viewModel),
                          const Gap(),
                          Turnover(viewModel: viewModel),
                          Auditor(viewModel: viewModel),
                          const Gap(),
                          DateAuditedFS(viewModel: viewModel),
                          const Gap(),
                          NumberEmployees(viewModel: viewModel),
                          const Gap(),
                          CountryRisk(viewModel),
                          const Gap(),
                          PartnerDetails(
                            viewModel: viewModel,
                            state: state,
                          ),
                          if (viewModel.canEdit)
                            AddItemButton(
                              isLeftSided: true,
                              child: Text(
                                semanticsLabel:
                                    "Add Partner / Shareholder".tr(),
                                "Add Partner / Shareholder".tr(),
                                style: const TextStyle(
                                  fontSize: AppStyle.fontSizeSmall,
                                ),
                              ),
                            ),
                          const Gap(
                            size: GapSize.medium,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                CustomButton(
                                  label: "ccsys.customerInformation.save".tr(),
                                  onPressed: (!viewModel.canEdit)
                                      ? null
                                      : () {
                                          viewModel.saveCustomerInformation();
                                        },
                                ),
                                const Gap(
                                  direction: Axis.horizontal,
                                ),
                                CustomButton(
                                  label: "ccsys.customerInformation."
                                          "saveAndContinue"
                                      .tr(),
                                  onPressed: (!viewModel.canEdit)
                                      ? null
                                      : () {
                                          viewModel.saveCustomerInformation(
                                            ifNavigate: true,
                                          );
                                        },
                                ),
                              ],
                            ),
                          ),
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
  }
}
