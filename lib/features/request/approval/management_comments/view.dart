import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/approval/management_comments/model.dart";
import "package:wcas_frontend/features/request/approval/management_comments/view_desktop.dart";

/// Displays the management comments approval view with responsive layout handling.
class ManagementCommentsView extends StatelessWidget {
  /// Creates the management comments approval view.
  const ManagementCommentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ManagementCommentsViewModel>(
      create: (context) => ManagementCommentsViewModel()..init(context),
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
