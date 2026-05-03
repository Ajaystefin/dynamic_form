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

class SelectFacilitiesDialogView extends StatelessWidget {
  const SelectFacilitiesDialogView({
    this.isSecuritySummary = false,
    this.isLinakage = false,
    super.key,
    this.securityItem,
    this.selectedFacility = const [],
    this.overridePageMode,
    this.preselectedAllFacilities,
    this.isCovenant = false,
  });
  final bool isSecuritySummary;
  final bool isLinakage;
  final PageMode? overridePageMode;
  final Reference? preselectedAllFacilities;
  final bool isCovenant;

  final List<Facility> selectedFacility;
  final Security? securityItem;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SelectFacilitiesDialogViewModel>(
      create: (context) => SelectFacilitiesDialogViewModel()
        ..init(
          context,
          selectedFacility,
          isSecuritySummary,
          securityItem,
          isLinakage,
          overridePageMode,
          preselectedAllFacilities,
          isCovenant,
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
