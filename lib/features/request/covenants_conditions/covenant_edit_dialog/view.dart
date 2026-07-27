import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/view_desktop.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/view_mobile.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";

/// Entry view for the covenant edit dialog.
class CovenantEditDialogView extends StatelessWidget {
  /// Creates a covenant edit dialog view.
  const CovenantEditDialogView({
    super.key,
    this.isNew,
    this.covenant,
    this.overridePageMode,
  });

  /// Indicates whether the covenant is new.
  final bool? isNew;

  /// Covenant data.
  final Covenant? covenant;

  /// Override page mode for the dialog.
  final PageMode? overridePageMode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CovenantEditDialogViewModel>(
      create: (context) => CovenantEditDialogViewModel(covenant, isNew: isNew)
        ..init(
          context,
          isNew: isNew,
          overridePageMode,
          covenantData: covenant,
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
