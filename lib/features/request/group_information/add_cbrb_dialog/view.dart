import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/model.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/view_desktop.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/view_mobile.dart";
import "package:wcas_frontend/models/request/group_information/cbrb_data.dart";

/// Responsive view for the Add CBRB dialog.
class AddCbrbDialogView extends StatelessWidget {
  /// Creates an [AddCbrbDialogView].
  const AddCbrbDialogView({required this.cbrb, super.key});

  /// CBRB record to add or edit.
  final CBRB? cbrb;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddCbrbDialogViewModel>(
      create: (context) => AddCbrbDialogViewModel()
        ..init(
          context,
          initialCbrb: cbrb,
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
      ),
    );
  }
}
