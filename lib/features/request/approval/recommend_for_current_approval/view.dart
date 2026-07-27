import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/approval/recommend_for_current_approval/model.dart";
import "package:wcas_frontend/features/request/approval/recommend_for_current_approval/view_desktop.dart";

/// Displays the recommendation current approval view with responsive layout handling.
class RecommendCurrentApprovalView extends StatelessWidget {
  /// Creates the recommendation current approval view.
  const RecommendCurrentApprovalView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecommendCurrentApprovalViewModel>(
      create: (context) => RecommendCurrentApprovalViewModel()..init(context),
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
