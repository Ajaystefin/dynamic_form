import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/view_desktop.dart";

/// View for displaying and managing the facility summary screen.
class FacilitiesSummaryView extends StatelessWidget {
  /// Creates a facility summary view.
  const FacilitiesSummaryView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Object? extra = GoRouterState.of(context).extra;
    final PageMode? pageMode = (extra is PageMode?) ? extra : null;
    return BlocProvider<FacilitiesSummaryViewModel>(
      create: (context) =>
          FacilitiesSummaryViewModel()..init(context, amendPagemode: pageMode),
      child: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          switch (sizingInformation.deviceScreenType) {
            case DeviceScreenType.desktop:
              return const ViewDesktop();

            case DeviceScreenType.tablet:
              return const ViewDesktop();

            default:
              return const ViewDesktop();
          }
        },
      ),
    );
  }
}
