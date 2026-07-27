import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:dio/dio.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/file_download_service/service.dart";

class _FileSaveCall {
  _FileSaveCall({
    required this.bytes,
    required this.fileName,
  });

  final Uint8List bytes;
  final String fileName;
}

Dio _dioWithResponder(
  FutureOr<void> Function(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) responder,
) {
  final dio = Dio(
    BaseOptions(
      responseType: ResponseType.bytes,
      followRedirects: false,
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (
        RequestOptions options,
        RequestInterceptorHandler handler,
      ) async {
        await responder(options, handler);
      },
    ),
  );

  return dio;
}

class _MockHttpOverrides extends HttpOverrides {
  _MockHttpOverrides({
    required this.statusCode,
    required this.reasonPhrase,
    required this.body,
  });

  final int statusCode;
  final String reasonPhrase;
  final List<int> body;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient(
      statusCode: statusCode,
      reasonPhrase: reasonPhrase,
      body: body,
    );
  }
}

class _MockHttpClient implements HttpClient {
  _MockHttpClient({
    required this.statusCode,
    required this.reasonPhrase,
    required this.body,
  });

  final int statusCode;
  final String reasonPhrase;
  final List<int> body;

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _MockHttpClientRequest(
      statusCode: statusCode,
      reasonPhrase: reasonPhrase,
      body: body,
      methodValue: method,
      uriValue: url,
    );
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    return openUrl("GET", url);
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) {
    return openUrl("POST", url);
  }

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) {
    return openUrl("DELETE", url);
  }

  @override
  Future<HttpClientRequest> putUrl(Uri url) {
    return openUrl("PUT", url);
  }

  @override
  Future<HttpClientRequest> patchUrl(Uri url) {
    return openUrl("PATCH", url);
  }

  @override
  Future<HttpClientRequest> headUrl(Uri url) {
    return openUrl("HEAD", url);
  }

  @override
  Future<HttpClientRequest> open(
    String method,
    String host,
    int port,
    String path,
  ) {
    return openUrl(method, Uri.parse("http://$host:$port$path"));
  }

  @override
  Future<HttpClientRequest> get(
    String host,
    int port,
    String path,
  ) {
    return open("GET", host, port, path);
  }

  @override
  Future<HttpClientRequest> post(
    String host,
    int port,
    String path,
  ) {
    return open("POST", host, port, path);
  }

  @override
  Future<HttpClientRequest> delete(
    String host,
    int port,
    String path,
  ) {
    return open("DELETE", host, port, path);
  }

  @override
  Future<HttpClientRequest> put(
    String host,
    int port,
    String path,
  ) {
    return open("PUT", host, port, path);
  }

  @override
  Future<HttpClientRequest> patch(
    String host,
    int port,
    String path,
  ) {
    return open("PATCH", host, port, path);
  }

  @override
  Future<HttpClientRequest> head(
    String host,
    int port,
    String path,
  ) {
    return open("HEAD", host, port, path);
  }

  @override
  bool autoUncompress = true;

  @override
  Duration? connectionTimeout;

  @override
  Duration idleTimeout = const Duration(seconds: 15);

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  bool Function(X509Certificate cert, String host, int port)?
      badCertificateCallback;

  @override
  void close({bool force = false}) {}

  @override
  set authenticate(
    Future<bool> Function(Uri url, String scheme, String? realm)? f,
  ) {}

  @override
  set authenticateProxy(
    Future<bool> Function(
      String host,
      int port,
      String scheme,
      String? realm,
    )? f,
  ) {}

  @override
  set findProxy(String Function(Uri url)? f) {}

  @override
  set keyLog(Function(String line)? callback) {}

  @override
  set connectionFactory(
    Future<ConnectionTask<Socket>> Function(
      Uri url,
      String? proxyHost,
      int? proxyPort,
    )? f,
  ) {}

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  _MockHttpClientRequest({
    required this.statusCode,
    required this.reasonPhrase,
    required this.body,
    required this.methodValue,
    required this.uriValue,
  });

  final int statusCode;
  final String reasonPhrase;
  final List<int> body;
  final String methodValue;
  final Uri uriValue;
  final BytesBuilder _requestBody = BytesBuilder();
  final _MockHttpHeaders _headers = _MockHttpHeaders();

  @override
  String get method => methodValue;

  @override
  Uri get uri => uriValue;

  @override
  HttpHeaders get headers => _headers;

  @override
  Encoding encoding = utf8;

  @override
  int contentLength = -1;

  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  bool persistentConnection = false;

  @override
  void add(List<int> data) {
    _requestBody.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await for (final chunk in stream) {
      _requestBody.add(chunk);
    }
  }

  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse(
      statusCode: statusCode,
      reasonPhrase: reasonPhrase,
      body: body,
    );
  }

  @override
  Future<HttpClientResponse> get done {
    return close();
  }

  @override
  Future<dynamic> flush() async {}

  @override
  void write(Object? object) {
    if (object != null) {
      _requestBody.add(encoding.encode(object.toString()));
    }
  }

  @override
  void writeAll(Iterable<dynamic> objects, [String separator = ""]) {
    write(objects.join(separator));
  }

  @override
  void writeCharCode(int charCode) {
    write(String.fromCharCode(charCode));
  }

  @override
  void writeln([Object? object = ""]) {
    write(object);
    write("\n");
  }

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _MockHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  _MockHttpClientResponse({
    required this.statusCode,
    required this.reasonPhrase,
    required List<int> body,
  })  : _bytes = Uint8List.fromList(body),
        _headers = _MockHttpHeaders(
          <String, List<String>>{
            HttpHeaders.contentTypeHeader: <String>["application/octet-stream"],
          },
        );

  final Uint8List _bytes;
  final _MockHttpHeaders _headers;

  @override
  final int statusCode;

  @override
  final String reasonPhrase;

  @override
  int get contentLength => _bytes.length;

  @override
  HttpHeaders get headers => _headers;

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => false;

  @override
  X509Certificate? get certificate => null;

  @override
  HttpClientResponseCompressionState get compressionState {
    return HttpClientResponseCompressionState.notCompressed;
  }

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  List<Cookie> get cookies => <Cookie>[];

  @override
  List<RedirectInfo> get redirects => <RedirectInfo>[];

  @override
  Future<Socket> detachSocket() {
    throw UnsupportedError("detachSocket is not supported in tests");
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_bytes).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _MockHttpHeaders implements HttpHeaders {
  _MockHttpHeaders([Map<String, List<String>>? initialHeaders])
      : _headers = initialHeaders ?? <String, List<String>>{};

  final Map<String, List<String>> _headers;

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    final key = name.toLowerCase();
    _headers.putIfAbsent(key, () => <String>[]).add(value.toString());
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers[name.toLowerCase()] = <String>[value.toString()];
  }

  @override
  void remove(String name, Object value) {
    _headers[name.toLowerCase()]?.remove(value.toString());
  }

  @override
  void removeAll(String name) {
    _headers.remove(name.toLowerCase());
  }

  @override
  String? value(String name) {
    final values = this[name];
    if (values == null || values.isEmpty) {
      return null;
    }
    return values.first;
  }

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _headers.forEach(action);
  }

  @override
  void clear() {
    _headers.clear();
  }

  @override
  bool get chunkedTransferEncoding => false;

  @override
  set chunkedTransferEncoding(bool value) {}

  @override
  int get contentLength => -1;

  @override
  set contentLength(int value) {}

  @override
  ContentType? get contentType => ContentType.binary;

  @override
  set contentType(ContentType? value) {}

  @override
  DateTime? get date => null;

  @override
  set date(DateTime? value) {}

  @override
  DateTime? get expires => null;

  @override
  set expires(DateTime? value) {}

  @override
  String? get host => null;

  @override
  set host(String? value) {}

  @override
  DateTime? get ifModifiedSince => null;

  @override
  set ifModifiedSince(DateTime? value) {}

  @override
  bool get persistentConnection => false;

  @override
  set persistentConnection(bool value) {}

  @override
  int? get port => null;

  @override
  set port(int? value) {}

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

void main() {
  group("FileDownloadService", () {
    HttpOverrides? previousHttpOverrides;

    tearDown(() {
      HttpOverrides.global = previousHttpOverrides;
      previousHttpOverrides = null;
    });

    test("instance should return singleton service", () {
      expect(FileDownloadService.instance, isA<FileDownloadService>());
      expect(
        identical(FileDownloadService.instance, FileDownloadService.instance),
        isTrue,
      );
    });

    test("constructor should create service with default Dio", () {
      final service = FileDownloadService();

      expect(service, isA<FileDownloadService>());
    });

    group("default Dio constructor and validateStatus", () {
      test("should execute validateStatus true branch for status below 500",
          () async {
        previousHttpOverrides = HttpOverrides.current;
        HttpOverrides.global = _MockHttpOverrides(
          statusCode: 404,
          reasonPhrase: "Not Found",
          body: <int>[1, 2, 3],
        );

        final service = FileDownloadService();

        final response = await service.downloadFile(
          "http://example.com/file",
          "missing.pdf",
        );

        expect(response.status, ResponseStatus.error);
        expect(response.code, 404);
        expect(response.message, contains("Not Found"));
      });

      test("should execute validateStatus false branch for status 500",
          () async {
        previousHttpOverrides = HttpOverrides.current;
        HttpOverrides.global = _MockHttpOverrides(
          statusCode: 500,
          reasonPhrase: "Server Error",
          body: utf8.encode("server error"),
        );

        final service = FileDownloadService();

        final response = await service.downloadFile(
          "http://example.com/error",
          "server-error.pdf",
        );

        expect(response, isA<AppResponse>());
        expect(response.status, ResponseStatus.error);
      });
    });

    group("downloadFile", () {
      test("should download file successfully and save bytes", () async {
        RequestOptions? capturedOptions;
        final saveCalls = <_FileSaveCall>[];

        final dio = _dioWithResponder(
          (
            RequestOptions options,
            RequestInterceptorHandler handler,
          ) {
            capturedOptions = options;

            handler.resolve(
              Response<List<int>>(
                requestOptions: options,
                statusCode: 200,
                statusMessage: "OK",
                data: <int>[1, 2, 3, 4, 5],
              ),
            );
          },
        );

        final service = FileDownloadService(
          dio: dio,
          fileSaver: (Uint8List bytes, String fileName) async {
            saveCalls.add(_FileSaveCall(bytes: bytes, fileName: fileName));
            return "saved-path";
          },
        );

        final response = await service.downloadFile(
          "/api/download",
          "report.pdf",
          queryParams: <String, dynamic>{
            "documentId": "123",
            "type": "pdf",
          },
          additionalHeaders: <String, dynamic>{
            "x-test-header": "test-value",
          },
        );

        expect(response.status, ResponseStatus.success);
        expect(response.code, 200);
        expect(response.message, "OK");
        expect(response.body["fileName"], "report.pdf");
        expect(response.body["size"], 5);

        expect(saveCalls, hasLength(1));
        expect(saveCalls.first.fileName, "report.pdf");
        expect(saveCalls.first.bytes, Uint8List.fromList(<int>[1, 2, 3, 4, 5]));

        expect(capturedOptions, isNotNull);
        expect(capturedOptions!.path, "/api/download");
        expect(capturedOptions!.queryParameters["documentId"], "123");
        expect(capturedOptions!.queryParameters["type"], "pdf");
        expect(capturedOptions!.headers["x-test-header"], "test-value");
        expect(capturedOptions!.responseType, ResponseType.bytes);
      });

      test("should cover default FileSaver branch and handle plugin error",
          () async {
        final dio = _dioWithResponder(
          (
            RequestOptions options,
            RequestInterceptorHandler handler,
          ) {
            handler.resolve(
              Response<List<int>>(
                requestOptions: options,
                statusCode: 200,
                statusMessage: "OK",
                data: <int>[1, 2, 3],
              ),
            );
          },
        );

        final service = FileDownloadService(dio: dio);

        final response = await service.downloadFile(
          "/api/download",
          "default-saver.pdf",
        );

        expect(response, isA<AppResponse>());
      });

      test("should return success with empty message when statusMessage is null",
          () async {
        final saveCalls = <_FileSaveCall>[];

        final dio = _dioWithResponder(
          (
            RequestOptions options,
            RequestInterceptorHandler handler,
          ) {
            handler.resolve(
              Response<List<int>>(
                requestOptions: options,
                statusCode: 200,
                data: <int>[10, 20],
              ),
            );
          },
        );

        final service = FileDownloadService(
          dio: dio,
          fileSaver: (Uint8List bytes, String fileName) async {
            saveCalls.add(_FileSaveCall(bytes: bytes, fileName: fileName));
            return "saved";
          },
        );

        final response = await service.downloadFile(
          "/api/download",
          "empty-message.txt",
        );

        expect(response.status, ResponseStatus.success);
        expect(response.code, 200);
        expect(response.message, "");
        expect(response.body["fileName"], "empty-message.txt");
        expect(response.body["size"], 2);
        expect(saveCalls, hasLength(1));
      });

      test("should handle Uint8List response data successfully", () async {
        final fileBytes = Uint8List.fromList(<int>[100, 101, 102]);
        final saveCalls = <_FileSaveCall>[];

        final dio = _dioWithResponder(
          (
            RequestOptions options,
            RequestInterceptorHandler handler,
          ) {
            handler.resolve(
              Response<Uint8List>(
                requestOptions: options,
                statusCode: 200,
                statusMessage: "Success",
                data: fileBytes,
              ),
            );
          },
        );

        final service = FileDownloadService(
          dio: dio,
          fileSaver: (Uint8List bytes, String fileName) async {
            saveCalls.add(_FileSaveCall(bytes: bytes, fileName: fileName));
            return "saved";
          },
        );

        final response = await service.downloadFile(
          "/api/file",
          "bytes.bin",
        );

        expect(response.status, ResponseStatus.success);
        expect(response.code, 200);
        expect(response.body["size"], 3);
        expect(saveCalls, hasLength(1));
        expect(saveCalls.first.bytes, fileBytes);
      });

      test("should return error response when server returns non-200 status",
          () async {
        final saveCalls = <_FileSaveCall>[];

        final dio = _dioWithResponder(
          (
            RequestOptions options,
            RequestInterceptorHandler handler,
          ) {
            handler.resolve(
              Response<List<int>>(
                requestOptions: options,
                statusCode: 404,
                statusMessage: "Not Found",
                data: <int>[],
              ),
            );
          },
        );

        final service = FileDownloadService(
          dio: dio,
          fileSaver: (Uint8List bytes, String fileName) async {
            saveCalls.add(_FileSaveCall(bytes: bytes, fileName: fileName));
            return "saved";
          },
        );

        final response = await service.downloadFile(
          "/api/missing",
          "missing.pdf",
        );

        expect(response.status, ResponseStatus.error);
        expect(response.code, 404);
        expect(response.message, "Failed to download file: Not Found");
        expect(saveCalls, isEmpty);
      });

      test("should return error response when status code is null", () async {
        final saveCalls = <_FileSaveCall>[];

        final dio = _dioWithResponder(
          (
            RequestOptions options,
            RequestInterceptorHandler handler,
          ) {
            handler.resolve(
              Response<List<int>>(
                requestOptions: options,
                statusMessage: "Unknown",
                data: <int>[],
              ),
            );
          },
        );

        final service = FileDownloadService(
          dio: dio,
          fileSaver: (Uint8List bytes, String fileName) async {
            saveCalls.add(_FileSaveCall(bytes: bytes, fileName: fileName));
            return "saved";
          },
        );

        final response = await service.downloadFile(
          "/api/unknown",
          "unknown.pdf",
        );

        expect(response.status, ResponseStatus.error);
        expect(response.code, isNull);
        expect(response.message, "Failed to download file: Unknown");
        expect(saveCalls, isEmpty);
      });

      test("should handle DioException using API manager exception handler",
          () async {
        final dio = _dioWithResponder(
          (
            RequestOptions options,
            RequestInterceptorHandler handler,
          ) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionTimeout,
                message: "Connection timeout",
              ),
            );
          },
        );

        final service = FileDownloadService(
          dio: dio,
          fileSaver: (Uint8List bytes, String fileName) async {
            return "saved";
          },
        );

        final response = await service.downloadFile(
          "/api/error",
          "error.pdf",
        );

        expect(response, isA<AppResponse>());
        expect(response.status, ResponseStatus.error);
      });

      test("should handle custom file saver exception", () async {
        final dio = _dioWithResponder(
          (
            RequestOptions options,
            RequestInterceptorHandler handler,
          ) {
            handler.resolve(
              Response<List<int>>(
                requestOptions: options,
                statusCode: 200,
                statusMessage: "OK",
                data: <int>[1, 2, 3],
              ),
            );
          },
        );

        final service = FileDownloadService(
          dio: dio,
          fileSaver: (Uint8List bytes, String fileName) async {
            throw Exception("save failed");
          },
        );

        final response = await service.downloadFile(
          "/api/download",
          "save-failed.pdf",
        );

        expect(response, isA<AppResponse>());
        expect(response.status, ResponseStatus.error);
      });

      test("should handle invalid response data type", () async {
        final dio = _dioWithResponder(
          (
            RequestOptions options,
            RequestInterceptorHandler handler,
          ) {
            handler.resolve(
              Response<String>(
                requestOptions: options,
                statusCode: 200,
                statusMessage: "OK",
                data: "invalid-data",
              ),
            );
          },
        );

        final service = FileDownloadService(
          dio: dio,
          fileSaver: (Uint8List bytes, String fileName) async {
            return "saved";
          },
        );

        final response = await service.downloadFile(
          "/api/download",
          "invalid.pdf",
        );

        expect(response, isA<AppResponse>());
        expect(response.status, ResponseStatus.error);
      });
    });

    group("openFileInNewTab", () {
      test("should save office file fallback", () async {
        final saveCalls = <_FileSaveCall>[];

        final service = FileDownloadService(
          dio: Dio(),
          fileSaver: (Uint8List bytes, String fileName) async {
            saveCalls.add(_FileSaveCall(bytes: bytes, fileName: fileName));
            return "saved";
          },
        );

        final bytes = Uint8List.fromList(<int>[1, 2, 3]);

        await service.openFileInNewTab(bytes, "document.docx");

        expect(saveCalls, hasLength(1));
        expect(saveCalls.first.fileName, "document.docx");
        expect(saveCalls.first.bytes, bytes);
      });

      test("should save archive file fallback", () async {
        final saveCalls = <_FileSaveCall>[];

        final service = FileDownloadService(
          dio: Dio(),
          fileSaver: (Uint8List bytes, String fileName) async {
            saveCalls.add(_FileSaveCall(bytes: bytes, fileName: fileName));
            return "saved";
          },
        );

        final bytes = Uint8List.fromList(<int>[9, 8, 7]);

        await service.openFileInNewTab(bytes, "archive.zip");

        expect(saveCalls, hasLength(1));
        expect(saveCalls.first.fileName, "archive.zip");
        expect(saveCalls.first.bytes, bytes);
      });

      test("should save unknown extension fallback", () async {
        final saveCalls = <_FileSaveCall>[];

        final service = FileDownloadService(
          dio: Dio(),
          fileSaver: (Uint8List bytes, String fileName) async {
            saveCalls.add(_FileSaveCall(bytes: bytes, fileName: fileName));
            return "saved";
          },
        );

        final bytes = Uint8List.fromList(<int>[5, 6, 7]);

        await service.openFileInNewTab(bytes, "file.unknownext");

        expect(saveCalls, hasLength(1));
        expect(saveCalls.first.fileName, "file.unknownext");
      });

      test("should save file without extension fallback", () async {
        final saveCalls = <_FileSaveCall>[];

        final service = FileDownloadService(
          dio: Dio(),
          fileSaver: (Uint8List bytes, String fileName) async {
            saveCalls.add(_FileSaveCall(bytes: bytes, fileName: fileName));
            return "saved";
          },
        );

        final bytes = Uint8List.fromList(<int>[1]);

        await service.openFileInNewTab(bytes, "filename");

        expect(saveCalls, hasLength(1));
        expect(saveCalls.first.fileName, "filename");
      });

      test("should cover browser-viewable extensions on web", () async {
        final viewableFiles = <String>[
          "file.pdf",
          "file.txt",
          "file.json",
          "file.xml",
          "file.csv",
          "file.jpg",
          "file.jpeg",
          "file.png",
          "file.gif",
          "file.bmp",
          "file.webp",
          "file.svg",
          "file.ico",
          "file.html",
          "file.htm",
          "file.css",
          "file.js",
          "file.mp4",
          "file.webm",
          "file.ogg",
          "file.mp3",
          "file.wav",
        ];

        for (final fileName in viewableFiles) {
          final saveCalls = <_FileSaveCall>[];

          final service = FileDownloadService(
            dio: Dio(),
            fileSaver: (Uint8List bytes, String fileName) async {
              saveCalls.add(_FileSaveCall(bytes: bytes, fileName: fileName));
              return "saved";
            },
          );

          final bytes = Uint8List.fromList(utf8.encode("content"));

          await service.openFileInNewTab(bytes, fileName);

          if (kIsWeb) {
            expect(saveCalls, isEmpty);
          } else {
            expect(saveCalls, hasLength(1));
            expect(saveCalls.first.fileName, fileName);
          }
        }
      });

      test("should cover non-viewable mime fallback extensions", () async {
        final nonViewableFiles = <String>[
          "file.doc",
          "file.docx",
          "file.xls",
          "file.xlsx",
          "file.ppt",
          "file.pptx",
          "file.zip",
          "file.rar",
          "file.7z",
          "file.tar",
          "file.gz",
          "file.unknown",
        ];

        for (final fileName in nonViewableFiles) {
          final saveCalls = <_FileSaveCall>[];

          final service = FileDownloadService(
            dio: Dio(),
            fileSaver: (Uint8List bytes, String fileName) async {
              saveCalls.add(_FileSaveCall(bytes: bytes, fileName: fileName));
              return "saved";
            },
          );

          final bytes = Uint8List.fromList(<int>[1, 2, 3]);

          await service.openFileInNewTab(bytes, fileName);

          expect(saveCalls, hasLength(1));
          expect(saveCalls.first.fileName, fileName);
        }
      });

      test("should throw custom file saver error from fallback path", () async {
        final service = FileDownloadService(
          dio: Dio(),
          fileSaver: (Uint8List bytes, String fileName) async {
            throw Exception("open save failed");
          },
        );

        final bytes = Uint8List.fromList(<int>[1]);

        await expectLater(
          service.openFileInNewTab(bytes, "document.xlsx"),
          throwsException,
        );
      });
    });

    group("fileToBase64", () {
      test("should convert platform file bytes to base64", () {
        final service = FileDownloadService(
          dio: Dio(),
          fileSaver: (Uint8List bytes, String fileName) async {
            return "saved";
          },
        );

        final file = PlatformFile(
          name: "sample.txt",
          size: 5,
          bytes: Uint8List.fromList(utf8.encode("hello")),
        );

        final result = service.fileToBase64(file);

        expect(result, base64Encode(utf8.encode("hello")));
      });

      test("should convert empty platform file bytes to base64", () {
        final service = FileDownloadService(
          dio: Dio(),
          fileSaver: (Uint8List bytes, String fileName) async {
            return "saved";
          },
        );

        final file = PlatformFile(
          name: "empty.txt",
          size: 0,
          bytes: Uint8List.fromList(<int>[]),
        );

        final result = service.fileToBase64(file);

        expect(result, "");
      });

      test("should convert binary platform file bytes to base64", () {
        final service = FileDownloadService(
          dio: Dio(),
          fileSaver: (Uint8List bytes, String fileName) async {
            return "saved";
          },
        );

        final bytes = Uint8List.fromList(<int>[0, 1, 2, 253, 254, 255]);

        final file = PlatformFile(
          name: "binary.bin",
          size: bytes.length,
          bytes: bytes,
        );

        final result = service.fileToBase64(file);

        expect(result, base64Encode(bytes.toList()));
      });

      test("should throw when platform file bytes are null", () {
        final service = FileDownloadService(
          dio: Dio(),
          fileSaver: (Uint8List bytes, String fileName) async {
            return "saved";
          },
        );

        final file = PlatformFile(
          name: "null-bytes.txt",
          size: 0,
        );

        expect(
          () => service.fileToBase64(file),
          throwsA(isA<TypeError>()),
        );
      });
    });
  });
}
