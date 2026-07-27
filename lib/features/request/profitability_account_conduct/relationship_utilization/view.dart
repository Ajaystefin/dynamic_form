import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/view_desktop.dart";

/// Relationship Utilization view.
class RelationshipUtilizationView extends StatelessWidget {
  /// Creates a Relationship Utilization view.
  const RelationshipUtilizationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RelationshipUtilizationViewModel>(
      create: (context) => RelationshipUtilizationViewModel()..init(context),
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
