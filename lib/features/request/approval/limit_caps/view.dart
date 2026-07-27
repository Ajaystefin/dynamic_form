import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/approval/limit_caps/model.dart";
import "package:wcas_frontend/features/request/approval/limit_caps/view_desktop.dart";

/// Displays the limit caps approval view with responsive layout handling.
class LimitCapsView extends StatelessWidget {
  /// Creates the limit caps approval view.
  const LimitCapsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LimitCapsViewModel>(
      create: (context) => LimitCapsViewModel()..init(context),
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
