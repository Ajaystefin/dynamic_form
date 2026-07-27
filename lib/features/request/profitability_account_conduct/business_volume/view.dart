import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/profitability_account_conduct/business_volume/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/business_volume/view_desktop.dart";

/// Business Volume view.
class BusinessVolumeView extends StatelessWidget {
  /// Creates a Business Volume view.
  const BusinessVolumeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BusinessVolumeViewModel>(
      create: (context) => BusinessVolumeViewModel()..init(context),
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
