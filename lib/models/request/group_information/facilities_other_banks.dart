import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/group_information/facilities_data.dart";

/// Represents facilities held with other banks.
class FacilitiesOtherBanks {
  /// Creates an instance of [FacilitiesOtherBanks].
  const FacilitiesOtherBanks({this.facilitiesList, this.customer});

  /// Creates an instance from a JSON map.
  factory FacilitiesOtherBanks.fromJson(
    Map<String, dynamic> json,
  ) {
    final facilities = <Facility>[];

    if (json["facilitiesList"] != null) {
      for (final v in json["facilitiesList"]) {
        facilities.add(Facility.fromJson(v));
      }
    }

    return FacilitiesOtherBanks(
      facilitiesList: facilities.isEmpty ? null : facilities,
    );
  }

  /// List of facilities with other banks.
  final List<Facility>? facilitiesList;

  /// Associated customer.
  final Customer? customer;

  /// Converts this object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      if (facilitiesList != null)
        "facilitiesList": facilitiesList!.map((v) => v.toJson()).toList(),
    };
  }
}
