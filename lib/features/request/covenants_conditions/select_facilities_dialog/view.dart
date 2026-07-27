import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/model.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/view_desktop.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/view_mobile.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/models/request/facility_security/security.dart";

/// Entry view for the select facilities dialog.
class SelectFacilitiesDialogView extends StatelessWidget {
  /// Creates a select facilities dialog view.
  const SelectFacilitiesDialogView({
    this.isSecuritySummary = false,
    this.isLinakage = false,
    super.key,
    this.securityItem,
    this.selectedFacility = const [],
    this.overridePageMode,
    this.preselectedAllFacilities,
    this.isCovenant = false,
    this.linkedLimitNo,
  });

  /// Indicates whether the dialog is opened from security summary.
  final bool isSecuritySummary;

  /// Indicates whether the dialog is opened from facility-security linkage.
  final bool isLinakage;

  /// Override page mode for the dialog.
  final PageMode? overridePageMode;

  /// Preselected all facilities option.
  final Reference? preselectedAllFacilities;

  /// Indicates whether the dialog is opened from covenant flow.
  final bool isCovenant;

  /// Preselected facilities.
  final List<Facility> selectedFacility;

  /// Security item used for linkage.
  final Security? securityItem;

  /// Limit number used to show linked securities.
  final String? linkedLimitNo;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SelectFacilitiesDialogViewModel>(
      create: (context) => SelectFacilitiesDialogViewModel()
        ..init(
          context,
          selectedFacility,
          isSecuritySummary: isSecuritySummary,
          securityItem,
          isLinakage: isLinakage,
          overridePageMode,
          preselectedAllFacilities,
          isCovenant: isCovenant,
          linkedLimitNo: linkedLimitNo,
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
