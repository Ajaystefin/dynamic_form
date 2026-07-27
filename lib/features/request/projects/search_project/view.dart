import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";

import "package:wcas_frontend/features/request/projects/search_project/model.dart";
import "package:wcas_frontend/features/request/projects/search_project/view_desktop.dart";
import "package:wcas_frontend/features/request/projects/search_project/view_mobile.dart";

/// Search Project view.
class SearchProjectView extends StatelessWidget {
  /// Creates a Search Project view.
  const SearchProjectView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchProjectViewModel>(
      create: (context) => SearchProjectViewModel()..init(context),
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
