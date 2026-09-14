class ApiManager {
  // Base URL is injected at build time via --dart-define=API_BASE_URL=https://...
  // Falls back to the staging URL if not provided.
  // Production build command example:
  //   flutter build web --dart-define=API_BASE_URL=https://bulkify.dts.ind.in/
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://bulkify.dts.ind.in/',
  );

  static const String loginUrl = "core/v1/auth/initiate";
  static const String verifyOtpUrl = "core/v1/auth/verify";
  static const String getOrderList = "zoho/v1/salesorder/list";
  static const String getOrderDetails = "zoho/v1/salesorder/get";
  static const String getUserList = "users/v1/list";
  static const String invoiceDownload = "zoho/v1/invoice/download";
}
