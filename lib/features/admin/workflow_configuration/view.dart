import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/admin/workflow_configuration/model.dart";
import "package:wcas_frontend/features/admin/workflow_configuration/view_desktop.dart";
import "package:wcas_frontend/features/admin/workflow_configuration/view_mobile.dart";

class WorkflowConfigurationView extends StatelessWidget {
  const WorkflowConfigurationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WorkflowConfigViewModel>(
      create: (context) => WorkflowConfigViewModel()..init(context),
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
