import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/model.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/view_desktop.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/view_mobile.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class UpdateWorkflowConfigurationView extends StatelessWidget {
  const UpdateWorkflowConfigurationView({super.key, this.config});
  final Reference? config;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UpdateWorkflowConfigViewModel>(
      create: (context) =>
          UpdateWorkflowConfigViewModel()..init(context, config),
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
