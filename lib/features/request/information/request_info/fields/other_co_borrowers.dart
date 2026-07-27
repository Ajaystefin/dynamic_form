import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/information/request_info/model.dart";
import "package:wcas_frontend/features/request/information/request_info/state.dart";
import "package:wcas_frontend/models/request/application_details.dart";

/// Displays the Other Co-Borrowers section on the Request Information screen.
///
/// Presents co-borrower details associated with the current request
/// and allows users to review or manage co-borrower information.
class OtherCoBorrowers extends StatelessWidget {
  /// Creates an [OtherCoBorrowers].
  const OtherCoBorrowers({
    required this.viewModel,
    required this.state,
    required this.row,
    super.key,
    this.width,
  });

  /// View model that provides request information data and
  /// manages co-borrower-related operations.
  final RequestInfoViewModel viewModel;

  /// Current state of the Request Information screen.
  final RequestInfoState state;

  /// Width used when rendering the co-borrower section.
  final double? width;

  /// Collection of co-borrowers displayed in the section.
  final List<CoBorrower>? row;

  @override
  Widget build(BuildContext context) {
    // Sync controllers with row length
    if (viewModel.rimControllers.length != (row?.length ?? 0)) {
      viewModel.initializeControllers(row ?? []);
    }

    return LabelWidget(
      label: "requestInformation.requestInformation.otherCoBorrowers".tr(),
      child: SizedBox(
        width: width,
        child: CustomRawTable(
          autoFitWidth: false,
          key: ValueKey(viewModel.coBorrowerList?.length ?? 0),
          columns: [
            TableColumn(
              width: 100.w,
              label: Text(
                "requestInformation.requestInformation.customerRIMNO".tr(),
              ),
            ),
            TableColumn(
              width: 100.w,
              label: Text(
                "requestInformation.requestInformation.customerName".tr(),
              ),
            ),
            if ((viewModel.coBorrowerList ?? []).isNotEmpty)
              TableColumn(width: 30.w, label: const Text(""))
            else
              TableColumn(width: 1.w, label: const Text("")),
          ],
          rows: List.generate(viewModel.coBorrowerList?.length ?? 0, (index) {
            if (index >= viewModel.rimControllers.length ||
                index >= viewModel.nameControllers.length) {
              return []; // Prevent index out of range
            }

            final CoBorrower? coborrower = viewModel.coBorrowerList?[index];
            final bool isValid = viewModel.canEdit;
            //  bool isValid = viewModel.canEdit
            //     ? viewModel.viewAccessRolesCheck()
            //         ? true
            //         : false
            //     : false;
            return [
              // RIM No Field
              CustomTextField(
                filled: !isValid,
                readOnly: !isValid,
                controller: viewModel.rimControllers[index],
                key: ValueKey("rim-${coborrower?.borrowerId}"),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(4),
                  child: DecoratedBox(
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
                key: ValueKey("name-${coborrower?.borrowerId}"),
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
                    key: ValueKey("delete-${coborrower?.borrowerId}"),
                    icon: const Icon(Icons.delete),
                    onPressed: () =>
                        isValid ? viewModel.removeCoBorrowerRow(index) : null,
                  );
                  // : const SizedBox();
                },
              ),
            ];
          }),
        ),
      ),
    );
  }
}
