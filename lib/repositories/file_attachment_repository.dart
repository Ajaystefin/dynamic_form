import "dart:convert";
import "dart:typed_data";

import "package:easy_localization/easy_localization.dart";
import "package:file_picker/file_picker.dart";
import "package:file_saver/file_saver.dart";
import "package:flutter/services.dart";

import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/services/file_download_service/service.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/file_access.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/file_attachment/document.dart";
import "package:wcas_frontend/models/request/file_attachment/file_upload.dart";

class FileAttachmentRepository {
  FileAttachmentRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();
  static final _singleton = FileAttachmentRepository();
  static FileAttachmentRepository get instance => _singleton;

  // ignore: unused_field
  final APIManager _apiManager;

  Future<List<FileDetail>> getFileUploadData(
    List<Reference>? documentTypes,
    List<Reference>? subTypes,
    List<Reference>? subSubTypes,
    List<Reference>? subSubSubTypes,
    List<Reference>? languages,
    String? rimNo,
    String? customerName,
    String? groupId,
    String? groupName,
    String? appRefNo,
    bool isLegacy,
  ) async {
    final Map<String, dynamic> requestData = {
      "metadata": {
        "RIMNo": rimNo == null || rimNo == "" ? null : rimNo,
        // "CustomerName":
        // customerName == null || customerName == "" ? null : customerName,
        "GroupId": groupId == null || groupId == "" ? null : groupId,
        // "GroupName": groupName == null || groupName == "" ? null : groupName,
        "AppRefNo": appRefNo == null || appRefNo == "" ? null : appRefNo,
      },
      "top": 500,
      "orderBy": "lastModifiedDateTime desc",
      "applyLegacy": isLegacy,
    };

    final Map<String, dynamic> data = BaseRequest.baseRequest(requestData);

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getFileUploadDatas, data);

    if (response.status == ResponseStatus.success) {
      final List<FileDetail> fileUploadDatas =
          (response.body["responseData"] as List<dynamic>?)
                  ?.map(
                    (doc) => FileDetail.fromJson(
                      doc,
                      documentTypes,
                      subTypes,
                      subSubTypes,
                      subSubSubTypes,
                      languages,
                    ),
                  )
                  .toList() ??
              [];

      return fileUploadDatas;
    }

    throw response.message;
  }

  Future<List<FileAccess>> getFileAccessRight() async {
    final Map data =
        BaseRequest.baseRequest({"role": Globals.user?.currentRole?.code});

    final List<FileAccess> fileAccesses = [];
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getFileAccessRight, data);
    if (response.status == ResponseStatus.success) {
      logger.f(json.encode(response.body));
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      for (final file in (response.body["responseData"] as List)) {
        fileAccesses.add(FileAccess.fromJson(file));
      }

      // Filter to only include folders with view or edit access
      // Folders with AccessType.none are removed along with all their children
      return _filterFileAccessesWithCascade(fileAccesses);
    } else {
      throw response.message;
    }
  }

  Future<List<Document>> getDocuments(
    List<Reference> documentTypes,
    List<Reference> subTypes,
    List<Reference> subSubTypes,
    List<Reference> subSubSubTypes,
    List<Reference> languages,
  ) async {
    final Map data = BaseRequest.baseRequest(
      {"appRefNo": Globals.request!.applicationRefNo},
    );

    final List<Document> files = [];
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getFiles, data);
    if (response.status == ResponseStatus.success) {
      logger.f(json.encode(response.body));
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      for (final file in (response.body["responseData"] as List)) {
        files.add(
          Document.fromJson(
            file,
            documentTypes,
            subTypes,
            subSubTypes,
            subSubSubTypes,
            languages,
          ),
        );
      }
      return files;
    } else {
      throw response.message;
    }
  }

  /// Flattens the hierarchical tree structure into a flat list
  List<FileAccess> _flattenFileAccesses(List<FileAccess> nodes) {
    final List<FileAccess> flattened = [];

    void flatten(FileAccess node) {
      flattened.add(node);
      if (node.children != null) {
        for (final FileAccess child in node.children!) {
          flatten(child);
        }
      }
    }

    for (final FileAccess node in nodes) {
      flatten(node);
    }

    return flattened;
  }

  /// Rebuilds the tree structure from a flat list of nodes
  List<FileAccess> _rebuildTree(List<FileAccess> flatList) {
    // Clear children for all nodes
    for (final FileAccess node in flatList) {
      node.children = [];
    }

    // Create ID -> Node map for quick lookup
    final Map<int, FileAccess> nodeMap = {
      for (final FileAccess node in flatList) node.id!: node,
    };

    // Rebuild parent-child relationships
    final List<FileAccess> rootNodes = [];
    for (final FileAccess node in flatList) {
      if (node.parentId == null) {
        rootNodes.add(node);
      } else if (nodeMap.containsKey(node.parentId)) {
        nodeMap[node.parentId]!.children!.add(node);
      } else {
        // Parent not in filtered list, treat as root
        rootNodes.add(node);
      }
    }

    return rootNodes;
  }

  /// Filters file accesses to only include view/edit access with cascading removal
  /// If a parent has AccessType.none, all its children are removed
  List<FileAccess> _filterFileAccessesWithCascade(
    List<FileAccess> fileAccesses,
  ) {
    // Step 1: Flatten the tree to get all nodes
    final List<FileAccess> allNodes = _flattenFileAccesses(fileAccesses);

    // Step 2: Create a map of id -> node for quick lookup
    final Map<int, FileAccess> nodeMap = {
      for (final FileAccess node in allNodes) node.id!: node,
    };

    // Step 3: Check if a node is valid (has view/edit AND all ancestors have view/edit)
    bool isNodeValid(FileAccess node) {
      // Check current node access
      if (node.access == AccessType.none) return false;

      // Check all ancestors up to root
      int? currentParentId = node.parentId;
      while (currentParentId != null) {
        final FileAccess? parent = nodeMap[currentParentId];
        if (parent == null) break; // No parent found, assume root
        if (parent.access == AccessType.none) {
          return false; // Ancestor has no access - cascade remove
        }
        currentParentId = parent.parentId;
      }

      return true;
    }

    // Step 4: Filter to only valid nodes (view/edit with valid ancestors)
    final List<FileAccess> validNodes = allNodes.where(isNodeValid).toList();

    // Step 5: Rebuild the tree structure
    return _rebuildTree(validNodes);
  }

  /// Computes file counts per folder where each FileAccess.node.fileCount
  /// = (direct documents in that folder) + (sum of all descendants' documents).
  ///
  /// Assumptions:
  /// - Document.folderId and FileAccess.id represent the same folder
  /// identifier.
  /// - Both are `int`. If yours are `String`, see the String variant below.
  List<FileAccess> calculateFileCountsAggregated(
    List<FileAccess> fileAccesses,
    List<Document> allDocuments,
  ) {
    // Build folderId -> direct document count map
    final Map<int, int> folderCountMap = {};
    for (final document in allDocuments) {
      final int? folderId =
          document.folderID; // ⚠️ ensure field name matches your model
      if (folderId != null) {
        folderCountMap[folderId] = (folderCountMap[folderId] ?? 0) + 1;
      }
    }

    // Post-order DFS: compute children's totals first, then set parent's total
    int updateAndSum(FileAccess node) {
      final int direct = folderCountMap[node.id] ?? 0;
      int childrenTotal = 0;

      final children = node.children;
      if (children != null && children.isNotEmpty) {
        for (final child in children) {
          childrenTotal += updateAndSum(child);
        }
      }

      final int total = direct + childrenTotal;
      node.fileCount = total; // parent holds aggregated count
      return total;
    }

    for (final root in fileAccesses) {
      updateAndSum(root);
    }

    return fileAccesses;
  }

  Future<List<Customer>> getCompanyRims(int groupRim) async {
    final List<Customer> rimStrings = [];
    final Map data = BaseRequest.baseRequest({"groupId": groupRim});

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getCompanyRims, data);
    if (response.status == ResponseStatus.success) {
      logger.f(json.encode(response.body));
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];

      final rims = response.body["responseData"]["rims"];
      for (final int rim in rims) {
        rimStrings.add(
          Customer(
            id: rim.toString(),
            customerName: rim.toString(),
            customerRimNo: rim,
          ),
        );
      }
      return rimStrings;
    } else {
      throw response.message;
    }
  }

  Future<void> downloadFileAttachment(Document document) async {
    final String fileName =
        "Company-${document.companyRim}_"
        "${document.date?.year}_${document.files!.first.name}";
    final Map data = BaseRequest.baseRequest({
      "appRefNo": Globals.request!.applicationRefNo,
      "fileName": document.fileName,
      "docType": document.documentType?.id,
    });

    final AppResponse response =
        await _apiManager.post(APIEndpoints.downloadFile, data);
    if (response.status == ResponseStatus.success) {
      final base64 = response.body!["responseData"]["content"];
      final Uint8List bytes = base64Decode(base64);
      await FileDownloadService.instance.openFileInNewTab(bytes, fileName);
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
      );
    } else {
      throw response.message;
    }
  }

  Future<void> downloadDigitalAttachment(
    String documentId,
    String webUrl,
    String documentName,
  ) async {
    final Map data = BaseRequest.baseRequest(
      {"edmsDocumentId": documentId, "webUrl": webUrl},
    );

    final AppResponse response =
        await _apiManager.post(APIEndpoints.downloadFileDigital, data);
    if (response.status == ResponseStatus.success) {
      final base64 = response.body!["responseData"]["contentBase64"];
      final Uint8List bytes = base64Decode(base64);
      await FileDownloadService.instance.openFileInNewTab(bytes, documentName);
    } else {
      throw response.message;
    }
  }

  Future<void> zipDownloadDigitalAttachment(
    List<String> documentIds,
    selectedDocs,
    String? rimNo,
    String? groupId,
    String? appRefNo,
  ) async {
    final Map data = BaseRequest.baseRequest({
      "groupId": groupId,
      "rimNo": rimNo,
      "appRefNo": appRefNo,
      "selectedFiles": selectedDocs
          .map(
            (d) => {
              "edmsId": d.edmsDriveItemId,
              "webUrl": d.webUrl,
              "rimNo": rimNo ?? d.rimNo ?? d.RIMNo,
              "date": d.date.toUtc().toIso8601String(),
              "groupId": groupId ?? d.groupId,
            },
          )
          .toList(),
    });
    final fileName =
        Utils.buildGroupedZipName(selectedDocs, rimFieldIsNo: true);
    final AppResponse response = await _apiManager.downloadFile(
      APIEndpoints.zipDownloadFileDigital,
      data,
    );
    final bytes = Uint8List.fromList(response.body!);
    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: bytes,
    );
  }

  Future<void> mergeDownloadDigitalAttachment(
    selectedDocs,
    List<String> documentIds,
    String? rimNo,
    String? groupId,
    String? appRefNo,
  ) async {
    // ALLOWED EXTENSIONS
    final allowedExtensions = [
      "pdf",
      "doc",
      "docx",
      "xls",
      "xlsx",
      "ppt",
      "pptx",
    ];

    // VALIDATE EACH FILE
    for (final d in selectedDocs) {
      final ext = d.webUrl?.split(".").last.toLowerCase();

      if (ext == null || !allowedExtensions.contains(ext)) {
        // Show error and STOP
        throw Exception(
          "eDigitalFilingFileAttachments.fileAttachments.mergeFileRestriction"
              .tr(),
        );
      }
    }

    final Map data = BaseRequest.baseRequest({
      "groupId": groupId,
      "rimNo": rimNo,
      "appRefNo": appRefNo,
      "selectedFiles": selectedDocs
          .map(
            (d) => {
              "edmsId": d.edmsDriveItemId,
              "webUrl": d.webUrl,
              "rimNo": d.rimNo ?? d.RIMNo,
              "periodEndDate": d.date.toUtc().toIso8601String(),
            },
          )
          .toList(),
    });
    final fileName = groupId != null && groupId != "0"
        ? "Group_${groupId}_pack.zip"
        : "Company_${rimNo}_pack.zip";
    final AppResponse response = await _apiManager.downloadFile(
      APIEndpoints.mergeDownloadFileDigital,
      data,
    );
    final bytes = Uint8List.fromList(response.body!);
    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: bytes,
    );
  }

  Future<String?> linkToApplication(
    String? appRefNo,
    List<String> documentIds,
  ) async {
    final List<Map<String, String>> fileIds =
        documentIds.map((id) => {"edmsDocumentId": id}).toList();

    final Map data =
        BaseRequest.baseRequest({"appRefNo": appRefNo, "files": fileIds});
    logger.f(json.encode(data));
    final AppResponse response =
        await _apiManager.post(APIEndpoints.linkToApplication, data);
    if (response.status == ResponseStatus.success &&
        response.body["responseData"]["failedCount"] == 0) {
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      return response.message;
    } else {
      response.message =
          response.body["responseData"]["failed"].first["reason"];
      throw response.message;
    }
  }

  /// Example method demonstrating how to use the new uploadMultipartFiles API.
  ///
  /// This is a demonstration method showing the complete flow of using
  /// the multipart file upload with PlatformFile objects.
  ///
  /// Returns: Success message from the API
  Future<String> uploadDigitalDocuments(List<Document> documents) async {
    final docs = Utils.mergeDocuments(documents);
    final Map data = BaseRequest.baseRequest(
      {"files": docs.map((document) => document.toEDMSJson()).toList()},
    );

    final all = documents.expand<PlatformFile>(
      (doc) => (doc.files ?? const <PlatformFile>[]).map(
        (f) => PlatformFile(
          name: f.name,
          size: f.size,
          bytes: f.bytes,
        ),
      ),
    );

    final byName = <String, PlatformFile>{};
    for (final f in all) {
      byName.putIfAbsent(f.name, () => f); // keeps the first occurrence
    }

    final files = byName.values.toList();

    // Step 3: Call the uploadMultipartFiles method
    final AppResponse response = await _apiManager.uploadMultipartFiles(
      APIEndpoints.uploadDigitalDocumentsMultipart,
      envelope: data,
      files: files,
      onSendProgress: (sent, total) {
        // Track upload progress
        final progress = (sent / total * 100).toStringAsFixed(2);
        logger.d("Upload progress: $progress%");
      },
    );

    // Step 4: Handle response
    if (response.status == ResponseStatus.success) {
      final statusCode =
          response.body?["baseResponse"]?["status"]?["statusCode"];
      if (statusCode == "200" || statusCode == "201") {
        response.message = _apiManager
            .buildDigitalUploadSuccessMessage(response.body?["responseData"]);
        return response.message;
      } else {
        throw _apiManager
                .extractFailedMessage(response.body?["responseData"]) ??
            response.message;
      }
    } else {
      throw _apiManager.extractFailedMessage(response.body?["responseData"]) ??
          response.message;
    }
  }

  Future<String> uploadDocumentsMultipart(List<Document> documents) async {
    final docs = Utils.mergeDocuments(documents);
    final Map data = BaseRequest.baseRequest({
      "atomic": true,
      "files": docs.asMap().entries.map((entry) {
        final index = entry.key;
        final doc = entry.value;
        return {
          ...doc.toJson(),
          "id": (index).toString(), // 1-based incremental id
        };
      }).toList(),
    });
    final files = documents
        .map<List<PlatformFile>>(
          (doc) =>
              // if doc.files is null, use an empty list
              (doc.files ?? const <PlatformFile>[])
                  .map(
                    (f) => PlatformFile(
                      name: f.name,
                      size: f.size,
                      bytes: f.bytes,
                    ),
                  )
                  .toList(),
        )
        .expand((lst) => lst) // flatten
        .toList();

    // Step 3: Call the uploadMultipartFiles method
    final AppResponse response = await _apiManager.uploadMultipartFiles(
      APIEndpoints.uploadDocumentsMultipart,
      envelope: data,
      files: files,
      onSendProgress: (sent, total) {
        // Track upload progress
        final progress = (sent / total * 100).toStringAsFixed(2);
        logger.d("Upload progress: $progress%");
      },
    );

    // Step 4: Handle response
    if (response.status == ResponseStatus.success) {
      response.message = _apiManager.buildUploadSuccessMessage(response.body);
      // response.body["baseResponse"]["status"]["statusDescription"];
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<String?> deleteDocument(Document document) async {
    final String fileName = document.files!.first.name;
    final Map data = BaseRequest.baseRequest(
      {"appRefNo": Globals.request!.applicationRefNo, "fileName": fileName},
    );

    final AppResponse response =
        await _apiManager.post(APIEndpoints.deleteFile, data);
    if (response.status == ResponseStatus.success) {
      return response.message;
    } else {
      throw response.message;
    }
  }
}

// Future<void> downloadFile(String endPoint, Map data, String docType) async {
//   try {
//     // Fetch file as bytes
//     final response = await dio.post<List<int>>(
//       endPoint,
//       data: jsonEncode(data),
//       options: Options(responseType: ResponseType.bytes),
//     );

//     if (response.statusCode == 200 && response.data != null) {
//       final bytes = Uint8List.fromList(response.data!);

//       // Create a Blob and trigger download
//       final blob = html.Blob([bytes]);
//       final urlBlob = html.Url.createObjectUrlFromBlob(blob);

//       final anchor = html.AnchorElement(href: urlBlob)
//         ..download = docType == "pdf" ? "form.pdf" : 'form.docx' // fixed name
//         ..style.display = 'none';

//       html.document.body!.append(anchor);
//       anchor.click();
//       anchor.remove();
//       html.Url.revokeObjectUrl(urlBlob);
//     } else {
//       throw 'Download failed: ${response.statusCode}';
//     }
//   } catch (e) {
//     throw 'Error: $e';
//   }
// }
