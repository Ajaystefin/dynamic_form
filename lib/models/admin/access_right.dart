import "package:wcas_frontend/models/admin/page.dart";

class AccessRight {
  AccessRight({this.role, this.requestType, this.subType, this.pages});

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
  String? role;
  String? requestType;
  String? subType;
  List<Page>? pages;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

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
