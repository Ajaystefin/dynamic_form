import "dart:convert";
import "dart:typed_data";
import "package:easy_localization/easy_localization.dart";
import "package:file_picker/file_picker.dart";
import "package:file_saver/file_saver.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/services/file_download_service/service.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/file_access.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/customer.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";
import "package:wcas_frontend/models/request/file_attachment/document.dart";
import "package:wcas_frontend/models/request/file_attachment/file_upload.dart";

/// Defines the contract for attachment-related operations.
///
/// Implementations are responsible for document selection,
/// downloading files, and viewing request summaries.
abstract class AttachmentViewModel {
  /// Holds the list of uploaded file details.
  List<FileDetail> fileUploadDatas = [];

  /// Updates the selection state of a document.
  ///
  /// The document identified by [key] is marked as selected or
  /// unselected based on [isSelected].
  Future<void> toggleDocumentSelection(
    String key,
    DocSubTypeData? docData, {
    required bool isSelected,
  });

  /// Downloads the specified document.
  ///
  /// Uses the provided document identifier, URL, and file name to
  /// retrieve the document.
  Future<void> downloadDocument(
    String documentId,
    String webUrl,
    String documentName,
  );

  /// Displays the request summary for the specified application.
  ///
  /// Uses the provided [context] for navigation or presentation.
  Future<void> viewRequestSummary(
    String? applicationId,
    BuildContext context,
  );
}

/// Repository responsible for file attachment operations and document
/// management services.
class FileAttachmentRepository {
  /// Creates a [FileAttachmentRepository] instance.
  ///
  /// If no [apiManager] is provided, a default [APIManager] instance
  /// is used.
  FileAttachmentRepository({
    APIManager? apiManager,
  }) : _apiManager = apiManager ?? APIManager();

  static final _singleton = FileAttachmentRepository();

  /// Returns the singleton instance of [FileAttachmentRepository].
  static FileAttachmentRepository get instance => _singleton;

  final APIManager _apiManager;

  /// Retrieves uploaded file details based on the provided search
  /// criteria and metadata filters.
  ///
  /// Returns a list of [FileDetail] objects mapped from the backend
  /// response, including the resolved document type, subtype, and
  /// language references.
  ///
  /// Throws an [ApiException] if the request fails.
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
    String? appRefNo, {
    required bool isLegacy,
  }) async {
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
      final result = filterResponse(response.body);
      final List<dynamic> respData =
          result["responseData"] as List<dynamic>? ?? [];

      final List<FileDetail> fileUploadDatas = respData
          .map(
            (doc) => FileDetail.fromJson(
              doc,
              documentTypes,
              subTypes,
              subSubTypes,
              subSubSubTypes,
              languages,
            ),
          )
          .toList();

      return fileUploadDatas;
    }

    //throw Exception(response.message);
    throw ApiException(response.message);
  }

  /// Filters the API response and applies node-level transformations to
  /// each item in the response data collection.
  ///
  /// Returns a copy of the original response with the filtered
  /// `responseData` list.
  Map<String, dynamic> filterResponse(Map<String, dynamic> data) {
    final List<dynamic> responseData = data["responseData"] ?? [];

    return {
      ...data,
      // function expects params
      // ignore: unnecessary_lambdas
      "responseData": responseData.map((item) => _filterNode(item)).toList(),
    };
  }

  /// Recursively filters a document tree node and its children.
  ///
  /// Removes:
  /// - Invalid file nodes for credit application documents without a
  ///   valid decision value.
  /// - Empty subtype nodes that have no name and no child nodes.
  ///
  /// Returns an empty map when the node should be excluded; otherwise,
  /// returns the filtered node with its processed children.
  Map<String, dynamic> _filterNode(Map<String, dynamic> node) {
    final attributes = node["attributes"] ?? {};
    final children = node["children"] as List<dynamic>? ?? [];

    // Condition 1: Remove invalid file
    final isInvalidFile = attributes["docType"] ==
            ServerConstants.creditApplicationDocumentType &&
        attributes["decision"]?.toString() == "null";

    // Recursively clean children first
    final filteredChildren = children
        // function expects params
        // ignore: unnecessary_lambdas
        .map((child) => _filterNode(child))
        .where((child) => child.isNotEmpty)
        .toList();

    // Condition 2: Remove empty/invalid subType node
    final isEmptySubTypeNode = node["type"] == "subType" &&
        (node["name"] == null || node["name"].toString().isEmpty) &&
        filteredChildren.isEmpty;

    // Final decision
    if (isInvalidFile || isEmptySubTypeNode) {
      return {};
    }

    return {
      ...node,
      "children": filteredChildren,
    };
  }

  /// Retrieves file access permissions for the current user's role.
  ///
  /// Returns a filtered list of [FileAccess] entries containing only
  /// folders and documents that the user has permission to view or edit.
  /// Any folders with no access are removed together with their child
  /// items.
  ///
  /// Throws an [ApiException] if the request fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Fetches legacy documents for the current application.
  ///
  /// Returns a list of [DocSubTypeDetail] parsed from the API response.
  ///
  /// Throws [ApiException] when the request is unsuccessful.
  Future<List<DocSubTypeDetail>> getLegacyDocuments() async {
    final Map data = BaseRequest.baseRequest(
      {
        "AppRefNo": Globals.request!.applicationRefNo, //"201812APNAR000019",
      },
    );

    final List<DocSubTypeDetail> files = [];
    final AppResponse response =
        await _apiManager.post(APIEndpoints.getLegacyFiles, data);
    if (response.status == ResponseStatus.success) {
      logger.f(json.encode(response.body));
      response.message =
          response.body["baseResponse"]["status"]["statusDescription"];
      for (final file in (response.body["responseData"] as List)) {
        files.add(
          DocSubTypeDetail.fromJson(
            file,
            [],
            [],
            [],
            [],
            [],
          ),
        );
      }
      return files;
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Retrieves documents associated with the current application.
  ///
  /// Returns a list of [Document] objects enriched with document type,
  /// subtype, and language reference data. Documents matching the credit
  /// application approval decision subtype can be excluded based on the
  /// value of [showApprovalSubType].
  ///
  /// Throws an [ApiException] if the request fails.
  Future<List<Document>> getDocuments({
    required bool showApprovalSubType,
    required List<Reference> documentTypes,
    required List<Reference> subTypes,
    required List<Reference> subSubTypes,
    required List<Reference> subSubSubTypes,
    required List<Reference> languages,
  }) async {
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
        if (showApprovalSubType &&
            file["subSubSubType"] ==
                ServerConstants
                    .subSubSubTypeCreditApplicationApprovalDecision) {
          continue; // skip this file
        }

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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Flattens a hierarchical file access tree into a single list.
  ///
  /// Traverses all nodes recursively and returns a flat collection
  /// containing each [FileAccess] node and its descendants.
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

  /// Reconstructs a hierarchical file access tree from a flat list of
  /// [FileAccess] nodes.
  ///
  /// Restores parent-child relationships using each node's `id` and
  /// `parentId` values and returns the resulting root nodes. Nodes whose
  /// parent is not present in the filtered list are treated as root
  /// nodes.
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

  /// Filters file access nodes based on access permissions.
  ///
  /// Returns only nodes with view or edit access and removes any node
  /// whose parent or ancestor has [AccessType.none]. The filtered nodes
  /// are then rebuilt into their original hierarchical structure
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
      if (node.access == AccessType.none) {
        return false;
      }

      // Check all ancestors up to root
      int? currentParentId = node.parentId;
      while (currentParentId != null) {
        final FileAccess? parent = nodeMap[currentParentId];
        if (parent == null) {
          break; // No parent found, assume root
        }
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

  /// Calculates and updates aggregated file counts for the file access
  /// hierarchy.
  ///
  /// Counts documents directly associated with each folder and rolls the
  /// totals up through the parent-child hierarchy so that each folder's
  /// `fileCount` includes documents from all descendant folders.
  ///
  /// Returns the updated list of [FileAccess] root nodes with aggregated
  /// file counts.
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

  /// Retrieves customer RIMs associated with the specified group.
  ///
  /// Returns a list of [Customer] objects created from the RIM numbers
  /// returned by the backend service.
  ///
  /// Throws an [ApiException] if the request fails.
  Future<List<Customer>> getCompanyRims(int groupRim) async {
    final List<Customer> rimStrings = [];
    final Map data = BaseRequest.baseRequest({
      "groupId": groupRim,
    });

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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Downloads the specified document attachment.
  ///
  /// Retrieves the document content from the backend service, decodes the
  /// returned Base64 data, opens the file in a new browser tab, and saves
  /// a local copy using a generated file name.
  ///
  /// Throws an [ApiException] if the download request fails.
  Future<void> downloadFileAttachment(Document document) async {
    final String fileName = "Company-${document.companyRim}_"
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Downloads a digital document attachment.
  ///
  /// Retrieves the document content using the specified document ID and
  /// web URL, decodes the returned Base64 payload, and opens the file in
  /// a new browser tab.
  ///
  /// Throws an [ApiException] if the download request fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Downloads multiple digital attachments as a ZIP file.
  ///
  /// Generates a ZIP archive containing the selected documents and saves
  /// it locally using a grouped file name derived from the selected
  /// document metadata.
  ///
  /// Throws an [ApiException] if the download operation fails.
  Future<void> zipDownloadDigitalAttachment(
    List<String> documentIds,
    List<DocSubTypeData?> selectedDocs,
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
              "edmsId": d?.edmsDriveItemId,
              "webUrl": d?.webUrl,
              "rimNo": d?.rimNo ?? rimNo,
              "periodEndDate": d?.date?.toUtc().toIso8601String(),
              "groupId": d?.groupId ?? groupId,
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

  /// Merges and downloads the selected digital attachments as a single
  /// ZIP package.
  ///
  /// Validates that all selected files have supported file extensions
  /// before requesting the merged download from the backend service.
  /// The generated package is saved locally using a company- or
  /// group-based file name.
  ///
  /// Throws an [ApiException] if any selected file type is unsupported
  /// or if the download operation fails.
  Future<void> mergeDownloadDigitalAttachment(
    List<DocSubTypeData?> selectedDocs,
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
      final ext = d?.webUrl?.split(".").last.toLowerCase();

      if (ext == null || !allowedExtensions.contains(ext)) {
        // Show error and STOP
        throw ApiException(
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
              "edmsId": d?.edmsDriveItemId,
              "webUrl": d?.webUrl,
              "rimNo": d?.rimNo ?? rimNo,
              "periodEndDate": d?.date?.toUtc().toIso8601String(),
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

  /// Links the specified documents to an application.
  ///
  /// Associates the provided EDMS document identifiers with the given
  /// application reference number and returns the success message from
  /// the API response when the operation completes successfully.
  ///
  /// Throws an [ApiException] if one or more documents fail to link or if
  /// the request is unsuccessful.
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
      return response.body["baseResponse"]["status"]["statusDescription"];
    } else {
      response.message =
          response.body["responseData"]["failed"].first["reason"];
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Uploads digital documents to the document management system.
  ///
  /// Merges document metadata, uploads the associated files using a
  /// multipart request, and returns a success message when all files are
  /// uploaded successfully.
  ///
  /// Upload progress is logged during the transfer process.
  ///
  /// Throws an [ApiException] if the upload fails or if any file is not
  /// uploaded successfully.
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
    final responseData = response.body?["responseData"];
    final message = _apiManager.buildDigitalUploadSuccessMessage(responseData);

    if (response.status == ResponseStatus.success) {
      final statusCode =
          response.body?["baseResponse"]?["status"]?["statusCode"];

      final perFileCounts = responseData?["perFileCounts"];
      final int success = perFileCounts?["success"] ?? 0;
      final int total = perFileCounts?["total"] ?? 0;

      final bool isAllSuccess = success == total;

      if (statusCode == "200" || statusCode == "201") {
        if (isAllSuccess) {
          return message;
        } else {
          throw ApiException(message);
        }
      } else {
        throw ApiException(message);
      }
    } else {
      throw ApiException(message);
    }
  }

  /// Uploads documents using a multipart request.
  ///
  /// Sends document metadata and associated files to the backend service,
  /// tracks upload progress, and returns a success message when all files
  /// are uploaded successfully.
  ///
  /// Throws an [ApiException] if the upload fails or if only a subset of
  /// files is uploaded successfully.
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
      final Map<String, dynamic>? responseData =
          response.body?["responseData"] as Map<String, dynamic>?;

      final int total = responseData?["total"] as int? ?? 0;
      final int success = responseData?["successCount"] as int? ?? 0;

      final bool isAllSuccess = total > 0 && success == total;

      final String message =
          _apiManager.buildUploadSuccessMessage(responseData);

      if (isAllSuccess) {
        // All files uploaded successfully
        return message;
      } else {
        // Partial success / failures
        throw ApiException(message);
      }
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Deletes the specified document from the current application.
  ///
  /// Sends a delete request for the provided document and returns the
  /// success message from the API response when the operation completes
  /// successfully.
  ///
  /// Throws an [ApiException] if the delete operation fails.
  Future<String?> deleteDocument(Document document) async {
    final String fileName = document.files!.first.name;
    final Map data = BaseRequest.baseRequest(
      {
        "appRefNo": Globals.request!.applicationRefNo,
        "fileName": fileName,
        "docType": document.documentType?.id,
      },
    );

    final AppResponse response =
        await _apiManager.post(APIEndpoints.deleteFile, data);
    if (response.status == ResponseStatus.success) {
      return response.message;
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Searches customer profiles using the provided customer, group, or
  /// party details.
  ///
  /// Returns a list of matching [Customer] records from the backend
  /// service. The response supports both single-customer and
  /// multiple-customer payload formats.
  ///
  /// Throws an [ApiException] if the search request fails or the response
  /// cannot be processed.
  Future<List<Customer?>> searchCustomerProfile(
    String? customerName,
    String? groupId,
    String? groupName, [
    String? customerId,
  ]) async {
    try {
      final Map data = BaseRequest.baseRequest({
        "PartyId": customerId,
        "FullName": customerName ?? "",
        "GroupId": int.tryParse(groupId ?? ""),
        "GroupName": groupName ?? "",
      });

      final List<Customer?> resultCustomers = [];

      final AppResponse response =
          await _apiManager.post(APIEndpoints.getCustomerProfile, data);

      if (response.status == ResponseStatus.success) {
        try {
          for (final element in (response.body["responseData"] as List)) {
            resultCustomers.add(Customer.fromJson(element));
          }
        } on Object {
          try {
            resultCustomers
                .add(Customer.fromJson(response.body["responseData"]));
          } on Object {
            rethrow;
          }
        }
      }
      return resultCustomers;
    } catch (e) {
      throw ApiException(e.toString());
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
//   } on Object catch (e) {
//     throw 'Error: $e';
//   }
// }
