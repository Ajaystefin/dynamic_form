import "package:easy_localization/easy_localization.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/facilities_securities/securities_summary/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/securities_summary/state.dart";
import "package:wcas_frontend/features/request/facilities_securities/securities_summary/widgets/security_summary_table.dart";
import "package:wcas_frontend/models/request/request.dart";

/// Desktop layout for displaying and managing the securities summary
/// screen.
class ViewDesktop extends StatelessWidget {
  /// Creates a desktop securities summary view.
  const ViewDesktop({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final SecuritiesSummaryViewModel viewModel =
        context.read<SecuritiesSummaryViewModel>();
    return BlocBuilder<SecuritiesSummaryViewModel, SecuritiesSummaryState>(
      builder: (context, state) {
        return Layout(
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    SecuritiesSummaryState state,
    SecuritiesSummaryViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      default:
        return buildView(viewModel, context, state);
    }
  }

  /// Builds the main securities summary view.
  ///
  /// Displays security summary details, security actions, and navigation
  /// controls for the current application.
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
                title: "security.securitySummary.title".tr(),
              ),
            ),
            BoxLayout(
              child: TopSectionDetails(
                request: Globals.request ?? Request(),
              ),
            ),
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
            if (state.deleteButtonStatus == LoadingStatus.loading)
              const Center(child: CupertinoActivityIndicator(radius: 50))
            else
              SecuritySummaryTable(
                key: UniqueKey(),
                viewModel: viewModel,
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 10,
              children: [
                if (viewModel.canCreateOrDeleteSecurity)
                  CustomButton(
                    label: "security.securitySummary.createSecurity".tr(),
                    onPressed: () {
                      router.go(
                        Routes.createSecurity,
                        extra: {
                          "security": null,
                          "pageMode": viewModel.createSecurityPageMode,
                        },
                      );
                    },
                  ),
                CustomButton(
                  label: "security.securitySummary.continue".tr(),
                  onPressed: () {
                    LayoutViewModel().goToNextRoute();
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
