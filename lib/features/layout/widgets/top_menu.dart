import "dart:async";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
// import 'package:go_router/go_router.dart';
// ignore: depend_on_referenced_packages
import "package:provider/provider.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/models/login/role.dart";

/// Top navigation menu displayed across the application.
class TopMenuSection extends StatelessWidget {
  /// Creates a [TopMenuSection].
  const TopMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    final LayoutViewModel viewModel = context.watch<LayoutViewModel>();
    logger.i("hideSideMenu ${viewModel.state.hideSideMenu}");
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: PhysicalModel(
        color: AppColors.scaffoldBackground,
        elevation: 6,
        shadowColor: AppColors.scaffoldBackground,
        child: Container(
          height: 60,
          width: double.infinity,
          color: Colors.white60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                spacing: 10,
                children: [
                  // if (context.isDesktop &&
                  //         (GoRouter.of(context).state.name == Routes.home) ||
                  //     (GoRouter.of(context).state.name ==
                  //         Routes.closedRequest))
                  if (viewModel.state.hideSideMenu)
                    Semantics(
                      label: "semantics.topMenu.goToHome".tr(),
                      button: true,
                      child: InkWell(
                        onTap: () {
                          router.go(Routes.home);
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          width: MediaQuery.of(context).size.width * 0.2,
                          constraints: const BoxConstraints(
                            maxWidth: 150,
                            minWidth: 80,
                          ),
                          child: Image.asset(
                            AppAssets.logo,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  if (!context.isDesktop && !viewModel.state.hideSideMenu)
                    Semantics(
                      label: "semantics.topMenu.sideMenu".tr(),
                      button: true,
                      child: IconButton(
                        onPressed: viewModel.openSideMenu,
                        icon: const Icon(Icons.menu),
                      ),
                    ),
                  const SizedBox(width: 30),
                  if ((context.isDesktop &&
                          viewModel.shouldShowDashboardButton) ||
                      viewModel.state.currentRoute == Routes.closedRequest) ...[
                    Semantics(
                      label: "semantics.topMenu.dashboard".tr(),
                      button: true,
                      child: OutlinedButton(
                        onPressed: () {
                          //Autosave function - This is to ensure that any
                          //unsaved changes are saved as draft before leaving
                          //the current page.
                          unawaited(Globals.onAutoSave?.call());
                          router.go(Routes.home);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              viewModel.isCurrentRoute(context, Routes.home)
                                  ? AppColors.primary
                                  : null,
                          side: BorderSide(
                            color: viewModel.isCurrentRoute(
                              context,
                              Routes.home,
                            )
                                ? AppColors.white
                                : AppColors.primary,
                            width: 0,
                          ), // Change border color
                        ),
                        child: Text(
                          "layout.topmenu.dashboardButton".tr(),
                          style: TextStyle(
                            color: !viewModel.isCurrentRoute(
                              context,
                              Routes.home,
                            )
                                ? AppColors.primary
                                : AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: CustomDropdown<Role>(
                        semanticLabel: "layout.topmenu.selectRole".tr(),
                        hintText: "layout.topmenu.selectRole".tr(),
                        width: 250,
                        selectedItems: [
                          Globals.user?.currentRole,
                        ],
                        onBeforeChange: (previousValue, currentValue) async {
                          return viewModel.showConfirmDialog(
                            context,
                            currentValue ?? Role(),
                          );
                        },
                        items: Globals.user?.availableRoles,
                        validationMessage: "",
                        dropdownBuilder: (context, item) =>
                            dropdownBuilderWidget(
                          showToolTip: true,
                          text: item?.name ?? "",
                        ),
                        itemBuilder: (context, item, {isDisabled, isSelected}) {
                          return dropdownItemBuildWidget(
                            item.name,
                            isSelected: isSelected ?? false,
                          );
                        },
                      ),
                    ),
                    const Gap(
                      direction: Axis.horizontal,
                    ),
                    Text(
                      "layout.topmenu.welcome".tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      Globals.user?.name?.toUpperCase() ?? "",
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Semantics(
                      label: "semantics.topMenu.logout".tr(),
                      button: true,
                      child: IconButton(
                        onPressed: () async =>
                            viewModel.showLogoutDialog(context),
                        icon: const Icon(
                          Icons.logout,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
