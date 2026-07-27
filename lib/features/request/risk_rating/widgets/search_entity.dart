import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/risk_rating/model.dart";

/// Search Entity
///
/// Displays entity search and selection options for a customer RIM.
class SearchEntity extends StatelessWidget {
  /// Creates a search entity widget.
  const SearchEntity(
    this.viewModel, {
    required this.rimNo,
    super.key,
  });

  /// Risk rating view model.
  final RiskRatingViewModel viewModel;

  /// Customer RIM number.
  final int rimNo;

  @override
  Widget build(BuildContext context) {
    String searchedEntity = "";
    return LabelWidget(
      label: "riskRating.entityId".tr(),
      isRequired: true,
      child: Row(
        key: UniqueKey(),
        children: [
          CustomTextField(
            semanticLabel: "riskRating.entityId".tr(),
            width: 200.w,
            onChanged: (value) {
              searchedEntity = value;
            },
            maxLength: 15,
          ),
          const Gap(direction: Axis.horizontal),
          CustomButton(
            semanticLabel: "riskRating.search".tr(),
            label: "riskRating.search".tr(),
            onPressed: () async {
              final int? entity = int.tryParse(searchedEntity);
              if (entity != null) {
                await viewModel.onSelectedEntities(
                  entity: entity,
                  rim: rimNo,
                  isSearchEntity: true,
                );
              } else {
                AlertManager().showFailureToast(
                  "common.validation.entityIdRequired".tr(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
