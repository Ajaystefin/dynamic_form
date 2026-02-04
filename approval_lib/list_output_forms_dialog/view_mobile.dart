import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/approval/list_output_forms_dialog/widgets/output_forms_list.dart';
import 'package:wcas_frontend/features/request/approval/list_output_forms_dialog/widgets/preview_download_button.dart';

import 'model.dart';
import 'state.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    ListOutputFormsDialogViewModel viewModel =
        context.read<ListOutputFormsDialogViewModel>();
    return BlocBuilder<ListOutputFormsDialogViewModel,
        ListOutputFormsDialogState>(builder: (context, state) {
      return _body(context, state, viewModel);
    });
  }

  Widget _body(BuildContext context, ListOutputFormsDialogState state,
      ListOutputFormsDialogViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text('common.emptyState'.tr()),
        );
      case LoadingStatus.error:
        return Center(
          child: Text('common.errorState'.tr()),
        );
      default:
        return SingleChildScrollView(
          child: Column(
            children: [
              BoxLayout(child: OutputFormsList(viewModel: viewModel)),
              const Gap(),
              PreviewDownloadButton(viewModel: viewModel)
            ],
          ),
        );
    }
  }
}
