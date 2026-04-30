import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/approval/country_summary/model.dart";
import "package:wcas_frontend/features/request/approval/country_summary/view_desktop.dart";
import "package:wcas_frontend/features/request/approval/country_summary/view_mobile.dart";

class CountrySummaryView extends StatelessWidget {
  const CountrySummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CountrySummaryViewModel>(
      create: (context) => CountrySummaryViewModel()..init(context),
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
