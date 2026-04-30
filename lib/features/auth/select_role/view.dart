import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/features/auth/select_role/model.dart";
import "package:wcas_frontend/features/auth/select_role/view_desktop.dart";
import "package:wcas_frontend/features/auth/select_role/view_mobile.dart";

class SelectRoleView extends StatelessWidget {
  const SelectRoleView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SelectRoleViewModel>(
      create: (context) => SelectRoleViewModel(),
      child: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          switch (sizingInformation.deviceScreenType) {
            case DeviceScreenType.desktop:
              return const ViewDesktop();

            case DeviceScreenType.tablet:
              return const ViewMobile();

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
