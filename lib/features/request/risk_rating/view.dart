import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/risk_rating/model.dart";
import "package:wcas_frontend/features/request/risk_rating/view_desktop.dart";
import "package:wcas_frontend/features/request/risk_rating/view_mobile.dart";

/// Risk Rating View
///
/// Displays the Risk Rating screen and initializes the
/// corresponding view model. Renders a responsive layout
/// based on the current device type.
class RiskRatingView extends StatelessWidget {
  /// Creates a risk rating view.
  const RiskRatingView({super.key});

  @override
  Widget build(BuildContext context) {
    final Object? extra = GoRouterState.of(context).extra;
    final PageMode? pageMode = (extra is PageMode?) ? extra : null;

    return BlocProvider<RiskRatingViewModel>(
      create: (context) =>
          RiskRatingViewModel()..init(context, amendPagemode: pageMode),
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
