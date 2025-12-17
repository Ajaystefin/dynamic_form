import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/text_utils.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/business_volume/model.dart';
import 'package:wcas_frontend/models/request/profitability/business_volume.dart';

class BusinessVoumeTable extends StatefulWidget {
  final BusinessVolumeViewModel viewModel;
  final List<BusinessVolume> businessVolumes;
  const BusinessVoumeTable(
      {super.key, required this.viewModel, required this.businessVolumes});

  @override
  State<BusinessVoumeTable> createState() => _BusinessVoumeTableState();
}

class _BusinessVoumeTableState extends State<BusinessVoumeTable> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: CustomSelectableText(
            text: "profitabilityAccountConduct.accountStats.aedValue".tr(),
            textAlign: TextAlign.right,
            style: AppStyle.tableSuffixHeaderStyle,
          ),
        ),
        CustomRawTable(
          // autoFitWidth: false,
          key: UniqueKey(),
          columns: getTableColumns(),
          rows: List.generate(widget.businessVolumes.length, (index) {
            return [
              Text(
                "${widget.businessVolumes[index].natureOfBusiness}",
                // initialValue: '${owner?.nationality}',
              ),
              Text(
                widget.businessVolumes[index].previousYear
                   ?.toStringAsFixed(2)
                    .formatNumber() ??
                    "",
                style: const TextStyle(color: AppColors.primary),
                // initialValue: '${owner?.nationality}',
              ),
              Text(
                widget.businessVolumes[index].currentYearYtd
                   ?.toStringAsFixed(2)
                    .formatNumber() ??
                    "",
                style: const TextStyle(color: AppColors.primary),
                // initialValue: '${owner?.nationality}',
              ),
              CustomTextField(
                initialValue: widget.businessVolumes[index].estimatesForNextYear
                   ?.toStringAsFixed(2),
                // readOnly: true,
                // filled: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12)
                ],
                // maxLength: 3,
                onChanged: (value) {
                  widget.businessVolumes[index].estimatesForNextYear =
                      double.tryParse(value);
                },
              ),
            ];
          }),
        ),
      ],
    );
  }

  List<TableColumn> getTableColumns() {
    return [
      TableColumn(
          width: 200.w,
          label: Text(
            key: UniqueKey(),
            "profitabilityAccountConduct.businessVolume.natureOfBussiness".tr(),
            style: const TextStyle(fontSize: 12),
          )),
      TableColumn(
          width: 200.w,
          label: Text(
            key: UniqueKey(),
            "profitabilityAccountConduct.businessVolume.previousYear".tr(),
            style: const TextStyle(fontSize: 12),
          )),
      TableColumn(
          width: 200.w,
          label: Text(
            key: UniqueKey(),
            "profitabilityAccountConduct.businessVolume.currentYear".tr(),
            style: const TextStyle(fontSize: 12),
          )),
      TableColumn(
          width: 200.w,
          label: Text(
            key: UniqueKey(),
            "profitabilityAccountConduct.businessVolume.estimatesForNextYear"
                .tr(),
            style: const TextStyle(fontSize: 12),
          ))
    ];
  }
}
