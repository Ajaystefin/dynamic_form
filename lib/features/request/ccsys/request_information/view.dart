import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/ccsys/request_information/model.dart";
import "package:wcas_frontend/features/request/ccsys/request_information/view_desktop.dart";
import "package:wcas_frontend/features/request/ccsys/request_information/view_mobile.dart";

/// Entry widget for the CCSYS request information screen.
class CCSYSRequestInformation extends StatelessWidget {
  /// Creates a [CCSYSRequestInformation] widget.
  const CCSYSRequestInformation({super.key});

  /// Builds the CCSYS request information screen with responsive layout.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<RequestInformationViewModel>(
      create: (context) => RequestInformationViewModel()..init(context),
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
