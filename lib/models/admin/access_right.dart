import "package:wcas_frontend/models/admin/page.dart";

/// Represents access rights configured for a role, request type,
/// subtype, and associated pages.
class AccessRight {
  /// Creates an [AccessRight] instance.
  AccessRight({this.role, this.requestType, this.subType, this.pages});

  /// Creates an [AccessRight] instance from a JSON map.
  AccessRight.fromJson(Map<String, dynamic> json) {
    role = json["role"];
    requestType = json["requestType"];
    subType = json["subType"];

    if (json["pageList"] != null && json["pageList"] is List) {
      pages = <Page>[];
      for (final Map<String, dynamic> pageJson in json["pageList"]) {
        pages?.add(Page.fromJson(pageJson));
      }
    }

    if (json["pageIds"] != null && json["pageIds"] is List) {
      pages = <Page>[];
      for (final Map<String, dynamic> pageJson in json["pageIds"]) {
        pages?.add(Page.fromJson(pageJson));
      }

      // for (var pageId in json['pageIds']) {
      //   pages?.add(Page.fromJson(pageId));
      // }
    }
  }

  /// Role associated with this access right.
  String? role;

  /// Request type associated with this access right.
  String? requestType;

  /// Request subtype associated with this access right.
  String? subType;

  /// Pages associated with this access right.
  List<Page>? pages;

  /// Converts this [AccessRight] instance into a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data["role"] = role;
    data["requestType"] = requestType;
    data["subType"] = subType;
    if (pages != null) {
      final List<Page> updatedPages =
          pages!.where((page) => page.isUpdated).toList();
      data["pageIds"] = updatedPages.map((page) => page.toJson()).toList();
    }
    return data;
  }
}
