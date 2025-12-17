import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/information/group_borrowers/model.dart';

class NonBorrowersTable extends StatelessWidget {
  const NonBorrowersTable({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GroupBorrowersViewModel>();
    final state = viewModel.state;

    if (state.isSearchingNonBorrowers) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // otherwise build the real table
    final nonBorrowers = viewModel.nonBorrowersList;
    return Column(
      children: [
        CustomRawTable(
          autoFitWidth: false,
          columns: [
            TableColumn(
                width: 120.w,
                label:
                    Text('requestInformation.groupBorrowers.customerRim'.tr())),
            TableColumn(
                width: 140.w,
                label: Text(
                    'requestInformation.groupBorrowers.customerName'.tr())),
            TableColumn(
                label: SizedBox(
              width: 80.w,
            )),
          ],
          rows: const [],
        ),
        SizedBox(
          height: nonBorrowers.length > 7 ? 150.w : null,
          child: SingleChildScrollView(
            child: CustomRawTable(
              key: UniqueKey(),
              autoFitWidth: false,
              columnHeaderHeight: 0.0,
              columns: [
                TableColumn(width: 120.w, label: const SizedBox()),
                TableColumn(width: 140.w, label: const SizedBox()),
                TableColumn(
                    label: SizedBox(
                  width: 80.w,
                )),
              ],
              rows: nonBorrowers.map((customer) {
                return <Widget>[
                  Center(child: Text(customer.customerRimNo.toString())),
                  Center(
                      child: Text(
                          (customer.displayName ?? customer.preferredName) ??
                              "")),
                  Center(
                    child: Checkbox(
                      value: viewModel.isSelectedForInclusion(customer),
                      activeColor: AppColors.primary,
                      onChanged: viewModel.isReadOnly
                          ? null
                          : (v) {
                              viewModel.toggleBorrowerSelection(
                                  customer.customerRimNo!, v ?? false);
                            },
                    ),
                  ),
                ];
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
