import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/approval/comments/model.dart";
import "package:wcas_frontend/features/request/approval/comments/view_desktop.dart";
import "package:wcas_frontend/features/request/approval/comments/view_mobile.dart";

/// Displays the approval comments view with responsive desktop and mobile layouts.
class CommentsView extends StatelessWidget {
  /// Creates the approval comments view.
  const CommentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CommentsViewModel>(
      create: (context) => CommentsViewModel()..init(context),
      child: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          switch (sizingInformation.deviceScreenType) {
            case DeviceScreenType.desktop:
              return const ViewDesktop();

            case DeviceScreenType.tablet:
              return const ViewDesktop();

            case DeviceScreenType.mobile:
              return const ViewMobile();

            default:
              return const ViewDesktop();
          }
        },
      ),
    );
  }
}
