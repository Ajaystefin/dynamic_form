import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/ccsys/create_request/model.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/view_desktop.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/view_mobile.dart";

/// Displays the CCSYS create request view with responsive layout handling.
class CCSYSCreateRequestView extends StatelessWidget {
  /// Creates the CCSYS create request view.
  const CCSYSCreateRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CcsysCreateRequestViewModel>(
      create: (context) => CcsysCreateRequestViewModel()..init(context),
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
