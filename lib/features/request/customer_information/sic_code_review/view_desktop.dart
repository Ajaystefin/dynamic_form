import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/customer_information/sic_code_review/fields/account_level_sic_code.dart';
import 'package:wcas_frontend/features/request/customer_information/sic_code_review/fields/action.dart';
import 'package:wcas_frontend/features/request/customer_information/sic_code_review/fields/sic_code_table.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    SicCodeReviewViewModel viewModel = context.read<SicCodeReviewViewModel>();
    return BlocBuilder<SicCodeReviewViewModel, SicCodeReviewState>(
        builder: (context, state) {
      return Layout(
        child: _body(context, state, viewModel),
      );
    });
  }

  Widget _body(BuildContext context, SicCodeReviewState state,
      SicCodeReviewViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.error:
        return Center(
          child: Text('common.errorState'.tr()),
        );
      default:
        return buildView(state, viewModel);
    }
  }

  Widget buildView(SicCodeReviewState state, SicCodeReviewViewModel viewModel) {
    return SingleChildScrollView(
      child: BoxLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(),
            CustomSectionHeader(
                title: "customerInformation.sicCodeReview.title".tr()),
            const Gap(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(),
                BoxLayout(
                    child: TopSectionDetails(
                  request: viewModel.request ?? Request(),
                )),
                BoxLayout(
                    child: Form(
                  key: viewModel.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SicCodeTableField(
                        viewModel: viewModel,
                      ),
                      const Gap(),
                      AccountLevelSicCode(
                        viewModel: viewModel,
                      ),
                      const Gap(),
                      if (viewModel.canEdit) ActionButton(viewModel: viewModel),
                    ],
                  ),
                )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
