import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/borrower_role.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/cash_collateral.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/cmo_remarks.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/country_of_incorporation.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/country_of_security.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/deferred_till.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/deferred_waived.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/emirates.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/is_security_expiry_open_ended.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/is_security_provider_cbd_customer.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/limit_controlling_security.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/present_security_amount.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/proposed_security_amount.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/remarks.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_code.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_desc.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_type.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_expire_date.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_group.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_held_by.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_number.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_provider_address.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_provider_category.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_provider_country_incorporation.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_provider_emirates_id.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_provider_legal_status.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_provider_name.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_provider_nationality.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_provider_rim_number.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_provider_tl_number.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/security_status.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/fields/tangible_security.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/widgets/action_widgets.dart';

import 'model.dart';
import 'state.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    CreateSecurityViewModel viewModel = context.read<CreateSecurityViewModel>();
    return BlocBuilder<CreateSecurityViewModel, CreateSecurityState>(
        builder: (context, state) {
      return Layout(
        child: _body(context, state, viewModel),
      );
    });
  }

  Widget _body(BuildContext context, CreateSecurityState state,
      CreateSecurityViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      default:
        return _buildView(context, state, viewModel);
    }
  }

  Widget _buildView(BuildContext context, CreateSecurityState state,
      CreateSecurityViewModel viewModel) {
    return SingleChildScrollView(
        child: BoxLayout(
            child: Form(
                key: viewModel.formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomSectionHeader(
                          title: "security.createSecurity.title".tr()),
                      const Gap(),
                      Column(children: [
                        BoxLayout(
                          child: TopSectionDetails(
                            request: viewModel.request,
                          ),
                        ),
                        (viewModel.security.securityType == null)
                            ? BoxLayout(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SecurityGroup(viewModel: viewModel),
                                      const Gap(),
                                      viewModel.security.securityType == null
                                          ? const SizedBox.shrink()
                                          : TypeOfSecurity(viewModel: viewModel)
                                    ]),
                              )
                            : BoxLayout(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SecurityDescription(viewModel: viewModel),
                                      const Gap(),
                                      SecurityCode(viewModel: viewModel),
                                      const Gap(),
                                      SecurityNumber(viewModel: viewModel),
                                      const Gap(),
                                      TangibleSecurity(viewModel: viewModel),
                                      const Gap(),
                                      LimitControllingSecurity(
                                          viewModel: viewModel),
                                      const Gap(),
                                      CashCollateral(viewModel: viewModel),
                                      const Gap(),
                                      PresentSecurityAmount(
                                          viewModel: viewModel),
                                      const Gap(),
                                      ProposedSecurityAmount(
                                          viewModel: viewModel),
                                      const Gap(),
                                      BorrowerRole(viewModel: viewModel),
                                      const Gap(),
                                      IsSecurityProviderCbdCustomer(
                                          viewModel: viewModel),
                                      const Gap(),
                                      IsSecurityExpiryOpenEnded(
                                          viewModel: viewModel),
                                      const Gap(),
                                      SecurityExpireDate(viewModel: viewModel),
                                      const Gap(),
                                      SecurityProviderRimNumber(
                                        viewModel: viewModel,
                                      ),
                                      const Gap(),
                                      SecurityProviderName(
                                          viewModel: viewModel),
                                      const Gap(),
                                      CountryOfIncorporation(
                                          viewModel: viewModel),
                                      const Gap(),
                                      SecurityHeldBy(viewModel: viewModel),
                                      const Gap(),
                                      SecurityStatus(viewModel: viewModel),
                                      const Gap(),
                                      SecurityProviderCategory(
                                          viewModel: viewModel),
                                      const Gap(),
                                      SecurityProviderLegalStatus(
                                          viewModel: viewModel),
                                      const Gap(),
                                      SecurityProviderCountryIncorporation(
                                          viewModel: viewModel),
                                      const Gap(),
                                      SecurityProviderTlNumber(
                                          viewModel: viewModel),
                                      const Gap(),
                                      SecurityProviderAddress(
                                        viewModel: viewModel,
                                      ),
                                      const Gap(),
                                      SecurityProviderEmiratesId(
                                          viewModel: viewModel),
                                      const Gap(),
                                      SecurityProviderNationality(
                                          viewModel: viewModel),
                                      const Gap(),
                                      CountryOfSecurity(viewModel: viewModel),
                                      const Gap(),
                                      Emirates(viewModel: viewModel),
                                      const Gap(),
                                      DeferredWaivedBy(viewModel: viewModel),
                                      const Gap(),
                                      DeferredTill(viewModel: viewModel),
                                      const Gap(),
                                      CmoRemarks(viewModel: viewModel),
                                      const Gap(),
                                      Remarks(viewModel: viewModel),
                                      const Gap(),
                                      Align(
                                          alignment:
                                              AlignmentDirectional.center,
                                          child: ActionWidgets(
                                            viewModel: viewModel,
                                          ))
                                    ]),
                              )
                      ])
                    ]))));
  }
}
