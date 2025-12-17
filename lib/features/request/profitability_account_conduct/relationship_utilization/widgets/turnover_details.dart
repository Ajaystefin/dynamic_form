import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/model.dart';
import 'package:wcas_frontend/models/request/profitability/relationship_utilization.dart';

class TurnOverDetails extends StatelessWidget {
  final RelationshipUtilization relationshipUtilization;
  final int index;
  final RelationshipUtilizationViewModel viewModel;

  const TurnOverDetails({
    super.key,
    required this.relationshipUtilization,
    required this.index,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: isWide
                  ? (constraints.maxWidth / 3) - 16
                  : constraints.maxWidth,
              child: LabelWidget(
                label:
                    "profitabilityAccountConduct.relationshipUtilisation.clientTurnover"
                        .tr(),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                child: CustomTextField(
                  semanticLabel:
                      "profitabilityAccountConduct.relationshipUtilisation.clientTurnover"
                          .tr(),
                  initialValue:
                      relationshipUtilization.clientTurnover?.toString() ?? "",
                  filled: false,
                  readOnly: false,
                  inputFormatters: [DecimalInputFormatter()],
                  validator: !viewModel.isFIApplication
                      ? CustomValidator.requiredField
                      : null,
                  onChanged: (value) {
                    viewModel.calculatePercentage(
                      clientTurnOver: double.tryParse(value) ?? 0.0,
                      index: index,
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              width: isWide
                  ? (constraints.maxWidth / 3) - 16
                  : constraints.maxWidth,
              child: LabelWidget(
                label:
                    "profitabilityAccountConduct.relationshipUtilisation.turnoverinCBDCUA"
                        .tr(),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                child: CustomTextField(
                  semanticLabel:
                      "profitabilityAccountConduct.relationshipUtilisation.turnoverinCBDCUA"
                          .tr(),
                  initialValue:
                      relationshipUtilization.turnoverInCbdCua?.toString() ??
                          "",
                  filled: true,
                  readOnly: true,
                ),
              ),
            ),
            SizedBox(
              width: isWide
                  ? (constraints.maxWidth / 3) - 16
                  : constraints.maxWidth,
              child: LabelWidget(
                label:
                    "profitabilityAccountConduct.relationshipUtilisation.throughputtoCBD"
                        .tr(),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                child: CustomTextField(
                  semanticLabel:
                      "profitabilityAccountConduct.relationshipUtilisation.throughputtoCBD"
                          .tr(),
                  hintText:
                      "${relationshipUtilization.throughputToCbdPercentage ?? ''}",
                  filled: true,
                  readOnly: true,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
