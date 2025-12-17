import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/account_conduct/widgets/rim_list_accordian.dart';
import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    AccountConductViewModel viewModel = context.read<AccountConductViewModel>();
    return BlocBuilder<AccountConductViewModel, AccountConductState>(
        builder: (context, state) {
      return Layout(
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: BoxLayout(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSectionHeader(
                    title:
                        "profitabilityAccountConduct.accountConduct.sectionTitle"
                            .tr()),
                const Gap(),
                BoxLayout(
                  child: TopSectionDetails(request: Globals.request!),
                ),
                BoxLayout(
                  child: _body(context, state, viewModel),
                )
              ],
            ))),
      );
    });
  }

  Widget _body(BuildContext context, AccountConductState state,
      AccountConductViewModel viewModel) {
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
        return _buildView(state, viewModel, context);
    }
  }

  Widget _buildView(AccountConductState state,
      AccountConductViewModel viewModel, BuildContext context) {
    return Form(
      key: viewModel.formKey,
      child: Column(
        children: [
          const Gap(),
          rimListAccordian(viewModel),
          const Gap(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                  label: "common.save".tr(),
                  onPressed: () async {
                    await viewModel.saveAccConductData();
                  }),
              const Gap(direction: Axis.horizontal),
              CustomButton(
                  label: "common.saveAndContinue".tr(), // "Save & Continue",
                  onPressed: () async {
                    await viewModel.saveAccConductData(ifNavigate: true);
                  }),
            ],
          )
        ],
      ),
    );
  }
}
