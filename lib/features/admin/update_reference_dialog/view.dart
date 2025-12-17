// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/admin/reference_type.dart';

import 'model.dart';
import 'view_desktop.dart';
import 'view_mobile.dart';

class UpdateReferenceDialogView extends StatelessWidget {
  final Reference reference;
  final ReferenceType referenceType;

  const UpdateReferenceDialogView(
      {super.key, required this.reference, required this.referenceType});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UpdateReferenceDialogViewModel>(
        create: (context) =>
            UpdateReferenceDialogViewModel()..init(reference, referenceType),
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
