import "package:wcas_frontend/models/admin/page.dart";

class FileAccess {
  FileAccess({
    this.id,
    this.name,
    this.parentId,
    this.access,
    this.children,
    this.path,
  });

  factory FileAccess.fromJson(Map<String, dynamic> json, {String? path}) {
    final String prevPath = path ?? "";
    final String currentPath = "$prevPath${json['name']}/";
    return FileAccess(
      id: (json["id"] is int ? json["id"] : int.tryParse(json["id"])) ?? 0,
      name: json["name"],
      parentId: json["parentId"],
      access: accessTypeFromString(json["access"]),
      children: json["children"] != null
          ? List<FileAccess>.from(
              (json["children"] as List).map(
                (child) => FileAccess.fromJson(
                  child,
                  path: currentPath,
                ),
              ),
            )
          : [],
      path: currentPath,
    );
  }
  int? id; //folderID
  String? name;
  int? parentId;
  AccessType? access;
  List<FileAccess>? children;
  String? path;

  int fileCount = 0;

  bool isUpdated = false;

  Map<String, dynamic> toJson() {
    return {
      "referenceDataListId": id,
      "name": name,
      "parentId": parentId,
      "accessType": accessTypeToString(access),
      "children": children?.map((child) => child.toJson()).toList(),
    };
  }
}
