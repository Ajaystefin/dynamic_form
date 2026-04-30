import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";
import "package:wcas_frontend/features/request/projects/create_project/view_desktop.dart";
import "package:wcas_frontend/features/request/projects/create_project/view_mobile.dart";
import "package:wcas_frontend/models/request/project/project.dart";

class CreateProjectView extends StatelessWidget {
  const CreateProjectView({
    this.isCreateProject = true,
    super.key,
    this.projectItem,
  });
  final bool isCreateProject;
  final Project? projectItem;

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final String? backTo = (extra is Map) ? extra["backTo"] as String? : null;

    // Optional fallback if caller didn't pass extra:
    final bool hasAppRef = (Globals.request?.applicationRefNo ?? "").isNotEmpty;

    return PopScope(
      // ← Always intercept; we'll decide what to do inside the callback
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) async {
        if (didPop) return;

        // 1) Prefer explicit back target from caller
        if (backTo != null && context.mounted) {
          context.replace(backTo); // ← use replace, not go
          return;
        }

        // 2) Fallback to your business rule
        if (hasAppRef && context.mounted) {
          context.replace(Routes.facilitySummaryView); // ← replace
          return;
        }

        // 3) Otherwise allow natural back
        final router = GoRouter.of(context);
        if (router.canPop()) {
          context.pop();
        } else if (context.mounted) {
          // Safety fallback if we’re at the root
          context.replace(Routes.home);
        }
      },
      child: BlocProvider<CreateProjectViewModel>(
        create: (context) => CreateProjectViewModel()
          ..init(
            context,
            isCreateProjectView: isCreateProject,
            projectItemView: projectItem ?? Project(),
          ),
        child: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            switch (sizingInformation.deviceScreenType) {
              case DeviceScreenType.desktop:
                return ViewDesktop(isCreateProject);
              case DeviceScreenType.tablet:
                return ViewDesktop(isCreateProject);
              case DeviceScreenType.mobile:
                return ViewMobile(isCreateProject);
              default:
                return ViewDesktop(isCreateProject);
            }
          },
        ),
      ),
    );
  }
}
// class CreateProjectView extends StatelessWidget {
//   final bool isCreateProject;
//   final Project? projectItem;
//   const CreateProjectView(
//       {this.isCreateProject = true, super.key, this.projectItem});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<CreateProjectViewModel>(
//         create: (context) => CreateProjectViewModel()
//           ..init(context,
//               isCreateProjectView: isCreateProject,
//               projectItemView: projectItem ?? Project()),
//         child: ResponsiveBuilder(
//           builder: (context, sizingInformation) {
//             switch (sizingInformation.deviceScreenType) {
//               case DeviceScreenType.desktop:
//                 return ViewDesktop(isCreateProject);

//               case DeviceScreenType.tablet:
//                 return ViewDesktop(isCreateProject);

//               case DeviceScreenType.mobile:
//                 return ViewMobile(isCreateProject);

//               default:
//                 return ViewDesktop(isCreateProject);
//             }
//           },
//         ));
//   }
// }
