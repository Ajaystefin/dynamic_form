import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/admin/role_right_mapping/model.dart";
import "package:wcas_frontend/features/admin/role_right_mapping/view_desktop.dart";
import "package:wcas_frontend/features/admin/role_right_mapping/view_mobile.dart";

class RoleRightMappingView extends StatelessWidget {
  const RoleRightMappingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RoleRightMappingViewModel>(
      create: (context) => RoleRightMappingViewModel()..init(context),
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
