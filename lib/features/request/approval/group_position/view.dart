import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/approval/group_position/model.dart";
import "package:wcas_frontend/features/request/approval/group_position/view_desktop.dart";
import "package:wcas_frontend/features/request/approval/group_position/view_mobile.dart";

class GroupPositionView extends StatelessWidget {
  const GroupPositionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GroupPositionViewModel>(
      create: (context) => GroupPositionViewModel()..init(context),
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
