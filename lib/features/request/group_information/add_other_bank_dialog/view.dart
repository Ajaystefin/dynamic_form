import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/model.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/view_desktop.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/view_mobile.dart";
import "package:wcas_frontend/models/request/group_information/facilities_data.dart";

/// Responsive view for the Add Other Bank dialog.
class AddOtherBankDialogView extends StatelessWidget {
  /// Creates an [AddOtherBankDialogView].
  const AddOtherBankDialogView({required this.facilities, super.key});

  /// Facility record to add or edit.
  final Facility? facilities;

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
      ),
    );
  }
}
