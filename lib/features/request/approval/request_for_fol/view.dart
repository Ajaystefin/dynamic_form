import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/approval/request_for_fol/model.dart";
import "package:wcas_frontend/features/request/approval/request_for_fol/view_desktop.dart";

/// Displays the request for FOL approval view with responsive layout handling.
class RequestForFolView extends StatelessWidget {
  /// Creates the request for FOL approval view.
  const RequestForFolView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RequestForFolViewModel>(
      create: (context) => RequestForFolViewModel()..init(context),
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
