import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/approval/credit_assessment/model.dart";
import "package:wcas_frontend/features/request/approval/credit_assessment/view_desktop.dart";

/// Displays the credit assessment approval view with responsive layout handling.
class CreditAssessmentView extends StatelessWidget {
  /// Creates the credit assessment approval view.
  const CreditAssessmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreditAssessmentViewModel>(
      create: (context) => CreditAssessmentViewModel()..init(context),
      child: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          switch (sizingInformation.deviceScreenType) {
            case DeviceScreenType.desktop:
              return const ViewDesktop();

            case DeviceScreenType.tablet:
              return const ViewDesktop();

            default:
              return const ViewDesktop();
          }
        },
      ),
    );
  }
}
