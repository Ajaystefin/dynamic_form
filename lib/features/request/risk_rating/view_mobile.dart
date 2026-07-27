import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/risk_rating/model.dart";
import "package:wcas_frontend/features/request/risk_rating/state.dart";
import "package:wcas_frontend/features/request/risk_rating/widgets/external_rating.dart";
import "package:wcas_frontend/features/request/risk_rating/widgets/fi_external_rating.dart";
import "package:wcas_frontend/features/request/risk_rating/widgets/fi_internal_rating.dart";
import "package:wcas_frontend/features/request/risk_rating/widgets/internal_rating.dart";
import "package:wcas_frontend/models/request/request.dart";

/// Mobile Risk Rating View
///
/// Displays the Risk Rating screen optimized for mobile devices.
class ViewMobile extends StatelessWidget {
  /// Creates a mobile risk rating view.
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final RiskRatingViewModel viewModel = context.read<RiskRatingViewModel>();
    return BlocBuilder<RiskRatingViewModel, RiskRatingState>(
      builder: (context, state) {
        return Layout(
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    RiskRatingState state,
    RiskRatingViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
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
                disabled: !viewModel.canEdit,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: viewModel.isFiFlow
                      ? [
                          FiInternalRating(viewModel),
                          const Gap(size: GapSize.large),
                          FiExternalRating(viewModel),
                          const Gap(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!viewModel.canEdit)
                                Container()
                              else
                                CustomButton(
                                  semanticLabel: "riskRating.save".tr(),
                                  label: "riskRating.save".tr(),
                                  onPressed: () async =>
                                      viewModel.onSavePressed(),
                                ),
                            ],
                          ),
                        ]
                      : [
                          InternalRatingTable(viewModel),
                          if (state.externalTableStatus ==
                              LoadingStatus.loading)
                            const CircularProgressIndicator()
                          else
                            ExternalRatingTable(viewModel),
                          const Gap(),
                          Row(
                            children: [
                              if (!viewModel.canEdit)
                                Container()
                              else
                                CustomButton(
                                  label: "riskRating.save".tr(),
                                  semanticLabel: "riskRating.save".tr(),
                                  onPressed: () async =>
                                      viewModel.onSavePressed(),
                                ),
                            ],
                          ),
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
