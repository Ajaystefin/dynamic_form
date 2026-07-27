import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/approval/proposed_facilities/model.dart";
import "package:wcas_frontend/features/request/approval/proposed_facilities/view_desktop.dart";

/// Displays the proposed facilities approval view with responsive layout handling.
class ProposedFacilitiesView extends StatelessWidget {
  /// Creates the proposed facilities approval view.
  const ProposedFacilitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProposedFacilitiesViewModel>(
      create: (context) => ProposedFacilitiesViewModel()..init(context),
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
