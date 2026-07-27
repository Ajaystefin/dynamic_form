import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/core/constants/constants.dart";

import "package:wcas_frontend/features/dashboard/closed_requests/model.dart";
import "package:wcas_frontend/features/dashboard/closed_requests/view_desktop.dart";
import "package:wcas_frontend/features/dashboard/closed_requests/view_mobile.dart";

/// Entry view for the closed requests feature.
class ClosedRequestsView extends StatelessWidget {
  /// Creates a [ClosedRequestsView].
  const ClosedRequestsView({required this.applicationType, super.key});

  /// Application filter type used to load the appropriate closed requests data.
  final ApplicationFilterType applicationType;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClosedRequestsViewModel>(
      create: (context) => ClosedRequestsViewModel()
        ..init(context, applicationType: applicationType),
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
