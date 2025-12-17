import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

class SearchHeaderSection extends StatelessWidget {
  const SearchHeaderSection({super.key});

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
          onPressed: () {
            if (context.mounted) {
              context.go(Routes.searchProject);
            }
          },
        ),
      ],
    );
  }
}
