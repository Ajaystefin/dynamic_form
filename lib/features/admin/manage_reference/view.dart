import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/admin/manage_reference/model.dart";
import "package:wcas_frontend/features/admin/manage_reference/view_desktop.dart";

/// Entry view for managing reference data.
class ManageReferenceView extends StatelessWidget {
  /// Creates a [ManageReferenceView].
  const ManageReferenceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ManageReferenceViewModel>(
      create: (context) => ManageReferenceViewModel()..init(context),
      child: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          switch (sizingInformation.deviceScreenType) {
            case DeviceScreenType.desktop:
              return const ViewDesktop();

            case DeviceScreenType.tablet:
              return const ViewDesktop();

            case DeviceScreenType.mobile:
              return const ViewDesktop();

            default:
              return const ViewDesktop();
          }
        },
      ),
    );
  }
}
