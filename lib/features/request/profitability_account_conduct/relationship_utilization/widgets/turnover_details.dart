import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/relationship_utilization/state.dart";
import "package:wcas_frontend/models/request/profitability/relationship_utilization.dart";

/// Turnover details.
class TurnOverDetails extends StatelessWidget {
  /// Creates turnover details.
  const TurnOverDetails({
    required this.relationshipUtilization,
    required this.index,
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// Relationship utilization data.
  final RelationshipUtilization? relationshipUtilization; // can be null

  /// Relationship utilization index.
  final int index;

  /// Relationship utilization view model.
  final RelationshipUtilizationViewModel viewModel;

  /// Relationship utilization state.
  final RelationshipUtilizationState state;

  @override
  Widget build(BuildContext context) {
    if (relationshipUtilization == null) {
      return const SizedBox.shrink();
    }

    return (state.turnOverStatus == LoadingStatus.loaded)
        ? LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth > 600;
              final double fieldWidth = isWide
                  ? (constraints.maxWidth / 3) - 16
                  : constraints.maxWidth;

              return Wrap(
                spacing: fieldWidth / 25,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Client Turnover (editable)
                  SizedBox(
                    width: fieldWidth,
                    child: LabelWidget(
                      label: "profitabilityAccountConduct."
                              "relationshipUtilisation.clientTurnover"
                          .tr(),
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      child: CustomTextField(
                        semanticLabel: "profitabilityAccountConduct."
                                "relationshipUtilisation.clientTurnover"
                            .tr(),
                        controller: viewModel.clientCtrlAt(index),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          NumericDecimalTextInputFormatter(
                            maxIntegerDigits: 15,
                            maxDecimalDigits: 6,
                          ),
                        ],
                        validator: !viewModel.isFIApplication
                            ? CustomValidator.requiredField
                            : null,

                        // Trigger calc when user submits (keyboard "Done"/"Enter")
                        onSubmitted: (_) {
                          viewModel.recalcPercentage(index);
                        },

                        // (Optional) live updates on every keystroke
                        onChanged: (_) => viewModel.recalcPercentage(index),
                      ),
                    ),
                  ),

                  // Turnover in CBD/CUA (read-only)
                  SizedBox(
                    width: fieldWidth,
                    child: LabelWidget(
                      label: "profitabilityAccountConduct."
                              "relationshipUtilisation.turnoverinCBDCUA"
                          .tr(),
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      child: CustomTextField(
                        semanticLabel: "profitabilityAccountConduct."
                                "relationshipUtilisation.turnoverinCBDCUA"
                            .tr(),
                        controller: viewModel.cbdCtrlAt(index),
                        filled: true,
                        readOnly: true,
                      ),
                    ),
                  ),

                  // Throughput to CBD % (read-only, auto-updates)
                  SizedBox(
                    width: fieldWidth,
                    child: LabelWidget(
                      label: "profitabilityAccountConduct."
                              "relationshipUtilisation.throughputtoCBD"
                          .tr(),
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      child: CustomTextField(
                        semanticLabel: "profitabilityAccountConduct."
                                "relationshipUtilisation.throughputtoCBD"
                            .tr(),
                        controller: viewModel.pctCtrlAt(index),
                        filled: true,
                        readOnly: true,
                      ),
                    ),
                  ),
                ],
              );
            },
          )
        : const CircularProgressIndicator();
  }
}
