import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/information/request_info/model.dart';
import 'package:wcas_frontend/features/request/information/request_info/state.dart';
import 'package:wcas_frontend/models/request/application_details.dart';

class OtherCoBorrowers extends StatelessWidget {
  const OtherCoBorrowers({
    super.key,
    required this.viewModel,
    required this.state,
    this.width,
    required this.row,
  });

  final RequestInfoViewModel viewModel;
  final RequestInfoState state;
  final double? width;
  final List<CoBorrower>? row;

  @override
  Widget build(BuildContext context) {
    // Sync controllers with row length
    if (viewModel.rimControllers.length != (row?.length ?? 0)) {
      viewModel.initializeControllers(row ?? []);
    }

    return LabelWidget(
      label: 'requestInformation.requestInformation.otherCoBorrowers'.tr(),
      showLabel: true,
      isRequired: false,
      child: SizedBox(
        width: width,
        child: CustomRawTable(
          autoFitWidth: false,
          key: ValueKey(viewModel.borrowerList?.length ?? 0),
          columns: [
            TableColumn(
                width: 100.w,
                label: Text(
                    'requestInformation.requestInformation.customerRIMNO'
                        .tr())),
            TableColumn(
                width: 100.w,
                label: Text(
                    'requestInformation.requestInformation.customerName'.tr())),
            ((viewModel.borrowerList ?? []).isNotEmpty)
                ? TableColumn(width: 30.w, label: const Text(''))
                : TableColumn(width: 1.w, label: const Text('')),
          ],
          rows: List.generate(viewModel.borrowerList?.length ?? 0, (index) {
            if (index >= viewModel.rimControllers.length ||
                index >= viewModel.nameControllers.length) {
              return []; // Prevent index out of range
            }

            CoBorrower? coborrower = viewModel.borrowerList?[index];
            bool isValid = viewModel.canEdit
                ? viewModel.viewAccessRolesCheck()
                    ? true
                    : false
                : false;
            return [
              // RIM No Field
              CustomTextField(
                filled: !isValid,
                readOnly: !isValid,
                controller: viewModel.rimControllers[index],
                key: ValueKey('rim-${coborrower?.borrowerId}'),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: InkWell(
                      onTap: () async {
                        final rimNo = viewModel.rimControllers[index].text;
                        await viewModel.updateRimNo(rimNo, index);
                        // No setState needed because controller updates UI
                      },
                      child: const Icon(
                        Icons.search_rounded,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Customer Name Field
              CustomTextField(
                key: ValueKey('name-${coborrower?.borrowerId}'),
                controller: viewModel.nameControllers[index],
                filled: true,
                readOnly: true,
              ),

              // Delete Button
              AnimatedBuilder(
                animation: viewModel.nameControllers[index],
                builder: (context, _) {
                  return
                      // viewModel.nameControllers[index].text.isNotEmpty
                      // ?
                      IconButton(
                    key: ValueKey('delete-${coborrower?.borrowerId}'),
                    icon: const Icon(Icons.delete),
                    onPressed: () =>
                        isValid ? viewModel.removeCoBorrowerRow(index) : null,
                  );
                  // : const SizedBox();
                },
              )
            ];
          }),
        ),
      ),
    );
  }
}
