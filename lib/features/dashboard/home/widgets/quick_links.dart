import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/features/dashboard/home/model.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";

/// Displays quick links available on the dashboard home screen.
class QuickLinks extends StatefulWidget {
  /// Creates a [QuickLinks] widget.
  const QuickLinks(this.viewModel, {this.isMobile = false, super.key});

  /// Home dashboard view model used to handle quick link actions.
  final HomeViewModel viewModel;

  /// Indicates whether the quick links are displayed on a mobile layout.
  final bool isMobile;

  @override
  State<QuickLinks> createState() => _QuickLinksState();
}

class _QuickLinksState extends State<QuickLinks> {
  @override
  void initState() {
    // widget.viewModel.isQuickLinkClicked = !(widget.isMobile);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() {
            widget.viewModel.isQuickLinkClicked =
                !widget.viewModel.isQuickLinkClicked;
          }),
          child: Container(
            width: 300,
            decoration: BoxDecoration(
              color: AppColors.accordionPrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "dashboard.home.quickLinks".tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    !widget.viewModel.isQuickLinkClicked
                        ? Icons.keyboard_arrow_down_outlined
                        : Icons.keyboard_arrow_up_outlined,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.viewModel.isQuickLinkClicked)
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.accordionPrimary),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Wrap(
                spacing: 14,
                runSpacing: 14,
                alignment: WrapAlignment.center,
                children: [
                  // Reference Data Management — visible if user has right
                  if (AuthRepository.hasRight(
                    RightConstants.referenceDataManagement,
                  ))
                    iconButton(
                      icon: Icons.display_settings_sharp,
                      width: 80,
                      text: "layout.sidemenu.referenceDataManagement".tr(),
                      onTap: () => router.go(Routes.manageReference),
                    ),
                  // Role Right Mapping — visible if user has right
                  if (AuthRepository.hasRight(RightConstants.roleRightMapping))
                    iconButton(
                      icon: Icons.person,
                      width: 60,
                      text: "layout.sidemenu.roleRightMapping".tr(),
                      onTap: () => router.go(Routes.adminRoleRight),
                    ),
                  // File Access — visible if user has right
                  if (AuthRepository.hasRight(RightConstants.fileAccess))
                    iconButton(
                      icon: Icons.storage,
                      text: "layout.sidemenu.fileAccess".tr(),
                      onTap: () => router.go(Routes.fileAccess),
                    ),
                  // Create Request — visible if user has right
                  if (AuthRepository.hasRight(RightConstants.createNewRequest))
                    iconButton(
                      icon: Icons.add_box_outlined,
                      text: "dashboard.home.createRequest".tr(),
                      onTap: () => router.go(Routes.requestCreate),
                    ),
                  // Create CCSYS — visible if user has right
                  if (AuthRepository.hasRight(
                    RightConstants.createCcsysRequest,
                  ))
                    iconButton(
                      icon: Icons.update_outlined,
                      text: "dashboard.home.createCCSYS".tr(),
                      onTap: () => router.go(Routes.ccsysCreateRequest),
                    ),
                  // Update CCSYS — visible if user has right
                  if (AuthRepository.hasRight(
                    RightConstants.ccsysRequestInformation,
                  ))
                    iconButton(
                      icon: Icons.update_outlined,
                      text: "dashboard.home.updateCCSYS".tr(),
                      onTap: () => router.go(
                        Routes.closedRequest,
                        extra: ApplicationFilterType.ccsys,
                      ),
                    ),
                  // Approve CCSYS — visible if user has right
                  if (AuthRepository.hasRight(
                    RightConstants.ccsysRecommendationApproval,
                  ))
                    iconButton(
                      icon: Icons.update_outlined,
                      text: "dashboard.home.approveCCSYS".tr(),
                      onTap: () => router.go(
                        Routes.closedRequest,
                        extra: ApplicationFilterType.ccsys,
                      ),
                    ),
                  // Digital Filing — visible if user has right
                  if (AuthRepository.hasRight(RightConstants.digitalFiling))
                    iconButton(
                      onTap: () => router.go(Routes.digitalEFiling),
                      icon: Icons.file_present_outlined,
                      text: "dashboard.home.digitalFiling".tr(),
                    ),
                  // Create/View Project — visible if user has right
                  if (AuthRepository.hasRight(RightConstants.createProject))
                    iconButton(
                      icon: Icons.settings_applications_outlined,
                      text: "dashboard.home.createViewProject".tr(),
                      onTap: () => router.go(Routes.searchProject),
                    ),
                  // Closed Request — visible if user has right
                  if (AuthRepository.hasRight(RightConstants.closedRequest))
                    iconButton(
                      icon: Icons.close_fullscreen,
                      text: "dashboard.home.closedRequest".tr(),
                      onTap: () => router.go(Routes.closedRequest),
                    ),
                  if (AuthRepository.hasRight(
                    RightConstants.userManual,
                  ))
                    iconButton(
                      icon: Icons.menu_book_outlined,
                      text: "dashboard.home.userManual".tr(),
                      onTap: widget.viewModel.downloadUserManual,
                    ),
                  if (AuthRepository.hasRight(
                    RightConstants.spreadSmartManual,
                  ))
                    iconButton(
                      icon: Icons.dataset_outlined,
                      text: "dashboard.home.spreadSmart".tr(),
                      onTap: widget.viewModel.downloadSpreadSmart,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget iconButton({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
    double? width,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 35, color: AppColors.teal),
          SizedBox(
            width: width ?? 50,
            child: Text(
              text,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
