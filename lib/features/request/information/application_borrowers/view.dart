import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/features/request/information/application_borrowers/model.dart";
import "package:wcas_frontend/features/request/information/application_borrowers/view_desktop.dart";

/// Entry point widget for the Application Borrowers screen.
///
/// Determines the appropriate layout to render based on the
/// current device form factor and screen size.
class ApplicationBorrowersView extends StatelessWidget {
  /// Creates an [ApplicationBorrowersView].
  const ApplicationBorrowersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ApplicationBorrowersViewModel>(
      create: (context) => ApplicationBorrowersViewModel()..init(context),
      child: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          switch (sizingInformation.deviceScreenType) {
            case DeviceScreenType.desktop:
              return const ViewDesktop();

            case DeviceScreenType.tablet:
              return const ViewDesktop();

            default:
              return const ViewDesktop();
          }
        },
      ),
    );
  }
}
