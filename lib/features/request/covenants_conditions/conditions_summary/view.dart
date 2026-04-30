import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/core/utils/utils.dart";

import "package:wcas_frontend/features/request/covenants_conditions/conditions_summary/model.dart";
import "package:wcas_frontend/features/request/covenants_conditions/conditions_summary/view_desktop.dart";
import "package:wcas_frontend/features/request/covenants_conditions/conditions_summary/view_mobile.dart";

class ConditionsSummaryView extends StatelessWidget {
  const ConditionsSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final Object? extra = GoRouterState.of(context).extra;
    final PageMode? pageMode = (extra is PageMode) ? extra : null;

    return BlocProvider<ConditionsSummaryViewModel>(
      create: (context) =>
          ConditionsSummaryViewModel()..init(context, pagemode: pageMode),
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
