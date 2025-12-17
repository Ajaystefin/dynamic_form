import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:wcas_frontend/models/request/group_information/facilities_data.dart';

import 'model.dart';
import 'view_desktop.dart';
import 'view_mobile.dart';

class AddOtherBankDialogView extends StatelessWidget {
  final Facility? facilities;
  const AddOtherBankDialogView({super.key, required this.facilities});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddOtherBankDialogViewModel>(
        create: (context) => AddOtherBankDialogViewModel()
          ..init(context, initalFacility: facilities),
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
