import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/approval/request_for_limit_release/model.dart";
import "package:wcas_frontend/features/request/approval/request_for_limit_release/view_desktop.dart";

/// Displays the request for limit release view with responsive layout handling.
class RequestForLimitReleaseView extends StatelessWidget {
  /// Creates the request for limit release view.
  const RequestForLimitReleaseView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RequestForLimitReleaseViewModel>(
      create: (context) => RequestForLimitReleaseViewModel()..init(context),
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
