import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/information/security_perfection/model.dart";
import "package:wcas_frontend/models/request/security_deferral.dart";

/// Displays the linked facilities table.
class LinkedFacilities extends StatelessWidget {
  /// Creates a [LinkedFacilities] widget.
  const LinkedFacilities({
    required this.viewModel,
    required this.info,
    super.key,
  });

  /// View model used by the widget.
  final SecurityPerfectionViewModel viewModel;

  /// Security deferral information used by the widget.
  final SecurityDeferral info;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomRawTable(
          rowsPerPage: 5,
          // key: UniqueKey(),
          columns: [
            TableColumn(
              label: Text(
                "requestInformation.securityPerfection.limitNumber".tr(),
              ),
            ),
            TableColumn(
              label: Text("requestInformation.securityPerfection.rimNo".tr()),
            ),
            TableColumn(
              label: Text(
                "requestInformation.securityPerfection.limitDescription".tr(),
              ),
            ),
            TableColumn(
              label: Text(
                "requestInformation.securityPerfection.limitAmount".tr(),
              ),
            ),
            TableColumn(
              label: Text(
                "requestInformation.securityPerfection.amountToBeReleased".tr(),
              ),
            ),
          ],
          rows: List.generate((info.facilityDetails ?? []).length, (index) {
            final infos = (info.facilityDetails ?? [])[index];

            return [
              Text(infos.limitNumber ?? ""),
              Text(infos.rimNo ?? ""),
              Text(infos.limitDescription ?? ""),
              Text(infos.limitAmountAED000s.toString()),
              CustomTextField(
                initialValue: infos.amountToBeReleased.toString(),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (String? value) {
                  infos.amountToBeReleased = double.tryParse(value ?? "");
                },
                onSaved: (String? value) {
                  infos.amountToBeReleased = double.tryParse(value.toString());
                },
              ),

              // attachIcon(info.isChecked),
            ];
          }),
        ),
        if ((info.facilityDetails ?? []).isEmpty)
          const Center(child: Text("No Data Found")),
      ],
    );
  }
}
