import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/view_desktop.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/view_mobile.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";

/// View for creating and editing facility details.
class CreateFacilityView extends StatelessWidget {
  /// Creates a create facility view.
  const CreateFacilityView(
    this.facilityArgs, {
    this.pageMode,
    super.key,
  });

  /// Arguments used to initialize the facility view.
  final CreateFacilityArgs? facilityArgs;

  /// Mode in which the page is displayed.
  final PageMode? pageMode;


  @override
  Widget build(BuildContext context) {
    // final facilityArgs = GoRouterState.of(context).extra as CreateFacilityArgs?;
    return BlocProvider<CreateFacilityViewModel>(
      create: (context) => CreateFacilityViewModel()
        ..init(
          showCreateForm: facilityArgs?.showCreateFacilityForm ?? false,
          selectedFacility: facilityArgs?.facility,
          pageModeFromArgs: pageMode,
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
