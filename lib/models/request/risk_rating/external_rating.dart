import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/customer.dart";

class ExternalRating {
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
  Customer? customer;
  String? customerName;
  int? customerRimNo;
  bool? isDeleted;
  bool? isDeletable;
  List<Reference>? ratings;
  Reference? sAndP;
  Reference? moodys;
  Reference? fitch;

  Map<String, dynamic> toJson() {
    return {
      "customerName": customerName,
      "customerRimNo": customerRimNo,
      "deleted": isDeleted,
      "ratingList": ratings,
    };
  }
}

class Ratings {
  Ratings(
    this.ratingType,
    this.rating,
    this.cbrbClassification,
    this.appRefno,
  );

  Ratings.fromJson(Map<String, dynamic> json) {
    ratingType = json["ratingType"];
    rating = json["rating"];
    cbrbClassification = json["cbrbClassification"];
    appRefno = json["appRefno"];
  }
  int? ratingType;
  int? rating;
  int? cbrbClassification;
  int? appRefno;

  Map<String, dynamic> toJson() {
    return {
      "ratingType": ratingType,
      "rating": rating,
      "cbrbClassification": cbrbClassification,
      "appRefno": appRefno,
    };
  }
}
