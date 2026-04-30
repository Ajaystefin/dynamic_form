import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:responsive_builder/responsive_builder.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/view_desktop.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/view_mobile.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant_condition.dart";

class ConditionEditDialogView extends StatelessWidget {
  const ConditionEditDialogView({
    super.key,
    this.condition,
    this.overridePageMode,
  });
  final CovenantCondition? condition;
  final PageMode? overridePageMode;
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConditionEditDialogViewModel>(
      create: (context) => ConditionEditDialogViewModel()
        ..init(context, overridePageMode, condition),
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
