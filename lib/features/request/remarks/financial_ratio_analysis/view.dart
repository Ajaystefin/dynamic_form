import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/model.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/view_desktop.dart";

/// Entry point for the Financial Ratio Analysis screen.
class FinancialRatioAnalysisView extends StatelessWidget {
  /// Creates a financial ratio analysis view.
  const FinancialRatioAnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinancialRatioAnalysisViewModel>(
      create: (context) => FinancialRatioAnalysisViewModel()..init(context),
      child: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          switch (sizingInformation.deviceScreenType) {
            case DeviceScreenType.desktop:
              return const ViewDesktop();

            case DeviceScreenType.tablet:
              return const ViewDesktop();

            case DeviceScreenType.mobile:
              return const ViewDesktop();

            default:
              return const ViewDesktop();
          }
        },
      ),
    );
  }
}
