import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/approval/request_for_closure/model.dart";
import "package:wcas_frontend/features/request/approval/request_for_closure/view_desktop.dart";

/// Displays the request for closure approval view with responsive layout handling.
class RequestForClosureView extends StatelessWidget {
  /// Creates the request for closure approval view.
  const RequestForClosureView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RequestForClosureViewModel>(
      create: (context) => RequestForClosureViewModel()..init(context),
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
