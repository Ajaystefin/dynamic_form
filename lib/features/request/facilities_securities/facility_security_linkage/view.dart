import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/core/utils/utils.dart";

import "package:wcas_frontend/features/request/facilities_securities/facility_security_linkage/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/facility_security_linkage/view_desktop.dart";
import "package:wcas_frontend/features/request/facilities_securities/facility_security_linkage/view_mobile.dart";

class FacilitySecurityLinkageView extends StatelessWidget {
  const FacilitySecurityLinkageView({super.key, this.overridePageMode});
  final PageMode? overridePageMode;

  @override
  Widget build(BuildContext context) {
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
