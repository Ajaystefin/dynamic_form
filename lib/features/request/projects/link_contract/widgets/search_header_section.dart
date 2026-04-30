import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";

class SearchHeaderSection extends StatelessWidget {
  const SearchHeaderSection({required this.viewModel, super.key});
  final LinkContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomSectionHeader(
          title: "project.linkContract.searchBorrower".tr(),
        ),
        const Spacer(),
        CustomButton(
          leadingIcon: const Icon(Icons.arrow_back, color: AppColors.white),
          label: "project.linkContract.backToRequestStatus".tr(),
          semanticLabel: "project.linkContract.backToRequestStatus".tr(),
          onPressed: () async {
            await viewModel.onBacktoRequestStatusPressed(context);
          },
        ),
      ],
    );
  }
}
