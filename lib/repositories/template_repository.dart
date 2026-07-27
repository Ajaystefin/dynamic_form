/// Repository responsible for handling template-related operations.
/// 
/// Implements a singleton pattern to provide a single shared instance
/// across the application.
class TemplateRepository {
  /// Private constructor to prevent external instantiation.
  TemplateRepository._();

  /// Internal singleton instance of [TemplateRepository].
  static final TemplateRepository _instance = TemplateRepository._();

  /// Returns the singleton instance of [TemplateRepository].
  static TemplateRepository get instance => _instance;
}
