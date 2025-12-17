import 'package:wcas_frontend/core/utils/utils.dart';

class RequestInfoState {
  LoadingStatus loaderStatus = LoadingStatus.loaded;
  final bool isButtonLoading;
  final bool isTPAN;
  final bool isIslamic;
  final bool isInterimReviewDateRequired;
  final bool isApplicationTypeMarkForward;
  bool? isPolicyDeviation;
  bool? overrideDate;
  bool? isPresentReviewDate;
  String? customerName;
  DateTime? presentReviewDate;
  DateTime? defaultNextReviewDate;
  DateTime? defaultPresentReviewDate;
  DateTime? nextReviewDate;
  DateTime? markForwardDate;

  RequestInfoState(
      {required this.loaderStatus,
      this.isButtonLoading = false,
      this.isTPAN = false,
      this.isIslamic = false,
      this.isInterimReviewDateRequired = false,
      this.isApplicationTypeMarkForward = false,
      this.isPolicyDeviation = false,
      this.overrideDate = false,
      this.isPresentReviewDate = false,
      this.customerName = '',
      this.nextReviewDate,
      this.presentReviewDate,
      this.markForwardDate,
      this.defaultPresentReviewDate,
      this.defaultNextReviewDate});

  RequestInfoState copyWith(
      {LoadingStatus? loaderStatus,
      bool? isButtonLoading,
      bool? isTPAN,
      bool? isIslamic,
      bool? isInterimReviewDateRequired,
      bool? isApplicationTypeMarkForward,
      bool? isPolicyDeviation,
      bool? overrideDate,
      bool? isPresentReviewDate,
      String? customerName,
      DateTime? presentReviewDate,
      DateTime? defaultNextReviewDate,
      DateTime? defaultPresentReviewDate,
      DateTime? markForwardDate,
      DateTime? nextReviewDate}) {
    return RequestInfoState(
        loaderStatus: loaderStatus ?? this.loaderStatus,
        isButtonLoading: isButtonLoading ?? this.isButtonLoading,
        isTPAN: isTPAN ?? this.isTPAN,
        isIslamic: isIslamic ?? this.isIslamic,
        isInterimReviewDateRequired:
            isInterimReviewDateRequired ?? this.isInterimReviewDateRequired,
        isApplicationTypeMarkForward:
            isApplicationTypeMarkForward ?? this.isApplicationTypeMarkForward,
        isPolicyDeviation: isPolicyDeviation ?? this.isPolicyDeviation,
        overrideDate: overrideDate ?? this.overrideDate,
        isPresentReviewDate: isPresentReviewDate ?? this.isPresentReviewDate,
        customerName: customerName ?? this.customerName,
        presentReviewDate: presentReviewDate ?? this.presentReviewDate,
        defaultNextReviewDate:
            defaultNextReviewDate ?? this.defaultNextReviewDate,
        nextReviewDate: nextReviewDate ?? this.nextReviewDate,
        defaultPresentReviewDate: defaultPresentReviewDate ?? this.defaultPresentReviewDate,
        markForwardDate: markForwardDate ?? this.markForwardDate);
  }
}
