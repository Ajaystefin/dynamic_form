import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/home/model.dart";

class QuickLinks extends StatefulWidget {
  const QuickLinks(this.viewModel, {this.isMobile = false, super.key});
  final HomeViewModel viewModel;
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
              border: Border.all(
                color: AppColors.accordionPrimary,
              ),
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
                  if (Utils.checkRole(UserRole.admin)) ...[
                    iconButton(
                      icon: Icons.display_settings_sharp,
                      width: 80,
                      text: "layout.sidemenu.referenceDataManagement".tr(),
                      onTap: () => router.go(Routes.manageReference),
                    ),
                    iconButton(
                      icon: Icons.person,
                      width: 60,
                      text: "layout.sidemenu.roleRightMapping".tr(),
                      onTap: () => router.go(Routes.adminRoleRight),
                    ),
                    iconButton(
                      icon: Icons.storage,
                      text: "layout.sidemenu.fileAccess".tr(),
                      onTap: () => router.go(Routes.fileAccess),
                    ),
                  ],
                  if (widget.viewModel.showCreateRequest)
                    iconButton(
                      icon: Icons.add_box_outlined,
                      text: "dashboard.home.createRequest".tr(),
                      onTap: () => router.go(Routes.requestCreate),
                    ),
                  if (Utils.checkRoles([
                    UserRole.relationshipOfficer,
                    UserRole.relationshipManager,
                  ]))
                    iconButton(
                      icon: Icons.update_outlined,
                      text: "dashboard.home.createCCSYS".tr(),
                      onTap: () => router.go(Routes.ccsysCreateRequest),
                    ),
                  if (Utils.checkRoles([
                    UserRole.segmentHeadBusiness,
                    UserRole.relationshipManagerBussiness,
                    UserRole.commercialAreaManager,
                    UserRole.teamLeaderBusiness,
                    UserRole.businessUnitHead,
                  ]))
                    iconButton(
                      icon: Icons.update_outlined,
                      text: "dashboard.home.updateCCSYS".tr(),
                      onTap: () => router.go(
                        Routes.closedRequest,
                        extra: ApplicationFilterType.ccsys,
                      ),
                    ),
                  if (Utils.checkRoles(
                    [UserRole.ccuChecker, UserRole.ccuMaker],
                  ))
                    iconButton(
                      icon: Icons.update_outlined,
                      text: "dashboard.home.approveCCSYS".tr(),
                      onTap: () => router.go(
                        Routes.closedRequest,
                        extra: ApplicationFilterType.ccsys,
                      ),
                    ),
                  if (!Utils.checkRoles([
                    UserRole.admin,
                    UserRole.icsAdmin,
                    UserRole.documentationChecker,
                    UserRole.documentationMaker,
                  ]))
                    iconButton(
                      onTap: () => router.go(Routes.digitalEFiling),
                      icon: Icons.file_present_outlined,
                      text: "dashboard.home.digitalFiling".tr(),
                    ),
                  if (Utils.checkRoles([
                    UserRole.relationshipManager,
                    UserRole.relationshipOfficer,
                    UserRole.commercialAreaManager,
                    UserRole.creditCordinator,
                    UserRole.creditAnalyst,
                    UserRole.creditCommitteeProxy,
                    UserRole.boardDirectorProxy,
                    UserRole.segmentHeadBusiness,
                    UserRole.relationshipManagerBussiness,
                    UserRole.teamLeaderBusiness,
                    // ro, rm, 4xBS, CCood, CA, CCP, BDP,
                  ]))
                    iconButton(
                      icon: Icons.settings_applications_outlined,
                      text: "dashboard.home.createViewProject".tr(),
                      onTap: () => router.go(Routes.searchProject),
                    ),
                  if (!Utils.checkRoles([
                    UserRole.icsAdmin,
                  ]))
                    iconButton(
                      icon: Icons.close_fullscreen,
                      text: "dashboard.home.closedRequest".tr(),
                      onTap: () => router.go(Routes.closedRequest),
                    ),
                  iconButton(
                    icon: Icons.menu_book_outlined,
                    text: "dashboard.home.userManual".tr(),
                    onTap: widget.viewModel.downloadUserManual,
                  ),
                  if (!Utils.checkRoles([UserRole.admin]))
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 35,
            color: AppColors.teal,
          ),
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
