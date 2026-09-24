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
  //static const String getOrderList1 = "zoho/v1/salesorder/list";
  static const String getOrderList = "orders/v1/list";
  static const String getOrderDetails = "orders/v1/get-by-key";
  //static const String getOrderDetails1 = "zoho/v1/salesorder/get";
  static const String getUserList = "users/v1/list";
  static const String invoiceDownload = "zoho/v1/invoice/download";
  static const String userAdd = "users/v1/add";
  static const String staticRoleKey = "8e13d862-6073-443b-9e3e-64ab84e25005";
  static const String roleList = "roles/v1/list";
  static const String userDetails = "users/v1/get-by-key";
  static const String paymentList = "payments/v1/list";
  static const String paymentDetails = "payments/v1/get-by-key";
}
