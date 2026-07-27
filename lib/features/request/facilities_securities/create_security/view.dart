import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/view_desktop.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/view_mobile.dart";
import "package:wcas_frontend/models/request/facility_security/security.dart";

/// Entry view for creating, viewing, or editing security details.
class CreateSecurityView extends StatelessWidget {
  /// Creates a security view.
  ///
  /// Optionally accepts an existing [security] and the current
  /// [pageMode] to determine the screen behavior.
  const CreateSecurityView({
    this.security,
    this.pageMode,
    super.key,
  });

  /// Security details to be displayed or edited.
  final Security? security;

  /// Current page mode that determines whether the screen is in
  /// na, view, or edit state.
  final PageMode? pageMode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateSecurityViewModel>(
      create: (context) =>
          CreateSecurityViewModel()..init(security, pageModeFromArgs: pageMode),
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
