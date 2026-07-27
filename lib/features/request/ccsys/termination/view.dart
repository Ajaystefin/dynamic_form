import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/ccsys/termination/model.dart";
import "package:wcas_frontend/features/request/ccsys/termination/view_desktop.dart";
import "package:wcas_frontend/features/request/ccsys/termination/view_mobile.dart";

/// Entry view for the CCsys Termination / Withdrawal screen.
class CcsysTerminationView extends StatelessWidget {
  /// Creates a CCsys termination view.
  const CcsysTerminationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CcsysTerminationViewModel>(
      create: (context) => CcsysTerminationViewModel()..init(context),
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
