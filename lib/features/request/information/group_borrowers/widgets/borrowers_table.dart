import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/information/group_borrowers/model.dart";
import "package:wcas_frontend/models/request/customer.dart";

class BorrowersTable extends StatelessWidget {
  const BorrowersTable({super.key});

  @override
  Widget build(BuildContext context) {
    final GroupBorrowersViewModel viewModel =
        context.watch<GroupBorrowersViewModel>();
    final List<Customer> borrowers = viewModel.borrowersList;

    return Column(
      children: [
        CustomRawTable(
          autoFitWidth: false,
          columns: [
            TableColumn(
              width: 120.w,
              label: Text("requestInformation.groupBorrowers.customerRim".tr()),
            ),
            TableColumn(
              width: 140.w,
              label: Text(
                "requestInformation.groupBorrowers.customerName".tr(),
              ),
            ),
            TableColumn(
              label: SizedBox(
                width: 80.w,
              ),
            ),
          ],
          rows: const [],
        ),
        SizedBox(
          height: 150.w,
          child: SingleChildScrollView(
            child: CustomRawTable(
              key: UniqueKey(),
              autoFitWidth: false,
              columnHeaderHeight: 0,
              columns: [
                TableColumn(width: 120.w, label: const SizedBox()),
                TableColumn(width: 140.w, label: const SizedBox()),
                TableColumn(
                  label: SizedBox(
                    width: 80.w,
                  ),
                ),
              ],
              rows: borrowers.map<List<Widget>>((customer) {
                final int? rim = customer.customerRimNo;
                Widget actionWidget;

                // If added via potential rim, show delete icon in front.
                if (viewModel.addedFromPotential.contains(rim)) {
                  actionWidget = IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.primary),
                    onPressed: () {
                      viewModel.isReadOnly
                          ? null
                          : viewModel.removePotentialBorrower(rim ?? 0);
                    },
                  );
                }
                // Otherwise, if manually added via non-borrowers selection,
                // show checkbox.
                else if (viewModel.isManuallyAdded(customer) &&
                    !customer.isPrimary) {
                  actionWidget = Checkbox(
                    value: viewModel.isSelectedForExclusion(customer),
                    activeColor: AppColors.primary,
                    onChanged: viewModel.isReadOnly
                        ? null
                        : (bool? newValue) {
                            viewModel.toggleBorrowerExclusion(
                              rim ?? 0,
                              newValue ?? false,
                            );
                          },
                  );
                } else {
                  actionWidget = const SizedBox.shrink();
                }
                return <Widget>[
                  Center(child: Text(rim.toString())),
                  Center(
                    child: CustomTooltip(
                      message: customer.concatCustomerFullName,
                      child: Text(
                        (customer.concatCustomerFullName),
                      ),
                    ),
                  ),
                  Center(child: actionWidget),
                ];
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
