import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/constants.dart";

class LogoSection extends StatelessWidget {
  const LogoSection({
    required this.width,
    super.key,
    this.height,
  });
  final double width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: height ?? 300),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppAssets.logo,
              ),
              const SizedBox(height: 20),
              CustomSelectableText(
                text: "auth.login.appName".tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
