import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/group_borrowers/model.dart";

/// Displays the Borrowers field used in the Group Borrowers screen.
///
/// Allows users to view, select, and manage borrowers associated
/// with the current request.
class BorrowersField extends StatelessWidget {
  /// Creates a [BorrowersField].
  const BorrowersField({
    required this.viewModel,
    super.key,
  });

  /// View model that manages borrower data, selection state,
  /// and related user interactions.
  final GroupBorrowersViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomButton(
            label: "requestInformation.groupBorrowers.exclude".tr(),
            onPressed: viewModel.isReadOnly
                ? null
                : Utils.isGroupApplication()
                    ? viewModel.excludeSelectedBorrowers
                    : null,
          ),
          const Gap(),
          AddItemButton(
            onTap: viewModel.isReadOnly
                ? null
                : Utils.isGroupApplication()
                    ? viewModel.toggleAddRimSection
                    : null,
            isLeftSided: true,
            child: Text(
              "requestInformation.groupBorrowers.addPotentialRIM".tr(),
              style: const TextStyle(fontSize: AppStyle.fontSizeSmall),
            ),
          ),
        ],
      ),
    );
  }
}
