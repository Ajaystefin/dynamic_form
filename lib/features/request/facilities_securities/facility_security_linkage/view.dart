import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/facility_security_linkage/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/facility_security_linkage/view_desktop.dart";
import "package:wcas_frontend/features/request/facilities_securities/facility_security_linkage/view_mobile.dart";

/// Entry view for displaying and managing facility-security linkage
/// information.
class FacilitySecurityLinkageView extends StatelessWidget {
  /// Creates a facility-security linkage view.
  const FacilitySecurityLinkageView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Object? extra = GoRouterState.of(context).extra;
    final PageMode? overridePageMode = (extra is PageMode?) ? extra : null;
    return BlocProvider<FacilitySecurityLinkageViewModel>(
      create: (context) =>
          FacilitySecurityLinkageViewModel()..init(context, overridePageMode),
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
