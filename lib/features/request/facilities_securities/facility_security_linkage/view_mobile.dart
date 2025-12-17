import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facility_security_linkage/widgets/facility_security_table.dart';
import 'package:wcas_frontend/models/request/request.dart';

import 'model.dart';
import 'state.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    FacilitySecurityLinkageViewModel viewModel =
        context.read<FacilitySecurityLinkageViewModel>();
    return BlocBuilder<FacilitySecurityLinkageViewModel,
        FacilitySecurityLinkageState>(builder: (context, state) {
      return Layout(
        child: _body(context, state, viewModel),
      );
    });
  }

  Widget _body(BuildContext context, FacilitySecurityLinkageState state,
      FacilitySecurityLinkageViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text('Empty State'.tr()),
        );
      default:
        return buildView(viewModel, state, context);
    }
  }

  Widget buildView(FacilitySecurityLinkageViewModel viewModel,
      FacilitySecurityLinkageState state, BuildContext context) {
    return SingleChildScrollView(
      child: BoxLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSectionHeader(
                title: "security.securityFacilityLinkage.title".tr()),
            const Gap(),
            BoxLayout(
              child: TopSectionDetails(request: Globals.request ?? Request()),
            ),
            const Gap(),
            Align(
              alignment: Alignment.centerRight,
              child: SelectableText(
                "security.securityFacilityLinkage.aed".tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
            const Gap(),
            BoxLayout(
              child: FacilitySecurityTableField(
                viewModel: viewModel,
                state: state,
              ),
            ),
            const Gap(),
            Align(
              alignment: Alignment.centerRight,
              child: CustomButton(
                  label: "security.securityFacilityLinkage.continue".tr(),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ),
            const Gap(customValue: 30),
          ],
        ),
      ),
    );
  }
}
