import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/admin/workflow_configuration/model.dart";
import "package:wcas_frontend/features/admin/workflow_configuration/view_desktop.dart";
import "package:wcas_frontend/features/admin/workflow_configuration/view_mobile.dart";

/// Responsive view for displaying and managing workflow configurations.
class WorkflowConfigurationView extends StatelessWidget {
  /// Creates a [WorkflowConfigurationView].
  const WorkflowConfigurationView({super.key});

  /// Builds the responsive workflow configuration page.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<WorkflowConfigViewModel>(
      create: (context) => WorkflowConfigViewModel()..init(),
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
