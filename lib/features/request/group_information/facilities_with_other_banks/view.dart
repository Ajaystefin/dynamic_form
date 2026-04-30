import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/group_information/facilities_with_other_banks/model.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_other_banks/view_desktop.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_other_banks/view_mobile.dart";

class FacilitiesWithOtherBanksView extends StatelessWidget {
  const FacilitiesWithOtherBanksView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FacilitiesWithOtherBanksViewModel>(
      create: (context) => FacilitiesWithOtherBanksViewModel()..init(context),
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
