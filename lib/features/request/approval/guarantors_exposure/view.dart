import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/approval/guarantors_exposure/model.dart";
import "package:wcas_frontend/features/request/approval/guarantors_exposure/view_desktop.dart";
import "package:wcas_frontend/features/request/approval/guarantors_exposure/view_mobile.dart";

class GuarantorsExposureView extends StatelessWidget {
  const GuarantorsExposureView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GuarantorsExposureViewModel>(
      create: (context) => GuarantorsExposureViewModel()..init(context),
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
