import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/services/route_service.dart';

class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.2,
            top: MediaQuery.of(context).size.height * 0.2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "common.components.notFoundView.oops".tr(),
              style: const TextStyle(
                  fontSize: 24,
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w700),
            ),
            const Gap(),
            Text(
              "common.components.notFoundView.notFound".tr(),
              style: AppStyle.boldLabel,
            ),
            const Gap(),
            Text(
              "common.components.notFoundView.guide".tr(),
            ),
            const Gap(),
            InkWell(
              onTap: () {
                router.go(Routes.home);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "common.components.notFoundView.actionButton".tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Icon(Icons.chevron_right_outlined, color: AppColors.primary)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
