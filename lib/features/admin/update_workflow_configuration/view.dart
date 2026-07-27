import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/model.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/view_desktop.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/view_mobile.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Responsive view for creating or updating workflow configuration.
class UpdateWorkflowConfigurationView extends StatelessWidget {
  /// Creates an [UpdateWorkflowConfigurationView].
  const UpdateWorkflowConfigurationView({super.key, this.config});

  /// Existing workflow configuration used when opening the view in edit mode.
  final Reference? config;

  /// Builds the responsive workflow configuration view.
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
