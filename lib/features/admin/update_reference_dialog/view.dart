import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/model.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/view_desktop.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/view_mobile.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";

/// View used to create or update reference data.
class UpdateReferenceDialogView extends StatelessWidget {
  /// Creates an [UpdateReferenceDialogView].
  const UpdateReferenceDialogView({
    required this.reference,
    required this.referenceType,
    super.key,
  });

  /// Reference being edited.
  final Reference reference;

  /// Reference type associated with the reference.
  final ReferenceType referenceType;

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
      ),
    );
  }
}
