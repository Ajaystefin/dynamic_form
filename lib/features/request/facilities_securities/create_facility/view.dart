import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';

import 'model.dart';
import 'view_desktop.dart';
import 'view_mobile.dart';

class CreateFacilityView extends StatelessWidget {
  const CreateFacilityView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final facilityArgs = GoRouterState.of(context).extra as CreateFacilityArgs?;
    return BlocProvider<CreateFacilityViewModel>(
        create: (context) => CreateFacilityViewModel()
          ..init(
            facilityArgs?.showCreateFacilityForm ?? false,
            selectedFacility: facilityArgs?.facility,
          ),
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
        ));
  }
}
