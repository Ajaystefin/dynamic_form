import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';

class DialogHelper {
  static final _singleton = DialogHelper();
  static DialogHelper get instance => _singleton;

  static Future<dynamic> showCustomDialog({
    required BuildContext context,
    required String title,
    required Widget content,
    double? width,
    bool barrierDismissible = true,
    VoidCallback? onClosePressed,
    List<Widget>? actions,
  }) async {
    return await showDialog(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8))),
          child: Container(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            width: width ?? Scale.scaleHorizontally(600),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: AppColors.white,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with background color
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.dialogHeaderColor, // Header color
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.dialogTitleColor),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel_outlined,
                              color: AppColors.mediumGreen),
                          onPressed: onClosePressed ??
                              () {
                                Navigator.of(context).pop();
                              },
                        )
                      ],
                    ),
                  ),
                  // Divider Below Header
                  const Divider(
                      height: 2, thickness: 2, color: AppColors.mediumGreen),
                  // Message Body
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Gap(),
                        content,
                        // action buttons
                        if (actions != null) ...[
                          const Gap(),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: actions),
                        ],
                        const Gap()
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
