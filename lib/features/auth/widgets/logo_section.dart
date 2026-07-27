import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/constants/constants.dart";

/// Displays the application logo and title section.
class LogoSection extends StatelessWidget {
  /// Creates a [LogoSection].
  const LogoSection({
    required this.width,
    super.key,
    this.height,
  });

  /// Width of the logo section.
  final double width;

  /// Optional height of the logo section.
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                child: Image.asset(
                  AppAssets.logo,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              CustomSelectableText(
                text: "auth.login.appName".tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
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
