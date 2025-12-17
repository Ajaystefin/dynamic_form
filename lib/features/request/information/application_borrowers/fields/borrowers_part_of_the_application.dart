import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/checkbox.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/features/request/information/application_borrowers/model.dart';
import 'package:wcas_frontend/features/request/information/application_borrowers/state.dart';
import 'package:wcas_frontend/models/request/customer.dart';

class BorrowersPartOfTheApplication extends StatefulWidget {
  const BorrowersPartOfTheApplication({super.key});

  @override
  State<BorrowersPartOfTheApplication> createState() =>
      _BorrowersPartOfTheApplicationState();
}

class _BorrowersPartOfTheApplicationState
    extends State<BorrowersPartOfTheApplication> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ApplicationBorrowersViewModel>();

    return BlocBuilder<ApplicationBorrowersViewModel,
        ApplicationBorrowersState>(
      builder: (context, state) {
        return CustomRawTable(
          key: UniqueKey(),
          columns: [
            TableColumn(
              label: Text(
                'requestInformation.applicationBorrowers.customerRim'.tr(),
              ),
            ),
            TableColumn(
              label: Text(
                'requestInformation.applicationBorrowers.customerName'.tr(),
              ),
            ),
            TableColumn(
                label: Text((viewModel.showCurrentFiCreditRisk)
                    ? 'requestInformation.applicationBorrowers.bankInvestmentGrade'
                        .tr()
                    : '')),
            if (viewModel.showCurrentFiCreditRisk)
              TableColumn(
                label: Text(
                    'requestInformation.applicationBorrowers.bankBelowInvestmentGrade'
                        .tr()),
              ),
          ],
          rows: viewModel.customers.map((customer) {
            final rimKey = customer.customerRimNo.toString();
            final isSelected = customer.isSelected;
            final isSelectedBelowGrade = customer.isSelectedBelowGrade;
            return _buildRow(
                viewModel: viewModel,
                customer: customer,
                valueBelowGrade: isSelectedBelowGrade,
                value: isSelected,
                onChanged: (val) {
                  viewModel.onCustomerRimNameSelected(rimKey, val ?? false);
                },
                onChangedBelowGrade: (val) {
                  viewModel.onBelowGradeSelected(rimKey, val ?? false);
                });
          }).toList(),
        );
      },
    );
  }

  List<Widget> _buildRow({
    required Customer? customer,
    required bool? value,
    bool? valueBelowGrade,
    required void Function(bool?) onChanged,
    required void Function(bool?) onChangedBelowGrade,
    required ApplicationBorrowersViewModel viewModel,
  }) {
    return [
      Center(
        child: Text(
          customer?.customerRimNo.toString() ?? "",
        ),
      ),
      Center(
        child: Text(
          customer?.displayRIMName ?? "",
        ),
      ),
      Align(
        alignment: AlignmentDirectional.center,
        child: CustomCheckbox(
          value: value ?? false,
          onChange: onChanged,
        ),
      ),
      if (viewModel.showCurrentFiCreditRisk)
        Align(
          alignment: AlignmentDirectional.center,
          child: CustomCheckbox(
            value: valueBelowGrade ?? false,
            onChange: onChangedBelowGrade,
          ),
        )
    ];
  }
}
