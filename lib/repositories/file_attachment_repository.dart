import 'dart:convert';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/api_service/api_manager.dart';
import 'package:wcas_frontend/core/services/api_service/base_request.dart';
import 'package:wcas_frontend/core/services/file_download_service/service.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/file_access.dart';
import 'package:wcas_frontend/models/admin/page.dart';
import 'package:wcas_frontend/models/admin/reference.dart';
import 'package:wcas_frontend/models/request/file_attachment/document.dart';
import 'package:wcas_frontend/models/request/file_attachment/file_upload.dart';

import '../core/utils/logger.dart';
import 'dart:typed_data';

class FileAttachmentRepository {
  static final _singleton = FileAttachmentRepository();
  static FileAttachmentRepository get instance => _singleton;

  // ignore: unused_field
  final APIManager _apiManager;

  FileAttachmentRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

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
      String? appRefNo) async {
    final Map<String, dynamic> requestData = {
      "metadata": {
        "RIMNo": rimNo,
        "CustomerName": customerName,
        "GroupId": groupId,
        "GroupName": groupName,
        "AppRefNo": appRefNo
      },
      "top": 500,
      "orderBy": "lastModifiedDateTime desc", //TODO handle static params
    };

    final Map<String, dynamic> data = BaseRequest.baseRequest(requestData);

    final AppResponse response =
        await _apiManager.post(APIEndpoints.getFileUploadDatas, data);

    if (response.status == ResponseStatus.success) {
      List<FileDetail> fileUploadDatas =
          (response.body["responseData"] as List<dynamic>?)
                  ?.map((doc) => FileDetail.fromJson(doc, documentTypes,
                      subTypes, subSubTypes, subSubSubTypes, languages))
                  .toList() ??
              [];

      // Filter out approval decision files if user doesn't have permission
      if (!_canViewApprovalDecisionFiles()) {
        fileUploadDatas = _filterApprovalDecisionFiles(fileUploadDatas);
      }

      return fileUploadDatas;
    }

    throw response.message;
  }

  /// Filters out approval decision files from the nested document structure
  List<FileDetail> _filterApprovalDecisionFiles(List<FileDetail> fileDetails) {
    return fileDetails.map((fileDetail) {
      if (fileDetail.documents != null) {
        fileDetail.documents = fileDetail.documents!.map((docDetail) {
          if (docDetail.documents != null) {
            docDetail.documents = docDetail.documents!.where((docSubType) {
              // Filter out documents with approval decision sub sub sub type
              return docSubType?.data?.subSubSubType?.id !=
                  ServerConstants
                      .subSubSubTypeCreditApplicationApprovalDecision;
            }).toList();
          }
          return docDetail;
        }).toList();
      }
      return fileDetail;
    }).toList();
  }

  /// Checks if the current user has permission to view approval decision files
  /// Only Credit Analyst and higher approval roles can view these files
  bool _canViewApprovalDecisionFiles() {
    return Utils.checkRoles([
      UserRole.creditAnalyst,
      UserRole.teamLeaderCreditLevelD1,
      UserRole.segmentHeadCreditLevelD,
      UserRole.segmentHeadLevelC,
      UserRole.segmentHeadLevelB1,
      UserRole.segmentHeadLevelB,
      UserRole.creditCommitteeProxy,
      UserRole.creditCommitteeProxyApprover,
      UserRole.boardDirectorProxy,
      UserRole.boardDirectorProxyApproval,
    ]);
  }

  Future<List<FileAccess>> getFileAccessRight() async {
    Map data =
        BaseRequest.baseRequest({"role": Globals.user?.currentRole?.code});

    List<FileAccess> fileAccesses = [];
    AppResponse response =
        await _apiManager.post(APIEndpoints.getFileAccessRight, data);
    if (response.status == ResponseStatus.success) {
      logger.f(json.encode(response.body));
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      for (var file in (response.body['responseData'] as List)) {
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
      List<Reference> languages) async {
    Map data = BaseRequest.baseRequest(
        {"appRefNo": Globals.request!.applicationRefNo});

    List<Document> files = [];
    AppResponse response = await _apiManager.post(APIEndpoints.getFiles, data);
    if (response.status == ResponseStatus.success) {
      logger.f(json.encode(response.body));
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      for (var file in (response.body['responseData'] as List)) {
        files.add(Document.fromJson(file, documentTypes, subTypes, subSubTypes,
            subSubSubTypes, languages));
      }
      return files;
    } else {
      throw response.message;
    }
  }

  /// Flattens the hierarchical tree structure into a flat list
  List<FileAccess> _flattenFileAccesses(List<FileAccess> nodes) {
    List<FileAccess> flattened = [];

    void flatten(FileAccess node) {
      flattened.add(node);
      if (node.children != null) {
        for (FileAccess child in node.children!) {
          flatten(child);
        }
      }
    }

    for (FileAccess node in nodes) {
      flatten(node);
    }

    return flattened;
  }

  /// Rebuilds the tree structure from a flat list of nodes
  List<FileAccess> _rebuildTree(List<FileAccess> flatList) {
    // Clear children for all nodes
    for (FileAccess node in flatList) {
      node.children = [];
    }

    // Create ID -> Node map for quick lookup
    Map<int, FileAccess> nodeMap = {
      for (FileAccess node in flatList) node.id!: node
    };

    // Rebuild parent-child relationships
    List<FileAccess> rootNodes = [];
    for (FileAccess node in flatList) {
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
      List<FileAccess> fileAccesses) {
    // Step 1: Flatten the tree to get all nodes
    List<FileAccess> allNodes = _flattenFileAccesses(fileAccesses);

    // Step 2: Create a map of id -> node for quick lookup
    Map<int, FileAccess> nodeMap = {
      for (FileAccess node in allNodes) node.id!: node
    };

    // Step 3: Check if a node is valid (has view/edit AND all ancestors have view/edit)
    bool isNodeValid(FileAccess node) {
      // Check current node access
      if (node.access == AccessType.none) return false;

      // Check all ancestors up to root
      int? currentParentId = node.parentId;
      while (currentParentId != null) {
        FileAccess? parent = nodeMap[currentParentId];
        if (parent == null) break; // No parent found, assume root
        if (parent.access == AccessType.none) {
          return false; // Ancestor has no access - cascade remove
        }
        currentParentId = parent.parentId;
      }

      return true;
    }

    // Step 4: Filter to only valid nodes (view/edit with valid ancestors)
    List<FileAccess> validNodes = allNodes.where(isNodeValid).toList();

    // Step 5: Rebuild the tree structure
    return _rebuildTree(validNodes);
  }

  List<FileAccess> calculateFileCounts(
      List<FileAccess> fileAccesses, List<Document> allDocuments) {
    // Create a map of folderID -> count for O(1) lookup
    Map<int, int> folderCountMap = {};
    for (Document document in allDocuments) {
      if (document.folderID != null) {
        folderCountMap[document.folderID!] =
            (folderCountMap[document.folderID!] ?? 0) + 1;
      }
    }

    // Recursive helper to update file counts
    void updateFileCounts(FileAccess fileAccess) {
      // Set file count from the map (0 if not found)
      fileAccess.fileCount = folderCountMap[fileAccess.id] ?? 0;

      // Recursively update children
      if (fileAccess.children != null) {
        for (FileAccess child in fileAccess.children!) {
          updateFileCounts(child);
        }
      }
    }

    // Update all top-level file accesses
    for (FileAccess fileAccess in fileAccesses) {
      updateFileCounts(fileAccess);
    }

    return fileAccesses;
  }

  Future<List<String>> getCompanyRims(int groupRim) async {
    List<String> rimStrings = [];
    Map data = BaseRequest.baseRequest({"groupId": groupRim});

    AppResponse response =
        await _apiManager.post(APIEndpoints.getCompanyRims, data);
    if (response.status == ResponseStatus.success) {
      logger.f(json.encode(response.body));
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];

      final rims = response.body['responseData']['rims'];
      for (int rim in rims) {
        rimStrings.add(rim.toString());
      }
      return rimStrings;
    } else {
      throw response.message;
    }
  }

  Future<void> downloadFileAttachment(Document document) async {
    String fileName = document.files!.first.name;
    Map data = BaseRequest.baseRequest(
        {"appRefNo": Globals.request!.applicationRefNo, "fileName": fileName});

    AppResponse response =
        await _apiManager.post(APIEndpoints.downloadFile, data);
    if (response.status == ResponseStatus.success) {
      final base64 = response.body!['responseData']['content'];
      Uint8List bytes = base64Decode(base64);
      FileDownloadService.instance.openFileInNewTab(bytes, fileName);
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
      );
    } else {
      throw response.message;
    }
  }

  Future<void> downloadDigitalAttachment(
      String documentId, String documentName) async {
    Map data = BaseRequest.baseRequest({"edmsDocumentId": documentId});

    AppResponse response =
        await _apiManager.downloadFile(APIEndpoints.downloadFileDigital, data);
    if (response.status == ResponseStatus.success) {
      final bytes = Uint8List.fromList(response.body!);
      FileDownloadService.instance.openFileInNewTab(bytes, documentName);
      await FileSaver.instance.saveFile(
        name: documentName,
        bytes: bytes,
      );
    } else {
      throw response.message;
    }
  }

  Future<void> zipDownloadDigitalAttachment(List<String> documentIds,
      String? rimNo, String? groupId, String? appRefNo) async {
    Map data = BaseRequest.baseRequest({
      "groupId": groupId,
      "rimNo": rimNo,
      "appRefNo": appRefNo,
      "edmsDocumentIds": documentIds
    });
    logger.f(json.encode(data));
    AppResponse response = await _apiManager.downloadFile(
        APIEndpoints.zipDownloadFileDigital, data);
    // if (response.status == ResponseStatus.success) {
    final bytes = Uint8List.fromList(response.body!);
    FileDownloadService.instance.openFileInNewTab(
        bytes, "${DateTime.now().millisecondsSinceEpoch}.zip");
    await FileSaver.instance.saveFile(
      name: "${DateTime.now().millisecondsSinceEpoch}.zip",
      bytes: bytes,
    );
    // } else {
    //   throw response.message;
    // }
  }

  Future<void> mergeDownloadDigitalAttachment(List<String> documentIds) async {
    Map data = BaseRequest.baseRequest({"edmsDocumentIds": documentIds});
    logger.f(json.encode(data));
    AppResponse response = await _apiManager.downloadFile(
        APIEndpoints.mergeDownloadFileDigital, data);
    // if (response.status == ResponseStatus.success) {
    final bytes = Uint8List.fromList(response.body!);
    FileDownloadService.instance.openFileInNewTab(bytes, "fileName.pdf");
    await FileSaver.instance.saveFile(
      name: "fileName.pdf",
      bytes: bytes,
    );
    // } else {
    //   throw response.message;
    // }
  }

  Future<String?> uploadDigitalDocuments(List<Document> documents) async {
    Map data = BaseRequest.baseRequest(
        {"files": documents.map((document) => document.toEDMSJson()).toList()});

    AppResponse response =
        await _apiManager.post(APIEndpoints.uploadDigitalDocuments, data);
    if (response.status == ResponseStatus.success) {
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<String?> uploadDocuments(List<Document> documents) async {
    Map data = BaseRequest.baseRequest(
        {"files": documents.map((document) => document.toJson()).toList()});

    AppResponse response =
        await _apiManager.post(APIEndpoints.uploadDocuments, data);
    if (response.status == ResponseStatus.success) {
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      return response.message;
    } else {
      throw response.message;
    }
  }

  Future<String?> deleteDocument(Document document) async {
    String fileName = document.files!.first.name;
    Map data = BaseRequest.baseRequest(
        {"appRefNo": Globals.request!.applicationRefNo, "fileName": fileName});

    AppResponse response =
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
