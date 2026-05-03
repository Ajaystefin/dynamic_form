import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";

class GuardedBlockFormatter extends TextInputFormatter {
  GuardedBlockFormatter({
    required this.shouldBlock,
    this.onBlocked,
    this.blockOnTrue = true,
  });
  final bool Function(int attempted) shouldBlock;
  final void Function(int attempted)? onBlocked;

  final bool blockOnTrue;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldV,
    TextEditingValue newV,
  ) {
    final String rawNew = newV.text.replaceAll(",", "");
    final String rawOld = oldV.text.replaceAll(",", "");

    // Allow clearing
    if (rawNew.isEmpty) return newV;

    final int attemptedNew = int.tryParse(rawNew) ?? 0;
    final int attemptedOld = int.tryParse(rawOld) ?? 0;

    final bool newBlocked = shouldBlock(attemptedNew);
    final bool oldBlocked = shouldBlock(attemptedOld);
    if (newBlocked && !oldBlocked) {
      onBlocked?.call(attemptedNew);
      if (blockOnTrue) return oldV;
    }

    if (blockOnTrue && newBlocked) {
      return oldV;
    }
    return newV;
  }
}

class LimitAllocationTable extends StatelessWidget {
  const LimitAllocationTable({
    required this.viewModel,
    super.key,
  });
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "facilities.createFacility.limitAllocation".tr(),
      child: SizedBox(
        height: 0.2.h,
        child: SingleChildScrollView(
          child: CustomRawTable(
            key: UniqueKey(),
            columns: [
              TableColumn(
                label: Text("facilities.createFacility.customerRIM".tr()),
              ),
              TableColumn(
                label: Text("facilities.createFacility.amountAed".tr()),
              ),
            ],
            rows: viewModel.borrowersByRimInTable.map((borrower) {
              return [
                Center(child: Text("RIM NO ${borrower.name ?? ""}")),
                Center(
                  child: CustomTextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"^\d{0,21}(?:\.\d{0,6})?$"),
                      ),
                      LengthLimitingTextInputFormatter(
                        28,
                      ), // 21 digits + 6 decimals + 1 for dot
                      GuardedBlockFormatter(
                        blockOnTrue: false,
                        shouldBlock: (attempted) {
                          final int cap = viewModel.effectiveProposedLimit;

                          final int otherTotal = viewModel.borrowersByRimInTable
                              .where((b) => !identical(b, borrower))
                              .map(
                                (b) =>
                                    int.tryParse(
                                      (b.description ?? "").replaceAll(",", ""),
                                    ) ??
                                    0,
                              )
                              .fold(0, (s, v) => s + v);

                          final bool exceedsSingle = attempted > cap;
                          final bool exceedsTotal =
                              (attempted + otherTotal) > cap;

                          return exceedsSingle || exceedsTotal;
                        },
                        onBlocked: null,
                      ),
                    ],
                    initialValue: borrower.description,

                    // initialValue: !viewModel.isSubLimitMode
                    //     ? borrower.description
                    //     : viewModel.getFacility.proposedLimit
                    //         .toString(), // NOTE --> no defualt values should be here  remove proposedLimit confirmed with jessy 10/Mar-2026
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: false),
                    onChanged: (allocationAmount) {
                      viewModel.compareAllocationAmount(
                        allocationAmount,
                        borrower,
                      );
                    },
                  ),
                ),
              ];
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class ThousandsSeparatorFormatter extends TextInputFormatter {
  final NumberFormat _fmt = NumberFormat("#,###");

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldV,
    TextEditingValue newV,
  ) {
    final raw = newV.text.replaceAll(",", "");
    if (raw.isEmpty) return const TextEditingValue(text: "");
    if (!RegExp(r"^\d+$").hasMatch(raw)) return oldV;

    final formatted = _fmt.format(int.parse(raw));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
