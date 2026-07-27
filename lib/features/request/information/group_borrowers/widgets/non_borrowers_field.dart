import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/information/group_borrowers/model.dart";

/// Displays controls for searching and including non-borrowers
/// in the Group Borrowers screen.
///
/// Allows users to search for customers by RIM number and include
/// eligible customers as borrowers in the request.
class NonBorrowersField extends StatelessWidget {
  /// Creates a [NonBorrowersField].
  const NonBorrowersField({
    required this.viewModel,
    super.key,
  });

  /// View model that manages borrower search, selection,
  /// and inclusion operations.
  final GroupBorrowersViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    String rimInput = "";
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CustomTextField(
            readOnly: viewModel.isReadOnly,
            width: AppStyle.groupBorrowersTextField,
            hintText:
                "requestInformation.groupBorrowers.searchCustomerRim".tr(),
            initialValue: rimInput,
            fillColor: AppColors.textFieldDisabledFill,
            validator: CustomValidator.requiredField,
            onChanged: (value) {
              rimInput = value;
            },
          ),
          const Gap(direction: Axis.horizontal),
          CustomButton(
            label: "requestInformation.groupBorrowers.search".tr(),
            leadingIcon: const Icon(
              Icons.search,
              color: AppColors.white,
            ),
            onPressed: viewModel.isReadOnly
                ? null
                : () {
                    viewModel.updateNonBorrowersSearchQuery(rimInput);
                  },
          ),
          const Gap(direction: Axis.horizontal),
          CustomButton(
            label: "requestInformation.groupBorrowers.include".tr(),
            onPressed: viewModel.isReadOnly
                ? null
                : Utils.isGroupApplication()
                    ? viewModel.includeSelectedBorrowers
                    : null,
          ),
        ],
      ),
    );
  }
}
