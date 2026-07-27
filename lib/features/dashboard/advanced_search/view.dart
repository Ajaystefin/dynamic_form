import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/dashboard/advanced_search/model.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/view_desktop.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/view_mobile.dart";

/// Entry view for the Advanced Search feature.
class AdvancedSearchView extends StatelessWidget {
  /// Creates an [AdvancedSearchView].
  const AdvancedSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdvancedSearchViewModel>(
      create: (context) => AdvancedSearchViewModel()..init(context),
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
