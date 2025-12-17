import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/form_row.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/model.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/borrower_search_name.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/search_header_section.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/widgets/search_rimno.dart';

class SearchBorrower extends StatelessWidget {
  final LinkContractViewModel viewModel;
  const SearchBorrower({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header + Back button
        const SearchHeaderSection(),
        const Gap(),
        // RIM No | Name | Proceed
        BoxLayout(
            extraPadding: true,
            child: FormRow(children: [
              // 1) RIM No
              SearchRimno(viewModel: viewModel),
              // 2) Name
              BorrowerSearchName(viewModel: viewModel),
              Padding(
                padding: const EdgeInsets.only(
                    top: AppStyle.linkContractProceedButton),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: CustomButton(
                    label: "project.linkContract.proceed".tr(),
                    semanticLabel: "project.linkContract.proceed".tr(),
                    onPressed: () async {
                      if (context.mounted) {
                        context.go(Routes.editViewProject);
                      }
                    },
                  ),
                ),
              ),
            ])),
      ],
    );
  }
}
