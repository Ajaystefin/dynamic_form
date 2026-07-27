import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/approval/previous_credit_approval/model.dart";
import "package:wcas_frontend/features/request/approval/previous_credit_approval/view_desktop.dart";

/// Displays the previous credit approval view with responsive layout handling.
class PreviousCreditApprovalView extends StatelessWidget {
  /// Creates the previous credit approval view.
  const PreviousCreditApprovalView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PreviousCreditApprovalViewModel>(
      create: (context) => PreviousCreditApprovalViewModel()..init(context),
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
