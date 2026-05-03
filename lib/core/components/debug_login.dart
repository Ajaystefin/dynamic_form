import "dart:convert";

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";

/// Debug login screen for SSO development
/// Allows developers to paste SSO response data to bypass SSO redirect
class DebugLoginView extends StatefulWidget {
  const DebugLoginView({super.key});

  @override
  State<DebugLoginView> createState() => _DebugLoginViewState();
}

class _DebugLoginViewState extends State<DebugLoginView> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  /// Example format for developers
  static const String _exampleFormat =
      '''https://wcas.cbd.dev/wcas-ui/#/login-success?tokenResponse={"jwtToken":"eyJ...","expiresIn":900000}&userResponse={"userDetailId":1584,"userId":"",...}&sessionID=abc123''';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Parse URL query parameters into a Map
  /// Handles both full URLs and raw query strings
  Map<String, String> _parseQueryParams(String input) {
    final Map<String, String> params = {};

    // Extract query string from URL if it's a full URL
    String queryString = input;
    if (input.contains("?")) {
      queryString = input.split("?").last;
    } else if (input.contains("#/")) {
      // Handle hash routing URLs like #/login-success?params
      final hashPart = input.split("#/").last;
      if (hashPart.contains("?")) {
        queryString = hashPart.split("?").last;
      }
    }

    // Split by & to get individual parameters
    final parts = queryString.split("&");

    for (final part in parts) {
      final keyValue = part.split("=");
      if (keyValue.length >= 2) {
        final key = Uri.decodeComponent(keyValue[0]);
        // Join back in case value contains '='
        final value = Uri.decodeComponent(keyValue.sublist(1).join("="));
        params[key] = value;
      }
    }

    return params;
  }

  /// Process the debug login with pasted SSO data
  Future<void> _handleSubmit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Parse the input text
      final inputText = _controller.text.trim();
      if (inputText.isEmpty) {
        throw "Please paste SSO response data";
      }

      // Parse as URL query parameters
      final Map<String, String> queryParams = _parseQueryParams(inputText);

      // Validate required fields
      if (!queryParams.containsKey("tokenResponse") ||
          !queryParams.containsKey("userResponse")) {
        throw "Missing required fields: tokenResponse and userResponse";
      }

      // Extract and set sessionID if present
      if (queryParams.containsKey("sessionID")) {
        Globals.sessionID = queryParams["sessionID"]!;
        debugPrint("Session ID set from debug input: ${Globals.sessionID}");
      }

      // Parse JSON strings from query parameters
      final userResponse = jsonDecode(queryParams["userResponse"]!);
      debugPrint("User Response: $userResponse");
      final tokenResponse = jsonDecode(queryParams["tokenResponse"]!);

      // Login with SSO (duplicated logic from splash screen)
      await AuthRepository.instance.loginWithSSO(
        tokenResponse: tokenResponse,
        userResponse: userResponse,
      );

      final bool hasRoles = Globals.user?.segments?.isNotEmpty ?? false;
      if (hasRoles) {
        AlertManager().showSuccessToast("auth.login.success".tr());
        (Globals.user?.availableRoles?.length == 1
            ? router.go(Routes.home)
            : router.go(Routes.selectRole));
      } else {
        throw "auth.login.errorMessageNoRoles".tr();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      AlertManager().showFailureToast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text("Debug SSO Login"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  const Text(
                    "Debug SSO Login",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Instructions
                  const Text(
                    "Paste the full SSO callback URL below to"
                    " login without SSO redirect.",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Example format
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBackground,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.darkGrey),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Expected format (paste full URL):",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 8),
                        SelectableText(
                          _exampleFormat,
                          style: TextStyle(
                            fontFamily: "monospace",
                            fontSize: 11,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Input textarea
                  TextField(
                    controller: _controller,
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText: "Paste full SSO callback URL here...",
                      border: const OutlineInputBorder(),
                      errorText: _errorMessage,
                      errorMaxLines: 3,
                    ),
                    style: const TextStyle(
                      fontFamily: "monospace",
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Submit button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                            ),
                          )
                        : const Text(
                            "Submit",
                            style: TextStyle(fontSize: 14),
                          ),
                  ),

                  // Help text
                  const SizedBox(height: 8),
                  const Text(
                    "Note: This screen is only available in debug mode.",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkGrey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
