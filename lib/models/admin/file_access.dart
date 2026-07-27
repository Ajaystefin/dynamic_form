import "package:wcas_frontend/models/admin/page.dart";

/// Represents file or folder access information with hierarchy details,
/// access type, children, and path.
class FileAccess {
  /// Creates a [FileAccess] instance.
  FileAccess({
    this.id,
    this.name,
    this.parentId,
    this.access,
    this.children,
    this.path,
  });

  /// Creates a [FileAccess] instance from a JSON map.
  ///
  /// The optional [path] parameter is used to build the hierarchical path
  /// for nested file or folder access items.
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

  /// Unique identifier of the file or folder.
  int? id;

  /// Name of the file or folder.
  String? name;

  /// Identifier of the parent file or folder.
  int? parentId;

  /// Access type assigned to the file or folder.
  AccessType? access;

  /// Child files or folders under this file access item.
  List<FileAccess>? children;

  /// Full hierarchical path of the file or folder.
  String? path;

  /// Number of files under this file access item.
  int fileCount = 0;

  /// Indicates whether this file access item has been updated.
  bool isUpdated = false;

  /// Converts this [FileAccess] instance into a JSON map.
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
