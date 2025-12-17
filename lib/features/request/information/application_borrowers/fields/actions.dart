import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/features/request/information/application_borrowers/model.dart';

class ActionWidget extends StatelessWidget {
  const ActionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ApplicationBorrowersViewModel>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CustomButton(
            label: 'requestInformation.applicationBorrowers.back'.tr(),
            onPressed: () {
              context.pop();
            }),
        const Gap(
          size: GapSize.medium,
          direction: Axis.horizontal,
        ),
        CustomButton(
            label: 'requestInformation.applicationBorrowers.saveContinue'.tr(),
            onPressed: () {
              viewModel.onSaveButtonPressed(context, navigationOrder: true);
            }),
      ],
    );
  }
}
