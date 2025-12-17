import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/share_of_wallet/widgets/share_wallet_table.dart';

import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    ShareOfWalletViewModel viewModel = context.read<ShareOfWalletViewModel>();
    return BlocBuilder<ShareOfWalletViewModel, ShareOfWalletState>(
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
                      "profitabilityAccountConduct.shareOfWallet.sectionTitle"
                          .tr()),
              const Gap(),
              BoxLayout(
                child: TopSectionDetails(request: Globals.request!),
              ),
              BoxLayout(
                child: _body(context, state, viewModel),
              ),
            ],
          )),
        ),
      );
    });
  }

  Widget _body(BuildContext context, ShareOfWalletState state,
      ShareOfWalletViewModel viewModel) {
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
        return Form(
          key: viewModel.formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              CustomSelectableText(
                text: 'profitabilityAccountConduct.shareOfWallet.sectionTitle'
                    .tr(),
                semanticsLabel:
                    'profitabilityAccountConduct.shareOfWallet.sectionTitle'
                        .tr(),
                textAlign: TextAlign.left,
                style: AppStyle.tableHeaderStyle,
              ),
              CustomSelectableText(
                text: 'profitabilityAccountConduct.shareOfWallet.aed'.tr(),
                semanticsLabel:
                    'profitabilityAccountConduct.shareOfWallet.aed'.tr(),
                textAlign: TextAlign.right,
                style: AppStyle.tableSuffixHeaderStyle,
              )
            ]),
            const Gap(),
            ShareOfWalletTable(walletList: viewModel.shareOfWalletList),
            const Gap(),
            LabelWidget(
              label: 'profitabilityAccountConduct.shareOfWallet.comments'.tr(),
              labelStyle: AppStyle.boldLabel,
              child: CustomTextArea(
                semanticLabel:
                    'profitabilityAccountConduct.shareOfWallet.comments'.tr(),
                width: MediaQuery.of(context).size.width * .8,
                hintText: " ",
                autoFocus: false,
                maxLength: 2000,
                initialValue: viewModel.rmComments,
                onSaved: (String? value) {
                  viewModel.rmComments = value?.trim() ?? '';
                },
              ),
            ),
            const Gap(size: GapSize.medium),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              CustomButton(
                semanticLabel:
                    'profitabilityAccountConduct.shareOfWallet.saveAndContinue'
                        .tr(),
                label:
                    'profitabilityAccountConduct.shareOfWallet.saveAndContinue'
                        .tr(),
                onPressed: () async {
                  await viewModel.onSaveAndContinue(context);
                },
              ),
            ]),
            const Gap(size: GapSize.medium),
          ]),
        );
    }
  }
}
