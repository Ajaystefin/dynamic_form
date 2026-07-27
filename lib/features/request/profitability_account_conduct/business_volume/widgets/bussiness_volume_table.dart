import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/business_volume/model.dart";
import "package:wcas_frontend/models/request/profitability/business_volume.dart";

/// Business volume table.
class BusinessVoumeTable extends StatefulWidget {
  /// Creates a business volume table.
  const BusinessVoumeTable({
    required this.viewModel,
    required this.businessVolumes,
    super.key,
  });

  /// Business volume view model.
  final BusinessVolumeViewModel viewModel;

  /// Business volumes list.
  final List<BusinessVolume> businessVolumes;

  @override
  State<BusinessVoumeTable> createState() => _BusinessVoumeTableState();
}

class _BusinessVoumeTableState extends State<BusinessVoumeTable> {
  @override
  Widget build(BuildContext context) {
    final bool isEmpty = widget.businessVolumes.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header suffix (AED Value)
        Align(
          alignment: Alignment.centerRight,
          child: CustomSelectableText(
            text: "profitabilityAccountConduct.accountStats.aedValue".tr(),
            textAlign: TextAlign.right,
            style: AppStyle.tableSuffixHeaderStyle,
          ),
        ),

        // Always render the table header + structure
        CustomRawTable(
          key: UniqueKey(),
          columns: getTableColumns(context, widget.viewModel),
          rows: List.generate(widget.businessVolumes.length, (index) {
            final BusinessVolume item = widget.businessVolumes[index];
            return [
              Text("${item.natureOfBusiness}"),
              Text(
                item.previousYear != null ? item.previousYear ?? "" : "",
                style: const TextStyle(color: AppColors.primary),
              ),
              Text(
                item.currentYearYtd != null ? item.currentYearYtd ?? "" : "",
                style: const TextStyle(color: AppColors.primary),
              ),
              CustomTextField(
                initialValue: item.estimatesForNextYear ?? "",
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  DecimalInputFormatter(
                    regEx: RegExp(r"^[0-9,]{0,15}(\.\d{0,6})?$"),
                  ),
                ],
                onSaved: (value) {
                  item.estimatesForNextYear = value;
                },
                onSubmitted: (value) {
                  item.estimatesForNextYear = value;
                },
              ),
            ];
          }),
        ),

        // Empty state UNDER the header
        if (isEmpty)
          Center(
            child: Text(
              "common.emptyState".tr(),
            ),
          ),
      ],
    );
  }

  /// Returns business volume table columns.
  List<TableColumn> getTableColumns(
    BuildContext context,
    BusinessVolumeViewModel viewModel,
  ) {
    return [
      TableColumn(
        width: 200.w,
        label: Text(
          "profitabilityAccountConduct.businessVolume.natureOfBussiness".tr(),
          style: const TextStyle(fontSize: 12),
        ),
      ),
      TableColumn(
        width: 200.w, //previousYear
        label: Text(
          viewModel.getPreviousYearLabel(context),
          style: const TextStyle(fontSize: 12),
        ),
      ),
      TableColumn(
        width: 200.w, //currentYear
        label: Text(
          viewModel.getCurrentYearLabel(context),
          style: const TextStyle(fontSize: 12),
        ),
      ),
      TableColumn(
        width: 200.w,
        label: Text(
          "profitabilityAccountConduct.businessVolume.estimatesForNextYear"
              .tr(),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    ];
  }
}
