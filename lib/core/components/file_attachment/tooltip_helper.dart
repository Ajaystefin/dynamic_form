import "package:easy_localization/easy_localization.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";

/// Helper methods for document tooltips.
class TooltipHelper {
  /// Returns the tooltip text for a document name based on
  /// document type and subtype.
  static String getDocumentNameTooltip(
    int? docTypeId,
    int? subSubTypeId,
  ) {
    //  Financial → Projection only
    if (docTypeId ==
            ServerConstants.documentTypeId[DocumentType.financialStatements] &&
        subSubTypeId == ServerConstants.subSubTypeFinancialProjection) {
      return "eDigitalFilingFileAttachments.fileAttachments.tooltip.documentName.financialProjection"
          .tr();
    }

    //  Credit Application
    if (docTypeId ==
        ServerConstants.documentTypeId[DocumentType.creditApplication]) {
      return "eDigitalFilingFileAttachments.fileAttachments.tooltip.documentName.creditApplication"
          .tr();
    }

    //  Constitutional
    if (docTypeId ==
        ServerConstants.documentTypeId[DocumentType.constitutionalDocument]) {
      return "eDigitalFilingFileAttachments.fileAttachments.tooltip.documentName.constitutional"
          .tr();
    }

    // Default (External, Other, Financial non-projection)
    return "eDigitalFilingFileAttachments.fileAttachments.tooltip.documentName.default"
        .tr();
  }
}
