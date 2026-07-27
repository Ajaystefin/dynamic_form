import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/models/request/profitability/share_of_wallet.dart";

/// Share of wallet table.
class ShareOfWalletTable extends StatelessWidget {
  /// Creates a share of wallet table.
  const ShareOfWalletTable({required this.walletList, super.key});

  /// Share of wallet list.
  final List<ShareOfWallet> walletList;

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      autoFitWidth: false,
      stackedHeaders: [
        StackedHeader(
          startIndex: 2,
          endIndex: 3,
          widget: Text(
            "profitabilityAccountConduct.shareOfWallet.facilitiesWithAllBanks"
                .tr(),
          ),
          width: 160.w,
        ),
        StackedHeader(
          startIndex: 4,
          endIndex: 5,
          widget: Text(
            "profitabilityAccountConduct.shareOfWallet.facilitiesWithCbd".tr(),
          ),
          width: 160.w,
        ),
        StackedHeader(
          startIndex: 6,
          endIndex: 7,
          widget: Text(
            "profitabilityAccountConduct.shareOfWallet.shareofWalletpercent"
                .tr(),
          ),
          width: 160.w,
        ),
      ],
      columns: [
        TableColumn(
          label: Text(
            "profitabilityAccountConduct.shareOfWallet.customerRim".tr(),
          ),
          width: 115.w,
        ),
        TableColumn(
          label: Text(
            "profitabilityAccountConduct.shareOfWallet.customerName".tr(),
          ),
          width: 185.w,
        ),
        TableColumn(
          label: Text(
            "profitabilityAccountConduct.shareOfWallet.totallimitsA".tr(),
          ),
          width: 80.w,
          isStacked: true,
        ),
        TableColumn(
          label: Text("profitabilityAccountConduct.shareOfWallet.totalC".tr()),
          width: 80.w,
          isStacked: true,
        ),
        TableColumn(
          label: Text(
            "profitabilityAccountConduct.shareOfWallet.totalLimitsB".tr(),
          ),
          width: 80.w,
          isStacked: true,
        ),
        TableColumn(
          label: Text("profitabilityAccountConduct.shareOfWallet.totalD".tr()),
          width: 80.w,
          isStacked: true,
        ),
        TableColumn(
          label: Text("profitabilityAccountConduct.shareOfWallet.limits".tr()),
          width: 80.w,
          isStacked: true,
        ),
        TableColumn(
          label: Text("profitabilityAccountConduct.shareOfWallet.totalOS".tr()),
          width: 80.w,
          isStacked: true,
        ),
      ],
      rows: walletList
          .map(
            (wallet) => [
              Center(child: Text("${wallet.customerRimNo}")),
              Center(child: Text(wallet.customerName)),
              Text(
                wallet.facilitiesWithAllBanksLimitsA
                    .toStringAsFixed(2)
                    .formatNumber(),
                style: const TextStyle(color: AppColors.darkBlue),
              ),
              Text(
                wallet.facilitiesWithAllBanksOutstandingC
                    .toStringAsFixed(2)
                    .formatNumber(),
                style: const TextStyle(color: AppColors.darkBlue),
              ),
              Text(
                wallet.facilitiesWithCbdLimitsB
                    .toStringAsFixed(2)
                    .formatNumber(),
                style: const TextStyle(color: AppColors.darkBlue),
              ),
              Text(
                wallet.facilitiesWithCbdOutstandingD
                    .toStringAsFixed(2)
                    .formatNumber(),
                style: const TextStyle(color: AppColors.darkBlue),
              ),
              Text(
                wallet.shareOfWalletLimits.toStringAsFixed(2),
                style: const TextStyle(color: AppColors.darkBlue),
              ),
              Text(
                wallet.shareOfWalletOutstanding.toStringAsFixed(2),
                style: const TextStyle(color: AppColors.darkBlue),
              ),
            ],
          )
          .toList(),
    );
  }
}
