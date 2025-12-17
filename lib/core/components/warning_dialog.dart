import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/services/session/cubit.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';

class SessionWarningDialog extends StatelessWidget {
  const SessionWarningDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        int secondsRemaining = state.secondsRemaining ?? 0;
        int minuteRemaining = state.minuteRemaining ?? 0;

        return Column(
          children: [
            Text(
              //${"common.session.graceIdleTime".tr()} ${state.idleMinute.toString().padLeft(2, '0')} Minutes.
              "common.session.gracePeriodPopupContent".tr(),
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Gap(),
            Text(
              "${minuteRemaining.toString().padLeft(2, '0')}:${secondsRemaining.toString().padLeft(2, '0')}",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 24,
                    color: AppColors.buttonBackground,
                  ),
              textAlign: TextAlign.center,
            ),
            const Gap(),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: CustomButton(
                    backgroundColor: AppColors.dialogTitleColor,
                    textColor: AppColors.white,
                    label: "common.session.gracePeriodLogoutButton".tr(),
                    onPressed: onLogoutPressed,
                  ),
                ),
                const Gap(direction: Axis.horizontal),
                Flexible(
                  child: CustomButton(
                    backgroundColor: AppColors.dialogTitleColor,
                    textColor: AppColors.white,
                    label: "common.session.gracePeriodContinueButton".tr(),
                    onPressed: () async {
                      onContinuePressed(context);
                    },
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Future<void> onLogoutPressed() async {
    await AuthRepository.instance.logout();
  }

  Future<void> onContinuePressed(BuildContext context) async {
    Navigator.of(context).pop();
    context.read<SessionCubit>().userInteracted();
  }
}
