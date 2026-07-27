import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/approval/group_summary/model.dart";
import "package:wcas_frontend/features/request/approval/group_summary/view_desktop.dart";

/// Displays the group summary approval view with responsive layout handling.
class GroupSummaryView extends StatelessWidget {
  /// Creates the group summary approval view.
  const GroupSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GroupSummaryViewModel>(
      create: (context) => GroupSummaryViewModel()..init(context),
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
