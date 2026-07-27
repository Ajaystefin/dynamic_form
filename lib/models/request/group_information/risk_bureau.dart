import "package:wcas_frontend/models/request/group_information/cbrb_data.dart";
import "package:wcas_frontend/models/request/group_information/share_of_wallet_data.dart";

/// class to handle response data for RiskBureau
class RiskBureau {
  /// Creates instance of [RiskBureau]
  RiskBureau({this.cbrbDataList, this.shareOfWalletList});

  /// Convert json into RiskBureau
  RiskBureau.fromJson(Map<String, dynamic> json) {
    if (json["cbrbDataList"] != null) {
      cbrbDataList = <CBRB>[];
      json["cbrbDataList"].forEach((v) {
        cbrbDataList!.add(CBRB.fromJson(v));
      });
    }
    if (json["shareOfWalletList"] != null) {
      shareOfWalletList = <ShareOfWalletData>[];
      json["shareOfWalletList"].forEach((v) {
        shareOfWalletList!.add(ShareOfWalletData.fromJson(v));
      });
    }
  }

  /// CBRB Data List
  List<CBRB>? cbrbDataList;

  /// List of share of wallet data
  List<ShareOfWalletData>? shareOfWalletList;

  /// Convert Object into json
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (cbrbDataList != null) {
      data["cbrbDataList"] = cbrbDataList!.map((v) => v.toJson()).toList();
    }
    if (shareOfWalletList != null) {
      data["shareOfWalletList"] =
          shareOfWalletList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
