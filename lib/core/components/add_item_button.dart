import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

class AddItemButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isLeftSided;
  const AddItemButton(
      {super.key, required this.child, this.onTap, this.isLeftSided = false});

  @override
  Widget build(BuildContext context) {
    if (isLeftSided) {
      return InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const VerticalDivider(
                  color: AppColors.primary,
                  width: 8,
                  thickness: 8,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(
                      color: AppColors.lightSuccess,
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 10,
                    children: [
                      child,
                      const CircleAvatar(
                        backgroundColor: AppColors.secondary,
                        radius: 12, // Adjust as needed
                        child: Icon(Icons.add,
                            size: 16, color: AppColors.white),
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
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10),
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(
                    color: AppColors.lightSuccess,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 10,
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.secondary,
                      radius: 12, // Adjust as needed
                      child: Icon(Icons.add,
                          size: 16, color: AppColors.white),
                    ),
                    child,
                  ],
                ),
              ),
              const VerticalDivider(
                color: AppColors.primary,
                width: 8,
                thickness: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
