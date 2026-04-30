import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/view_desktop.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/view_mobile.dart";

class FacilitiesSummaryView extends StatelessWidget {
  const FacilitiesSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FacilitiesSummaryViewModel>(
      create: (context) => FacilitiesSummaryViewModel()..init(context),
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
