import 'package:get/get.dart';

import '../modules/auth_module/login/bindings/login_binding.dart';
import '../modules/auth_module/login/views/login_view.dart';
import '../modules/auth_module/otp_validation/bindings/otp_validation_binding.dart';
import '../modules/auth_module/otp_validation/views/otp_validation_view.dart';
import '../modules/auth_module/splash/bindings/splash_binding.dart';
import '../modules/auth_module/splash/views/splash_view.dart';
import '../modules/device_location/bindings/device_location_binding.dart';
import '../modules/device_location/views/device_location_view.dart';
import '../modules/earnings/bindings/earnings_binding.dart';
import '../modules/earnings/views/earnings_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/delivery_failed_summary/bindings/delivery_failed_summary_binding.dart';
import '../modules/delivery_failed_summary/views/delivery_failed_summary_view.dart';
import '../modules/delivery_failed_reason/bindings/delivery_failed_reason_binding.dart';
import '../modules/delivery_failed_reason/views/delivery_failed_reason_view.dart';
import '../modules/customer_unavailable/bindings/customer_unavailable_binding.dart';
import '../modules/customer_unavailable/views/customer_unavailable_view.dart';
import '../modules/delivery_success/bindings/delivery_success_binding.dart';
import '../modules/delivery_success/views/delivery_success_view.dart';
import '../modules/collect_payment/bindings/collect_payment_binding.dart';
import '../modules/collect_payment/views/collect_payment_view.dart';
import '../modules/confirm_delivery/bindings/confirm_delivery_binding.dart';
import '../modules/confirm_delivery/views/confirm_delivery_view.dart';
import '../modules/delivery_otp/bindings/delivery_otp_binding.dart';
import '../modules/delivery_otp/views/delivery_otp_view.dart';
import '../modules/map_webview/bindings/map_webview_binding.dart';
import '../modules/map_webview/views/map_webview_view.dart';
import '../modules/navigate_to_deliver/bindings/navigate_to_deliver_binding.dart';
import '../modules/navigate_to_deliver/views/navigate_to_deliver_view.dart';
import '../modules/order_details/bindings/order_details_binding.dart';
import '../modules/order_details/views/order_details_view.dart';
import '../modules/orders/bindings/orders_binding.dart';
import '../modules/orders/views/orders_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.OTP_VALIDATION,
      page: () => const OtpValidationView(),
      binding: OtpValidationBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_DETAILS,
      page: () => const OrderDetailsView(),
      binding: OrderDetailsBinding(),
    ),
    GetPage(
      name: _Paths.DEVICE_LOCATION,
      page: () => const DeviceLocationView(),
      binding: DeviceLocationBinding(),
    ),
    GetPage(
      name: _Paths.EARNINGS,
      page: () => const EarningsView(),
      binding: EarningsBinding(),
    ),
    GetPage(
      name: _Paths.ORDERS,
      page: () => const OrdersView(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.NAVIGATE_TO_DELIVER,
      page: () => const NavigateToDeliverView(),
      binding: NavigateToDeliverBinding(),
    ),
    GetPage(
      name: _Paths.MAP_WEBVIEW,
      page: () => const MapWebviewView(),
      binding: MapWebviewBinding(),
    ),
    GetPage(
      name: _Paths.DELIVERY_OTP,
      page: () => const DeliveryOtpView(),
      binding: DeliveryOtpBinding(),
    ),
    GetPage(
      name: _Paths.CONFIRM_DELIVERY,
      page: () => const ConfirmDeliveryView(),
      binding: ConfirmDeliveryBinding(),
    ),
    GetPage(
      name: _Paths.COLLECT_PAYMENT,
      page: () => const CollectPaymentView(),
      binding: CollectPaymentBinding(),
    ),
    GetPage(
      name: _Paths.DELIVERY_SUCCESS,
      page: () => const DeliverySuccessView(),
      binding: DeliverySuccessBinding(),
    ),
    GetPage(
      name: _Paths.CUSTOMER_UNAVAILABLE,
      page: () => const CustomerUnavailableView(),
      binding: CustomerUnavailableBinding(),
    ),
    GetPage(
      name: _Paths.DELIVERY_FAILED_REASON,
      page: () => const DeliveryFailedReasonView(),
      binding: DeliveryFailedReasonBinding(),
    ),
    GetPage(
      name: _Paths.DELIVERY_FAILED_SUMMARY,
      page: () => const DeliveryFailedSummaryView(),
      binding: DeliveryFailedSummaryBinding(),
    ),
  ];
}
