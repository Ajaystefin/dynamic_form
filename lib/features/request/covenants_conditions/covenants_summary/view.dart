import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/core/utils/utils.dart";

import "package:wcas_frontend/features/request/covenants_conditions/covenants_summary/model.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenants_summary/view_desktop.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenants_summary/view_mobile.dart";

class CovenantsSummaryView extends StatelessWidget {
  const CovenantsSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final Object? extra = GoRouterState.of(context).extra;
    final PageMode? pageMode = (extra is PageMode) ? extra : null;

    return BlocProvider<CovenantsSummaryViewModel>(
      create: (context) =>
          CovenantsSummaryViewModel()..init(context, pageMode: pageMode),
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
