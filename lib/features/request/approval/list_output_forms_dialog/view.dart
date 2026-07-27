import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/approval/list_output_forms_dialog/model.dart";
import "package:wcas_frontend/features/request/approval/list_output_forms_dialog/view_desktop.dart";
import "package:wcas_frontend/features/request/approval/list_output_forms_dialog/view_mobile.dart";

/// Displays the list output forms dialog with responsive layout handling.
class ListOutputFormsDialogView extends StatelessWidget {
  /// Creates the list output forms dialog view.
  const ListOutputFormsDialogView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ListOutputFormsDialogViewModel>(
      create: (context) => ListOutputFormsDialogViewModel()..init(context),
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
