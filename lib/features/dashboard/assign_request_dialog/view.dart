import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/dashboard/assign_request_dialog/model.dart";
import "package:wcas_frontend/features/dashboard/assign_request_dialog/view_desktop.dart";
import "package:wcas_frontend/features/dashboard/assign_request_dialog/view_mobile.dart";

class AssignRequestDialogView extends StatelessWidget {
  const AssignRequestDialogView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AssignRequestDialogViewModel>(
      create: (context) => AssignRequestDialogViewModel()..init(context),
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
