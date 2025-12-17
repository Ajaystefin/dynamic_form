import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/risk_rating/widgets/external_rating.dart';
import 'package:wcas_frontend/features/request/risk_rating/widgets/internal_rating.dart';
import 'package:wcas_frontend/models/request/request.dart';

import 'model.dart';
import 'state.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    RiskRatingViewModel viewModel = context.read<RiskRatingViewModel>();
    return BlocBuilder<RiskRatingViewModel, RiskRatingState>(
        builder: (context, state) {
      return Layout(
        child: _body(context, state, viewModel),
      );
    });
  }

  Widget _body(BuildContext context, RiskRatingState state,
      RiskRatingViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      // case LoadingStatus.error:
      //   return Center(
      //     child: Text('common.serverError'.tr()),
      //   );
      default:
        return _build(viewModel, state);
    }
  }

  Widget _build(RiskRatingViewModel viewModel, RiskRatingState state) {
    return SingleChildScrollView(
      child: BoxLayout(
        child: Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BoxLayout(
                child: TopSectionDetails(request: Globals.request ?? Request()),
              ),
              BoxLayout(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InternalRatingTable(viewModel),
                    state.externalTableStatus == LoadingStatus.loading
                        ? const CircularProgressIndicator()
                        : ExternalRatingTable(viewModel),
                    const Gap(),
                    Row(
                      children: [
                        CustomButton(
                            label: "riskRating.save".tr(),
                            semanticLabel: "riskRating.save".tr(),
                            onPressed: () async => await viewModel
                                .onSavePressed(isReadOnly: viewModel.isViewOnly))
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
