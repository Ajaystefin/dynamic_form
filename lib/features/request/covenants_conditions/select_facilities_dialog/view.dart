import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:wcas_frontend/models/request/facility_security/facility.dart';
import 'package:wcas_frontend/models/request/facility_security/security.dart';
import 'model.dart';
import 'view_desktop.dart';
import 'view_mobile.dart';

class SelectFacilitiesDialogView extends StatelessWidget {
  final bool isSecuritySummary;
  const SelectFacilitiesDialogView(
      {this.isSecuritySummary = false,
      super.key,
      this.securityItem,
      this.selectedFacility = const []});
  final List<Facility> selectedFacility;
  final Security? securityItem;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SelectFacilitiesDialogViewModel>(
        create: (context) => SelectFacilitiesDialogViewModel()
          ..init(context, selectedFacility, isSecuritySummary, securityItem),
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
