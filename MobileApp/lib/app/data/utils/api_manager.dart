class ApiManager {
  static const String baseUrl = "https://bulkify.dts.ind.in/"; //staging
  static const String loginUrl = "core/v1/auth/initiate";
  static const String verifyOtpUrl = "core/v1/auth/verify";
  static const String getConnect = "contact/v1/profile";
  //static const String getOrderList = "orders/v1/orderlist";
  static const String getOrderList = "driver/v1/orders";
  static const String summary = "contact/v1/summary";
  static const String onlinestatus = "contact/v1/onlinestatus";
  static const String pendingOffer = "driver/v1/offers/pending";
  static const String acceptOrder = "driver/v1/accept";
  static const String rejectOrder = "driver/v1/reject";
  static const String driverStatus = "driver/v1/status";
}
