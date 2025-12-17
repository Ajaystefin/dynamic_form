import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/information/in_pipeline_dialog/fields/table.dart';

import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    InPipelineDialogViewModel viewModel =
        context.read<InPipelineDialogViewModel>();
    return BlocBuilder<InPipelineDialogViewModel, InPipelineDialogState>(
        builder: (context, state) {
      return _body(context, state, viewModel);
    });
  }

  Widget _body(BuildContext context, InPipelineDialogState state,
      InPipelineDialogViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case LoadingStatus.empty:
        return Center(child: Text('common.emptyState'.tr()));
      case LoadingStatus.error:
        return Center(child: Text('common.errorState'.tr()));

      default:
        return BoxLayout(
          child: SingleChildScrollView(
            child: InPipelineTable(viewModel: viewModel,state: state,),
          ),
        );
    }
  }
}
