import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/customer.dart";

/// External Rating response data
class ExternalRating {
  /// Creates a [ExternalRating] instance
  ExternalRating({
    this.customerName,
    this.customerRimNo,
    this.isDeleted = false,
    this.isDeletable = true,
    this.ratings,
    this.sAndP,
    this.moodys,
    this.fitch,
  });

  /// Convert json to ExternalRating
  ExternalRating.fromJson(Map<String, dynamic> json) {
    customerName = json["customerName"];
    customerRimNo = json["rimNo"];
    isDeleted = json["isdeleted"];
    isDeletable = json["isDeletable"] ?? false;

    final ratingList = json["ratingList"];
    if (ratingList != null && ratingList is List) {
      ratings = ratingList
          .map<Reference>(
            (item) => Reference(
              id: item["ratingType"],
              typeId: item["rating"],
            ),
          )
          .toList();
    }
  }

  /// Customer details
  Customer? customer;

  /// Customer name
  String? customerName;

  /// Customer RIM number
  int? customerRimNo;

  /// is deleted or not
  bool? isDeleted;

  /// can be deleted or not
  bool? isDeletable;

  /// List of Regerences of ratings
  List<Reference>? ratings;

  /// Reference Data sAndP
  Reference? sAndP;

  /// Reference Data moodys
  Reference? moodys;

  /// Reference Data fitch
  Reference? fitch;

  /// Convert ExternalRating into json
  Map<String, dynamic> toJson() {
    return {
      "customerName": customerName,
      "customerRimNo": customerRimNo,
      "deleted": isDeleted,
      "ratingList": ratings,
    };
  }
}
