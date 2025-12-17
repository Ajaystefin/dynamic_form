import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/dashboard/closed_requests/fields/closed_request_table.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';

import 'model.dart';
import 'state.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    ClosedRequestsViewModel viewModel = context.read<ClosedRequestsViewModel>();
    return BlocBuilder<ClosedRequestsViewModel, ClosedRequestsState>(
        builder: (context, state) {
      return Layout(
        child: _body(context, state, viewModel),
      );
    });
  }

  Widget _body(BuildContext context, ClosedRequestsState state,
      ClosedRequestsViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text('Empty State'.tr()),
        );
      case LoadingStatus.error:
        return Center(
          child: Text('common.errorState'.tr()),
        );
      default:
        return SingleChildScrollView(
            child:
                BoxLayout(child: ClosedRequestTable(state: state, viewModel)));
    }
  }
}
