import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/features/request/information/termination/model.dart";
import "package:wcas_frontend/features/request/information/termination/view_desktop.dart";
import "package:wcas_frontend/features/request/information/termination/view_mobile.dart";

/// Entry point widget for the Termination screen.
///
/// Determines and renders the appropriate layout based on the
/// current device type and screen size.
class TerminationView extends StatelessWidget {
  /// Creates a [TerminationView].
  const TerminationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TerminationViewModel>(
      create: (context) => TerminationViewModel()..init(context),
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
