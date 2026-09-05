part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const SPLASH = _Paths.SPLASH;
  static const LOGIN = _Paths.LOGIN;
  static const OTP_VALIDATION = _Paths.OTP_VALIDATION;
  static const ORDER_DETAILS = _Paths.ORDER_DETAILS;
  static const DEVICE_LOCATION = _Paths.DEVICE_LOCATION;
  static const EARNINGS = _Paths.EARNINGS;
  static const ORDERS = _Paths.ORDERS;
  static const PROFILE = _Paths.PROFILE;
  static const NAVIGATE_TO_DELIVER = _Paths.NAVIGATE_TO_DELIVER;
  static const MAP_WEBVIEW = _Paths.MAP_WEBVIEW;
  static const DELIVERY_OTP = _Paths.DELIVERY_OTP;
  static const CONFIRM_DELIVERY = _Paths.CONFIRM_DELIVERY;
  static const COLLECT_PAYMENT = _Paths.COLLECT_PAYMENT;
  static const DELIVERY_SUCCESS = _Paths.DELIVERY_SUCCESS;
  static const CUSTOMER_UNAVAILABLE = _Paths.CUSTOMER_UNAVAILABLE;
  static const DELIVERY_FAILED_REASON = _Paths.DELIVERY_FAILED_REASON;
  static const DELIVERY_FAILED_SUMMARY = _Paths.DELIVERY_FAILED_SUMMARY;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const OTP_VALIDATION = '/otp-validation';
  static const ORDER_DETAILS = '/order-details';
  static const DEVICE_LOCATION = '/device-location';
  static const EARNINGS = '/earnings';
  static const ORDERS = '/orders';
  static const PROFILE = '/profile';
  static const NAVIGATE_TO_DELIVER = '/navigate-to-deliver';
  static const MAP_WEBVIEW = '/map-webview';
  static const DELIVERY_OTP = '/delivery-otp';
  static const CONFIRM_DELIVERY = '/confirm-delivery';
  static const COLLECT_PAYMENT = '/collect-payment';
  static const DELIVERY_SUCCESS = '/delivery-success';
  static const CUSTOMER_UNAVAILABLE = '/customer-unavailable';
  static const DELIVERY_FAILED_REASON = '/delivery-failed-reason';
  static const DELIVERY_FAILED_SUMMARY = '/delivery-failed-summary';
}
