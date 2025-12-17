import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/form_row.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/widgets/action_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/widgets/associated_table.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/widgets/condition_description_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/widgets/condition_inline_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/widgets/condition_sub_type_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/widgets/condition_type_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/widgets/customer_name_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/widgets/frequency_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/widgets/general_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/widgets/include_in_term.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/widgets/status_field.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/widgets/target_date_field.dart';

import 'model.dart';
import 'state.dart';
import 'widgets/action_widget.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});
  @override
  Widget build(BuildContext context) {
    ConditionEditDialogViewModel viewModel =
        context.read<ConditionEditDialogViewModel>();
    return BlocBuilder<ConditionEditDialogViewModel, ConditionEditDialogState>(
        builder: (context, state) {
      return _body(context, state, viewModel);
    });
  }

  Widget _body(BuildContext context, ConditionEditDialogState state,
      ConditionEditDialogViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text('common.emptyState'.tr()),
        );

      default:
        return _buildView(viewModel, context, state);
    }
  }

  Widget _buildView(
    ConditionEditDialogViewModel viewModel,
    BuildContext context,
    ConditionEditDialogState state,
  ) {
    return SingleChildScrollView(
      child: BoxLayout(
        extraPadding: true,
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormRow(children: [
                CustomerNameField(viewModel: viewModel),
                ConditionTypeField(
                  viewModel: viewModel,
                  state: state,
                ),
                const Gap()
              ]),
              const Gap(),
              FormRow(children: [
                ConditionDescriptionField(
                  viewModel: viewModel,
                ),
                ConditionSubTypeField(
                  viewModel: viewModel,
                  state: state,
                  key: UniqueKey(),
                ),
                viewModel.isStandartList()
                    ? IncludeInTermField(
                        viewModel: viewModel,
                      )
                    : const SizedBox()
              ]),
              const Gap(),
              ConditionInlineField(
                viewModel: viewModel,
              ),
              const Gap(),
              FormRow(children: [
                FrequencyField(viewModel: viewModel),
                TargetDateField(viewModel: viewModel),
                GeneralField(
                  state: state,
                  viewModel: viewModel,
                ),
              ]),
              const Gap(),
              if (viewModel.isSpecificSelected())
                AssociatedTable(
                  viewModel: viewModel,
                ),
              const Gap(),
              FormRow(children: [
                StatusField(viewModel: viewModel),
                ActionField(viewModel: viewModel),
                const Gap()
              ]),
              ActionWidget(viewModel: viewModel)
            ],
          ),
        ),
      ),
    );
  }
}
