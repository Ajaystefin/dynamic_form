import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/facilities_securities/securities_summary/widgets/security_summary_table.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';

import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    SecuritiesSummaryViewModel viewModel =
        context.read<SecuritiesSummaryViewModel>();
    return BlocBuilder<SecuritiesSummaryViewModel, SecuritiesSummaryState>(
        builder: (context, state) {
      return Layout(
        child: _body(context, state, viewModel),
      );
    });
  }

  Widget _body(BuildContext context, SecuritiesSummaryState state,
      SecuritiesSummaryViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      default:
        return buildView(viewModel, context, state);
    }
  }

  Widget buildView(
    SecuritiesSummaryViewModel viewModel,
    BuildContext context,
    SecuritiesSummaryState state,
  ) {
    return SingleChildScrollView(
      child: BoxLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppStyle.spacing),
              child: CustomSectionHeader(
                  title: "security.securitySummary.title".tr()),
            ),
            BoxLayout(
                child: TopSectionDetails(
              request: Globals.request ?? Request(),
            )),
            Align(
              alignment: Alignment.centerRight,
              child: SelectableText(
                "security.securitySummary.aed".tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
            state.deleteButtonStatus == LoadingStatus.loading
                ? const Center(child: CupertinoActivityIndicator(radius: 50))
                : SecuritySummaryTable(
                    key: UniqueKey(),
                    viewModel: viewModel,
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 10,
              children: [
                if (AuthRepository.hasRight(RightConstants.createSecurity))
                  CustomButton(
                      label: "security.securitySummary.createSecurity".tr(),
                      onPressed: () {
                        // Navigator.of(context).pop();
                        router.go(Routes.createSecurity);
                      }),
                CustomButton(
                    label: "security.securitySummary.continue".tr(),
                    onPressed: () {
                      // Navigator.of(context).pop();
                      LayoutViewModel().goToNextRoute();
                    }),
              ],
            ),
            const SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }
}
