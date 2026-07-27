import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_detailed/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_detailed/view_desktop.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_profitability_detailed/view_mobile.dart";

/// Relationship Profitability Detailed view.
class RelationshipProfitabilityDetailedView extends StatelessWidget {
  /// Creates a Relationship Profitability Detailed view.
  const RelationshipProfitabilityDetailedView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RelationshipProfitabilityDetailedViewModel>(
      create: (context) =>
          RelationshipProfitabilityDetailedViewModel()..init(context),
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
