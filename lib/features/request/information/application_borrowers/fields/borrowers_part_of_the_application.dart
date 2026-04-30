import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/features/request/information/application_borrowers/model.dart";
import "package:wcas_frontend/features/request/information/application_borrowers/state.dart";
import "package:wcas_frontend/models/request/customer.dart";

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
        final bool showCountryColumn = viewModel.isFI &&
            viewModel.customers.any((c) => c.isCountryFI == true);

        return CustomRawTable(
          key: viewModel.isReadOnly
              ? const ValueKey("BorrowersTable")
              : UniqueKey(),
          columns: [
            TableColumn(
              label: Text(
                "requestInformation.applicationBorrowers.customerRim".tr(),
              ),
            ),
            TableColumn(
              label: Text(
                "requestInformation.applicationBorrowers.customerName".tr(),
              ),
            ),

            // COUNTRY column (always visible in FI screen)
            if (showCountryColumn)
              TableColumn(
                label: Text(
                  "requestInformation.applicationBorrowers.country".tr(),
                ),
              ),

            // IG column
            TableColumn(
              label: Text(
                viewModel.isFI
                    ? "requestInformation.applicationBorrowers."
                            "bankInvestmentGrade"
                        .tr()
                    : "",
              ),
            ),

            // BIG column
            if (viewModel.isFI)
              TableColumn(
                label: Text(
                  "requestInformation.applicationBorrowers."
                          "bankBelowInvestmentGrade"
                      .tr(),
                ),
              ),
          ],
          rows: viewModel.customers.map((customer) {
            final bool isOwner = viewModel.primaryRim != null &&
                customer.customerRimNo == viewModel.primaryRim;
            return _buildRow(
              viewModel: viewModel,
              customer: customer,
              showCountryColumn: showCountryColumn,
              onChangedCountry: (val) => viewModel.onCountrySelected(
                customer.customerRimNo.toString(),
                val ?? false,
              ),
              isOwner: (!viewModel.isFI) ? isOwner : false,
              onChangedIG: (val) => viewModel.onCustomerRimNameSelected(
                customer.customerRimNo.toString(),
                val ?? false,
              ),
              onChangedBIG: (val) => viewModel.onBelowGradeSelected(
                customer.customerRimNo.toString(),
                val ?? false,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  List<Widget> _buildRow({
    required Customer customer,
    required bool? isOwner,
    required bool showCountryColumn,
    required void Function(bool?) onChangedIG,
    required void Function(bool?) onChangedBIG,
    required void Function(bool?) onChangedCountry,
    required ApplicationBorrowersViewModel viewModel,
  }) {
    final bool isCountryFI = customer.isCountryFI == true;

    return [
      // RIM
      Center(child: Text(customer.customerRimNo.toString())),

      // Customer Name
      Center(
        child: CustomTooltip(
          message: customer.concatCustomerFullName,
          child: Text(
            (customer.concatCustomerFullName),
          ),
        ),
      ),

      // COUNTRY column
      if (showCountryColumn)
        Align(
          alignment: Alignment.center,
          child: isCountryFI
              ? CustomCheckbox(
                  value: customer.isSelectedCountryFI ?? false,
                  onChange: onChangedCountry,
                )
              : const Text("—"),
        ),

      // IG column
      Align(
        alignment: Alignment.center,
        child: isCountryFI
            ? const Text("—") // text only for country row
            : IgnorePointer(
                ignoring: isOwner ?? false,
                child: CustomCheckbox(
                  value: customer.isSelected ?? false,
                  onChange: onChangedIG,
                ),
              ),
        // CustomCheckbox(
        //     value: customer.isSelected ?? false,
        //     onChange: onChangedIG,
        //   ),
      ),

      // BIG column
      if (viewModel.isFI)
        Align(
          alignment: Alignment.center,
          child: isCountryFI
              ? const Text("—") // text only for country row
              : IgnorePointer(
                  ignoring: isOwner ?? false,
                  child: CustomCheckbox(
                    value: customer.isSelectedBelowGrade ?? false,
                    onChange: onChangedBIG,
                  ),
                ),
          // CustomCheckbox(
          //     value: customer.isSelectedBelowGrade ?? false,
          //     onChange: onChangedBIG,
          //   ),
        ),
    ];
  }
}
