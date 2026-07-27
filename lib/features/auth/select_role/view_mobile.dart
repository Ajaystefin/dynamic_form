import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/auth/select_role/model.dart";
import "package:wcas_frontend/features/auth/select_role/state.dart";
import "package:wcas_frontend/features/auth/select_role/widgets/select_role_dropdown.dart";
import "package:wcas_frontend/features/auth/widgets/logo_section.dart";

/// Mobile view for the role selection screen.
class ViewMobile extends StatelessWidget {
  /// Creates a [ViewMobile].
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final SelectRoleViewModel viewModel = context.read<SelectRoleViewModel>();
    return BlocBuilder<SelectRoleViewModel, SelectRoleState>(
      builder: (context, state) {
        return Scaffold(
          body: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
                minWidth: MediaQuery.of(context).size.width,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Center(
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkGrey,
                              spreadRadius: 10,
                              blurRadius: 50,
                            ),
                          ],
                        ),
                        child: ColoredBox(
                          color: AppColors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LogoSection(
                                width: 800.w,
                                // height: 350,
                              ),
                              Container(
                                width: 800.w,
                                padding: const EdgeInsets.all(40),
                                color: AppColors.loginBackground,
                                child: Container(
                                  width: 800.w,
                                  color: AppColors.darkBlue,
                                  padding: const EdgeInsets.all(20),
                                  child: SelectRoleDropdown(
                                    viewModel: viewModel,
                                    state: state,
                                    width: 800.w,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(right: 10),
                      alignment: Alignment.bottomRight,
                      child: Text(
                        "Build ${"version".tr()}",
                        style: const TextStyle(color: AppColors.darkGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
