import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/group_information/facilities_with_cbd/model.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_cbd/view_desktop.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_cbd/view_mobile.dart";

class FacilitiesWithCbdView extends StatelessWidget {
  const FacilitiesWithCbdView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FacilitiesWithCbdViewModel>(
      create: (context) => FacilitiesWithCbdViewModel()..init(context),
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
