import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_app/controllers/order_controller.dart';
import 'package:admin_app/models/order_model.dart';
import 'package:admin_app/service/order_service.dart';
import 'package:admin_app/utils/blob_downloader.dart';
import 'package:intl/intl.dart';

class PaymentTransactionModel {
  final String issuedBy;
  final String createdOn;
  final String paymentId;
  final String paymentMethod;
  final String rrnUtr;
  final String status;
  final String amount;

  PaymentTransactionModel({
    required this.issuedBy,
    required this.createdOn,
    required this.paymentId,
    required this.paymentMethod,
    required this.rrnUtr,
    required this.status,
    required this.amount,
  });
}

class LineItemTaxModel {
  final String taxName;
  final String taxAmount;
  final double taxPercent;

  LineItemTaxModel({
    required this.taxName,
    required this.taxAmount,
    this.taxPercent = 0.0,
  });
}

class OrderItemModel {
  final String sku;
  final String name;
  final String itemType;
  final String description;
  final String price;
  final RxInt qty;
  final TextEditingController qtyController;
  final RxString total;
  final List<LineItemTaxModel> lineItemTaxes;
  final RxBool isAccepted;
  final RxBool isRejected;

  OrderItemModel({
    this.sku = '-',
    required this.name,
    required this.itemType,
    required this.description,
    required this.price,
    required int qty,
    required String total,
    this.lineItemTaxes = const [],
    bool initialAccepted = false,
    bool initialRejected = false,
  }) : qty = qty.obs,
       qtyController = TextEditingController(text: qty.toString()),
       total = total.obs,
       isAccepted = initialAccepted.obs,
       isRejected = initialRejected.obs;

  String get merchant => description;
}

class DocumentModel {
  final String title;
  final String code;

  DocumentModel({required this.title, required this.code});
}

class ShippingDriverModel {
  final String initials;
  final String name;
  final String vehicle;
  final String distance;
  final int activeOrders;
  final String status;
  final bool isPrimary;
  final String? driverKey;
  final String? driverUserKey;
  final String? phone;
  final String? fcmtoken;
  final Map<String, dynamic> rawJson;

  ShippingDriverModel({
    required this.initials,
    required this.name,
    required this.vehicle,
    required this.distance,
    required this.activeOrders,
    required this.status,
    this.isPrimary = false,
    this.driverKey,
    this.driverUserKey,
    this.phone,
    this.fcmtoken,
    this.rawJson = const {},
  });

  factory ShippingDriverModel.fromJson(Map<String, dynamic> json) {
    final String rawName =
        (json['name'] ??
                json['drivername'] ??
                json['driver_name'] ??
                json['fullname'] ??
                json['full_name'] ??
                json['username'] ??
                json['first_name'] ??
                'Driver')
            .toString()
            .trim();

    final String formattedName = rawName.isNotEmpty
        ? rawName.split(RegExp(r'\s+')).map((word) {
            if (word.isEmpty) return word;
            return word[0].toUpperCase() + word.substring(1).toLowerCase();
          }).join(' ')
        : 'Driver';

    String initials = (json['initials'] ?? '').toString().trim();
    if (initials.isEmpty) {
      final parts = formattedName.split(' ').where((p) => p.isNotEmpty).toList();
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (formattedName.isNotEmpty) {
        initials = formattedName
            .substring(0, formattedName.length >= 2 ? 2 : 1)
            .toUpperCase();
      } else {
        initials = 'DR';
      }
    }

    dynamic vehicleData =
        json['vehicle'] ??
        json['vehicletype'] ??
        json['vehicle_type'] ??
        json['transport_type'] ??
        json['transport'] ??
        json['mode'];

    String vehicle = '';
    if (vehicleData is Map) {
      final vName = (vehicleData['name'] ?? '').toString().trim();
      final vType = (vehicleData['type'] ?? '').toString().trim();
      final vReg =
          (vehicleData['registrationnumber'] ??
                  vehicleData['registration_number'] ??
                  vehicleData['reg_number'] ??
                  vehicleData['regnumber'] ??
                  '')
              .toString()
              .trim();
      final parts = [
        vName,
        vType,
        vReg,
      ].where((s) => s.isNotEmpty && s != 'null').toList();
      vehicle = parts.join(', ');
    } else if (vehicleData != null) {
      String str = vehicleData.toString().trim();
      str = str
          .replaceAll('{', '')
          .replaceAll('}', '')
          .replaceAll('name:', '')
          .replaceAll('name :', '')
          .replaceAll('type:', '')
          .replaceAll('type :', '')
          .replaceAll('registrationnumber:', '')
          .replaceAll('registrationnumber :', '')
          .replaceAll('registration_number:', '')
          .replaceAll('registration_number :', '');
      vehicle = str
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty && s != 'null')
          .join(', ');
    }

    if (vehicle.isEmpty) {
      vehicle = 'Van';
    }

    dynamic rawDist =
        json['distance'] ??
        json['distancetext'] ??
        json['distance_text'] ??
        json['distance_km'] ??
        json['distance_in_km'] ??
        json['distance_from_store'] ??
        json['km'];
    String distance = '';
    if (rawDist is num) {
      distance = '${rawDist.toStringAsFixed(1)} km from store';
    } else if (rawDist != null && rawDist.toString().trim().isNotEmpty) {
      String distStr = rawDist.toString().trim();
      if (!distStr.toLowerCase().contains('store') &&
          !distStr.toLowerCase().contains('km')) {
        distance = '$distStr km from store';
      } else if (!distStr.toLowerCase().contains('store')) {
        distance = '$distStr from store';
      } else {
        distance = distStr;
      }
    } else {
      distance = '1.0 km from store';
    }

    final dynamic rawOrders =
        json['activeorders'] ??
        json['active_orders'] ??
        json['current_orders'] ??
        json['orders_count'] ??
        json['activeordercount'] ??
        json['runningorders'] ??
        json['orders'];
    final int activeOrders = rawOrders is int
        ? rawOrders
        : (int.tryParse(rawOrders?.toString() ?? '0') ?? 0);

    final dynamic rawOnline =
        json['status'] ??
        json['onlinestatus'] ??
        json['online_status'] ??
        json['driverstatus'] ??
        json['availability'];
    String status = 'Online';
    if (rawOnline != null) {
      final s = rawOnline.toString().trim().toLowerCase();
      if (s == 'online' || s == 'available' || s == 'active') {
        status = 'Online';
      } else if (s == 'busy' || s == 'on_trip' || s == 'delivering') {
        status = 'Busy';
      } else if (s == 'offline' || s == 'inactive') {
        status = 'Offline';
      } else {
        status = s.length == 1
            ? s.toUpperCase()
            : s[0].toUpperCase() + s.substring(1);
      }
    } else if (json['isonline'] == false || json['is_online'] == false) {
      status = 'Offline';
    } else if (json['isbusy'] == true || json['is_busy'] == true) {
      status = 'Busy';
    }

    final bool isPrimary =
        json['isprimary'] == true ||
        json['is_primary'] == true ||
        json['primary'] == true;

    final String? resolvedDriverUserKey =
        (json['driveruserkey'] ??
                json['driver_user_key'] ??
                json['userkey'] ??
                json['user_key'] ??
                json['driverkey'] ??
                json['driver_key'] ??
                json['driverid'] ??
                json['driver_id'] ??
                json['id'] ??
                json['key'])
            ?.toString()
            .trim();

    final String? phone =
        (json['mobile'] ??
                json['mobilenumber'] ??
                json['phone'] ??
                json['phonenumber'])
            ?.toString();

    final String? fcmToken =
        (json['fcmtoken'] ??
                json['fcmToken'] ??
                json['fcm_token'] ??
                json['devicetoken'] ??
                json['device_token'] ??
                json['push_token'] ??
                json['pushtoken'] ??
                json['token'] ??
                (json['driver'] is Map
                    ? (json['driver']['fcmtoken'] ??
                          json['driver']['fcmToken'] ??
                          json['driver']['devicetoken'])
                    : null) ??
                (json['user'] is Map
                    ? (json['user']['fcmtoken'] ??
                          json['user']['fcmToken'] ??
                          json['user']['devicetoken'])
                    : null))
            ?.toString()
            .trim();

    return ShippingDriverModel(
      initials: initials,
      name: formattedName,
      vehicle: vehicle,
      distance: distance,
      activeOrders: activeOrders,
      status: status,
      isPrimary: isPrimary,
      driverKey: resolvedDriverUserKey,
      driverUserKey: resolvedDriverUserKey,
      phone: phone,
      fcmtoken: fcmToken,
      rawJson: json,
    );
  }
}

class ShippingActivityModel {
  final String title;
  final String timestamp;
  final String description;
  final bool isCompleted;
  final String? highlightText;

  ShippingActivityModel({
    required this.title,
    required this.timestamp,
    required this.description,
    this.isCompleted = true,
    this.highlightText,
  });
}

class OrderDetailsController extends GetxController {
  final OrderService _orderService = Get.put(OrderService());

  final Rxn<OrderModel> selectedOrder = Rxn<OrderModel>();
  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;

  // Summary Fields
  final RxString orderKey = ''.obs;
  final RxString orderId = ''.obs;
  final RxString salesOrderId = ''.obs;
  final RxBool isAcceptingOrder = false.obs;
  final RxBool isRejectingOrder = false.obs;
  final RxBool isOrderAccepted = false.obs;
  final RxString customerId = ''.obs;

  bool get isDraftOrPending {
    if (isOrderAccepted.value) return false;
    final status = orderStatus.value.trim().toLowerCase();
    if (status == 'invoiced' || status == 'open') return false;
    return status == 'draft' || status == 'pending';
  }

  bool get shouldShowShippingActivity {
    final rawStatus = orderStatus.value.trim().toLowerCase();
    if (rawStatus == 'invoiced' || rawStatus == 'open') {
      return true;
    }

    // If order status is draft or pending, always show "no shipping activity found"
    if (isDraftOrPending) return false;

    if (isOrderAccepted.value) return true;
    if (orderItems.isNotEmpty &&
        orderItems.any((item) => item.isAccepted.value)) {
      return true;
    }

    if (rawStatus == 'accepted' ||
        rawStatus == 'confirmed' ||
        rawStatus == 'approved' ||
        rawStatus == 'fulfilled') {
      return true;
    }

    final rawShip = shipmentStatus.value.trim().toLowerCase();
    if (rawShip == 'packed' ||
        rawShip == 'dispatched' ||
        rawShip == 'shipped' ||
        rawShip.contains('transit') ||
        rawShip.contains('deliver')) {
      return true;
    }

    return false;
  }

  final RxBool isSubmittingPayment = false.obs;
  final RxString orderNo = ''.obs;
  final RxString date = ''.obs;
  final RxString time = ''.obs;
  final RxString customer = ''.obs;
  final RxString company = ''.obs;
  final RxString channel = ''.obs;
  final RxString paymentMethod = ''.obs;
  final RxString orderStatus = ''.obs;
  final RxString shipmentStatus = ''.obs;

  // Shipping Address
  final RxString shippingName = ''.obs;
  final RxString shippingPhone = ''.obs;
  final RxString shippingAddress = ''.obs;
  final RxString shippingPincode = ''.obs;

  // Billing Address
  final RxString billingName = ''.obs;
  final RxString billingPhone = ''.obs;
  final RxString billingAddress = ''.obs;
  final RxString billingPincode = ''.obs;

  // Price Breakdown
  final RxString subtotal = ''.obs;
  final RxString shippingFee = ''.obs;
  final RxString platformFee = ''.obs;
  final RxString bankFee = ''.obs;
  final RxString discountPercent = ''.obs;
  final RxString couponDiscount = ''.obs;
  final RxString couponCode = '#WELCOME10'.obs;
  final RxString tax = ''.obs;
  final RxString cgst = ''.obs;
  final RxString sgst = ''.obs;
  final RxString igst = ''.obs;
  final RxString grandTotal = ''.obs;
  final RxDouble dueAmount = 0.0.obs;
  final RxDouble paidAmount = 0.0.obs;
  final RxBool hasExplicitDueAmount = false.obs;

  // Invoice details
  final RxString invoiceId = ''.obs;
  final RxString invoiceNumber = ''.obs;
  final RxBool isDownloadingInvoice = false.obs;
  final RxBool isInvoiceDownloaded = false.obs;

  // Documents List
  final RxList<DocumentModel> documents = <DocumentModel>[].obs;

  // Payment Transactions List
  final RxList<PaymentTransactionModel> transactions =
      <PaymentTransactionModel>[].obs;

  // Order Items List
  final RxList<OrderItemModel> orderItems = <OrderItemModel>[].obs;

  // Shipping Activity Timeline & Driver Assignment State
  final RxList<ShippingActivityModel> shippingActivities =
      <ShippingActivityModel>[].obs;
  final RxInt currentShippingStep = 0.obs;
  final RxString assignedDriverName = ''.obs;
  final RxString assignedDriverPhone = ''.obs;
  final RxString assignedDriverVehicle = ''.obs;
  final RxString pickedUpTime = ''.obs;
  final RxString inTransitTime = ''.obs;
  final RxString outForDeliveryTime = ''.obs;
  final RxString deliveredTime = ''.obs;
  final RxString driverSearchQuery = ''.obs;
  final RxString selectedDriverAvailability = 'Online'.obs;
  final RxString selectedDriverSort = 'Nearest first'.obs;
  final RxBool markAsPackedOnAssign = true.obs;
  final RxBool notifyCustomerOnAssign = true.obs;

  List<String> get availableDriverStatuses => const ['Online', 'Busy'];

  final List<String> shippingSteps = const [
    'Accepted',
    'Driver Assigned',
    'Picked Up',
    'In Transit',
    'Out for Delivery',
    'Delivered',
  ];

  final RxBool isLoadingDrivers = false.obs;
  final RxBool isRefreshingPage = false.obs;

  final RxList<ShippingDriverModel> drivers = <ShippingDriverModel>[
    ShippingDriverModel(
      initials: 'JD',
      name: 'Jhon Doe',
      vehicle: 'Van',
      distance: '1.2 km from store',
      activeOrders: 2,
      status: 'Online',
      isPrimary: true,
    ),
    ShippingDriverModel(
      initials: 'AK',
      name: '[Driver name]',
      vehicle: 'Bike',
      distance: '3.8 km from store',
      activeOrders: 0,
      status: 'Online',
    ),
    ShippingDriverModel(
      initials: 'MR',
      name: '[Driver name]',
      vehicle: 'Van',
      distance: '6.1 km from store',
      activeOrders: 4,
      status: 'Busy',
    ),
    ShippingDriverModel(
      initials: 'RK',
      name: '[Driver name]',
      vehicle: 'Bike',
      distance: '2.4 km from store',
      activeOrders: 1,
      status: 'Online',
    ),
    ShippingDriverModel(
      initials: 'SP',
      name: '[Driver name]',
      vehicle: 'Van',
      distance: '4.5 km from store',
      activeOrders: 3,
      status: 'Busy',
    ),
  ].obs;

  Future<void> fetchDrivers({String? orderKeyParam, String? searchKey}) async {
    final String targetOrderKey =
        (orderKeyParam != null && orderKeyParam.trim().isNotEmpty)
        ? orderKeyParam.trim()
        : orderKey.value.trim();

    if (targetOrderKey.isEmpty) {
      return;
    }

    final String query = (searchKey ?? driverSearchQuery.value).trim();
    isLoadingDrivers.value = true;

    try {
      final res = await _orderService.getDriverList(
        orderkey: targetOrderKey,
        search: query,
        sort: 'nearest',
        includeoffline: false,
        limit: 50,
      );

      if (res != null) {
        List<dynamic>? rawList;
        final data = res['data'];
        if (data is List) {
          rawList = data;
        } else if (data is Map) {
          if (data['drivers'] is List) {
            rawList = data['drivers'] as List;
          } else if (data['items'] is List) {
            rawList = data['items'] as List;
          } else if (data['list'] is List) {
            rawList = data['list'] as List;
          }
        } else if (res['drivers'] is List) {
          rawList = res['drivers'] as List;
        }

        if (rawList != null && rawList.isNotEmpty) {
          final parsed = rawList
              .whereType<Map>()
              .map(
                (d) =>
                    ShippingDriverModel.fromJson(Map<String, dynamic>.from(d)),
              )
              .toList();
          if (parsed.isNotEmpty) {
            drivers.value = parsed;
          }
        }
      }
    } catch (_) {
      // Keep existing list on error
    } finally {
      isLoadingDrivers.value = false;
    }
  }

  List<ShippingDriverModel> get filteredDrivers {
    final q = driverSearchQuery.value.trim().toLowerCase();
    final statuses = availableDriverStatuses;
    final selectedStatus = statuses.contains(selectedDriverAvailability.value)
        ? selectedDriverAvailability.value.trim().toLowerCase()
        : (statuses.isNotEmpty ? statuses.first.trim().toLowerCase() : '');

    return drivers.where((d) {
      if (q.isNotEmpty &&
          !d.name.toLowerCase().contains(q) &&
          !(d.phone ?? '').toLowerCase().contains(q)) {
        return false;
      }
      if (selectedStatus.isNotEmpty) {
        if (d.status.trim().toLowerCase() != selectedStatus) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  final RxBool isAssigningDriver = false.obs;
  final RxString assigningDriverUserKey = ''.obs;

  final RxMap<String, int> driverAssignClickCount = <String, int>{}.obs;
  final RxMap<String, int> driverAssignCooldown = <String, int>{}.obs;
  final RxMap<String, String> driverAssignmentKeys = <String, String>{}.obs;
  final RxMap<String, bool> driverIsCheckingStatus = <String, bool>{}.obs;
  final RxMap<String, bool> driverHasAccepted = <String, bool>{}.obs;
  final Map<String, Timer> _driverCooldownTimers = <String, Timer>{};

  String getDriverIdentifier(ShippingDriverModel driver) {
    final key =
        (driver.driverUserKey ??
                driver.driverKey ??
                driver.phone ??
                driver.name)
            .trim();
    return key.isNotEmpty ? key : driver.name.trim();
  }

  void _clearDriverTimers() {
    for (final timer in _driverCooldownTimers.values) {
      timer.cancel();
    }
    _driverCooldownTimers.clear();
    driverAssignCooldown.clear();
    driverAssignmentKeys.clear();
    driverIsCheckingStatus.clear();
    driverHasAccepted.clear();
  }

  void _startDriverCooldown(
    String driverId,
    int seconds,
    ShippingDriverModel driver,
  ) {
    _driverCooldownTimers[driverId]?.cancel();
    driverAssignCooldown[driverId] = seconds;
    _driverCooldownTimers[driverId] = Timer.periodic(
      const Duration(seconds: 1),
      (timer) async {
        final current = driverAssignCooldown[driverId] ?? 0;
        if (current <= 1) {
          driverAssignCooldown[driverId] = 0;
          timer.cancel();
          _driverCooldownTimers.remove(driverId);
          // After 30s wait, check if driver accepted the order
          await _checkDriverAcceptance(driverId, driver);
        } else {
          driverAssignCooldown[driverId] = current - 1;
        }
      },
    );
  }

  String formatIso(dynamic raw) {
    if (raw == null) return '';
    final s = raw.toString().trim();
    if (s.isEmpty || s == 'null') return '';
    try {
      final dt = DateTime.parse(s).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final mon = dt.month.toString().padLeft(2, '0');
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$day-$mon-${dt.year} $hour:$min';
    } catch (_) {
      return s;
    }
  }

  void _applyAssignmentData(dynamic res) {
    if (res == null) return;
    final dynamic data =
        (res is Map && res['data'] != null && res['data'] is Map)
        ? res['data']
        : res;

    final dynamic currentMap = (data is Map && data['current'] is Map)
        ? data['current']
        : ((res is Map && res['current'] is Map) ? res['current'] : null);

    if (currentMap is Map) {
      final String acceptedDriverName =
          (currentMap['drivername'] ??
                  currentMap['driver_name'] ??
                  currentMap['name'] ??
                  '')
              .toString()
              .trim();
      if (acceptedDriverName.isNotEmpty) {
        assignedDriverName.value = acceptedDriverName;
      }

      final String dPhone =
          (currentMap['phone'] ??
                  currentMap['mobilenumber'] ??
                  currentMap['mobile'] ??
                  '')
              .toString()
              .trim();
      if (dPhone.isNotEmpty) {
        assignedDriverPhone.value = dPhone;
      }

      if (currentMap['vehicle'] is Map) {
        final v = currentMap['vehicle'];
        final vName =
            (v['name'] ?? v['model'] ?? v['vehiclename'])?.toString().trim() ??
            '';
        final vReg =
            (v['registrationnumber'] ??
                    v['reg_number'] ??
                    v['registration_number'] ??
                    v['number'])
                ?.toString()
                .trim() ??
            '';
        final vType = v['type']?.toString().trim() ?? '';
        assignedDriverVehicle.value = [
          if (vName.isNotEmpty) vName else if (vType.isNotEmpty) vType,
          if (vReg.isNotEmpty) vReg,
        ].join(' · ');
      }

      final String dUserKey =
          (currentMap['driveruserkey'] ?? currentMap['driver_user_key'] ?? '')
              .toString()
              .trim();
      if (dUserKey.isNotEmpty) {
        driverHasAccepted[dUserKey] = true;
      }

      // Build shipping activities list
      final List<ShippingActivityModel> activities = [];

      final dName = assignedDriverName.value.isNotEmpty
          ? assignedDriverName.value
          : 'Driver';

      final assignedOn = currentMap['assignedtime'] ??
          currentMap['assigned_time'] ??
          currentMap['assignedon'] ??
          currentMap['assigned_on'] ??
          (data is Map
              ? (data['assignedtime'] ??
                  data['assigned_time'] ??
                  data['assignedon'])
              : null);

      final respondedOn = currentMap['acceptedtime'] ??
          currentMap['accepted_time'] ??
          currentMap['respondedon'] ??
          currentMap['responded_on'] ??
          (data is Map
              ? (data['acceptedtime'] ??
                  data['accepted_time'] ??
                  data['respondedon'])
              : null);

      final assignedBy =
          (currentMap['assignedby'] ?? currentMap['assigned_by'] ?? 'Admin')
              .toString()
              .trim();
      final state = (currentMap['state'] ?? currentMap['status'] ?? '')
          .toString()
          .toLowerCase();

      final pickedUpOn = currentMap['pickeduptime'] ??
          currentMap['picked_up_time'] ??
          currentMap['pickuptime'] ??
          currentMap['pickup_time'] ??
          currentMap['pickedon'] ??
          currentMap['picked_on'] ??
          currentMap['pickedup_on'] ??
          currentMap['picked_up_on'] ??
          currentMap['picked_up_at'] ??
          currentMap['pickedup_at'] ??
          (data is Map
              ? (data['pickeduptime'] ??
                  data['picked_up_time'] ??
                  data['pickup_time'] ??
                  data['pickuptime'])
              : null) ??
          currentMap['modifiedon'] ??
          currentMap['modified_on'] ??
          currentMap['updatedon'] ??
          currentMap['updated_at'];

      final inTransitOn = currentMap['intransittime'] ??
          currentMap['in_transit_time'] ??
          currentMap['transittime'] ??
          currentMap['transit_time'] ??
          currentMap['in_transittime'] ??
          (data is Map
              ? (data['intransittime'] ??
                  data['in_transit_time'] ??
                  data['transittime'])
              : null);

      final outForDeliveryOn = currentMap['outfordeliverytime'] ??
          currentMap['out_for_delivery_time'] ??
          currentMap['outdeliverytime'] ??
          currentMap['out_delivery_time'] ??
          (data is Map
              ? (data['outfordeliverytime'] ??
                  data['out_for_delivery_time'] ??
                  data['outdeliverytime'])
              : null);

      final deliveredOn = currentMap['deliveredtime'] ??
          currentMap['delivered_time'] ??
          currentMap['deliveredon'] ??
          currentMap['delivered_on'] ??
          currentMap['closedon'] ??
          currentMap['closed_on'] ??
          (data is Map
              ? (data['deliveredtime'] ??
                  data['delivered_time'] ??
                  data['closedon'])
              : null);

      if (pickedUpOn != null &&
          pickedUpOn.toString().trim().isNotEmpty &&
          pickedUpOn.toString().trim() != 'null') {
        pickedUpTime.value = formatIso(pickedUpOn);
      }
      if (inTransitOn != null &&
          inTransitOn.toString().trim().isNotEmpty &&
          inTransitOn.toString().trim() != 'null') {
        inTransitTime.value = formatIso(inTransitOn);
      }
      if (outForDeliveryOn != null &&
          outForDeliveryOn.toString().trim().isNotEmpty &&
          outForDeliveryOn.toString().trim() != 'null') {
        outForDeliveryTime.value = formatIso(outForDeliveryOn);
      }
      if (deliveredOn != null &&
          deliveredOn.toString().trim().isNotEmpty &&
          deliveredOn.toString().trim() != 'null') {
        deliveredTime.value = formatIso(deliveredOn);
      }

      final lowerShipStatus = shipmentStatus.value.toLowerCase().trim();
      int calculatedStep = currentShippingStep.value;
      if (deliveredOn != null ||
          state == 'delivered' ||
          lowerShipStatus == 'delivered') {
        calculatedStep = 5;
      } else if (outForDeliveryOn != null ||
          state == 'out_for_delivery' ||
          state.contains('out') ||
          lowerShipStatus.contains('out')) {
        calculatedStep = 4;
      } else if (inTransitOn != null ||
          state == 'in_transit' ||
          state.contains('transit') ||
          lowerShipStatus.contains('transit')) {
        calculatedStep = 3;
      } else if (pickedUpOn != null ||
          state == 'picked_up' ||
          state.contains('pick') ||
          lowerShipStatus.contains('pick')) {
        calculatedStep = 2;
      } else if (state == 'accepted' ||
          (state.contains('accept') && !state.contains('assign'))) {
        calculatedStep = 1;
      }
      if (calculatedStep > currentShippingStep.value) {
        currentShippingStep.value = calculatedStep;
        shipmentStatus.value = shippingSteps[calculatedStep];
      }

      final isDelivered = currentShippingStep.value >= 5 ||
          deliveredOn != null ||
          state == 'delivered';

      final isOutForDelivery = currentShippingStep.value >= 4 ||
          outForDeliveryOn != null ||
          state == 'out_for_delivery' ||
          state.contains('out') ||
          lowerShipStatus.contains('out') ||
          isDelivered;

      final isInTransit = currentShippingStep.value >= 3 ||
          inTransitOn != null ||
          state == 'in_transit' ||
          state.contains('transit') ||
          lowerShipStatus.contains('transit') ||
          isOutForDelivery;

      final isPickedUp = currentShippingStep.value >= 2 ||
          pickedUpOn != null ||
          state == 'picked_up' ||
          state.contains('pick') ||
          lowerShipStatus.contains('pick') ||
          isInTransit;

      final isAccepted = currentShippingStep.value >= 1 ||
          respondedOn != null ||
          state == 'accepted' ||
          isPickedUp;

      // Most recent on top:
      // 1. Delivered
      if (isDelivered) {
        final delTimeStr = deliveredOn != null
            ? formatIso(deliveredOn)
            : (deliveredTime.value.isNotEmpty
                ? deliveredTime.value
                : (outForDeliveryOn != null
                    ? formatIso(outForDeliveryOn)
                    : formatIso(DateTime.now())));
        activities.add(
          ShippingActivityModel(
            title: 'Delivered',
            timestamp: delTimeStr,
            description: 'Order delivered successfully · Driver App',
          ),
        );
      }

      // 2. Out for Delivery
      if (isOutForDelivery) {
        final outTimeStr = outForDeliveryOn != null
            ? formatIso(outForDeliveryOn)
            : (outForDeliveryTime.value.isNotEmpty
                ? outForDeliveryTime.value
                : (inTransitOn != null
                    ? formatIso(inTransitOn)
                    : (pickedUpOn != null
                        ? formatIso(pickedUpOn)
                        : (respondedOn != null
                            ? formatIso(respondedOn)
                            : (assignedOn != null
                                ? formatIso(assignedOn)
                                : formatIso(DateTime.now()))))));
        activities.add(
          ShippingActivityModel(
            title: 'Out for Delivery',
            timestamp: outTimeStr,
            description: 'Reaching customer location · Driver App',
          ),
        );
      }

      // 3. In Transit
      if (isInTransit) {
        final inTransitTimeStr = inTransitOn != null
            ? formatIso(inTransitOn)
            : (inTransitTime.value.isNotEmpty
                ? inTransitTime.value
                : (pickedUpOn != null
                    ? formatIso(pickedUpOn)
                    : (respondedOn != null
                        ? formatIso(respondedOn)
                        : (assignedOn != null
                            ? formatIso(assignedOn)
                            : formatIso(DateTime.now())))));
        activities.add(
          ShippingActivityModel(
            title: 'In Transit',
            timestamp: inTransitTimeStr,
            description: 'On the way to delivery location · Driver App',
          ),
        );
      }

      // 4. Driver picked up
      if (isPickedUp) {
        final pickupTimeStr = pickedUpOn != null
            ? formatIso(pickedUpOn)
            : (pickedUpTime.value.isNotEmpty
                ? pickedUpTime.value
                : (respondedOn != null
                    ? formatIso(respondedOn)
                    : (assignedOn != null
                        ? formatIso(assignedOn)
                        : formatIso(DateTime.now()))));

        activities.add(
          ShippingActivityModel(
            title: 'Driver picked up: $dName',
            timestamp: pickupTimeStr,
            description: 'Driver App · Picked up',
          ),
        );
      }

      // 5. Accepted by driver
      if (isAccepted && respondedOn != null) {
        activities.add(
          ShippingActivityModel(
            title: 'Accepted by driver: $dName',
            timestamp: formatIso(respondedOn),
            description: 'Driver App · Accepted',
          ),
        );
      }

      // 6. Driver assigned
      if (assignedOn != null) {
        activities.add(
          ShippingActivityModel(
            title: 'Driver assigned: $dName',
            timestamp: formatIso(assignedOn),
            description: 'Assigned by $assignedBy · Admin',
          ),
        );
      }

      final historyList = data is Map ? data['history'] : null;
      if (historyList is List && historyList.isNotEmpty) {
        for (final h in historyList) {
          if (h is Map) {
            final hResp = h['acceptedtime'] ??
                h['accepted_time'] ??
                h['respondedon'] ??
                h['responded_on'];
            final hAssigned = h['assignedtime'] ??
                h['assigned_time'] ??
                h['assignedon'] ??
                h['assigned_on'];
            final hPick = h['pickeduptime'] ??
                h['picked_up_time'] ??
                h['pickuptime'] ??
                h['pickup_time'] ??
                h['pickedon'] ??
                h['picked_on'];
            final hInTransit = h['intransittime'] ??
                h['in_transit_time'] ??
                h['transittime'] ??
                h['transit_time'];
            final hOutForDelivery = h['outfordeliverytime'] ??
                h['out_for_delivery_time'] ??
                h['outdeliverytime'];
            final hDelivered = h['deliveredtime'] ??
                h['delivered_time'] ??
                h['deliveredon'] ??
                h['closedon'];
            final hBy = (h['assignedby'] ?? h['assigned_by'] ?? 'Admin')
                .toString()
                .trim();
            final hDriver = (h['drivername'] ?? h['name'] ?? dName)
                .toString()
                .trim();
            final hState = (h['state'] ?? h['status'] ?? '')
                .toString()
                .toLowerCase();

            if ((hState == 'delivered' || hDelivered != null) &&
                deliveredOn == null &&
                !activities.any((a) => a.title.toLowerCase().contains('deliver'))) {
              activities.add(
                ShippingActivityModel(
                  title: 'Delivered',
                  timestamp: formatIso(hDelivered ?? hOutForDelivery ?? hPick ?? hResp ?? hAssigned),
                  description: 'Order delivered successfully · Driver App',
                ),
              );
            }

            if ((hState == 'out_for_delivery' || hState.contains('out') || hOutForDelivery != null) &&
                outForDeliveryOn == null &&
                !activities.any((a) => a.title.toLowerCase().contains('out'))) {
              activities.add(
                ShippingActivityModel(
                  title: 'Out for Delivery',
                  timestamp: formatIso(hOutForDelivery ?? hInTransit ?? hPick ?? hResp ?? hAssigned),
                  description: 'Reaching customer location · Driver App',
                ),
              );
            }

            if ((hState == 'in_transit' || hState.contains('transit') || hInTransit != null) &&
                inTransitOn == null &&
                !activities.any((a) => a.title.toLowerCase().contains('transit'))) {
              activities.add(
                ShippingActivityModel(
                  title: 'In Transit',
                  timestamp: formatIso(hInTransit ?? hPick ?? hResp ?? hAssigned),
                  description: 'On the way to delivery location · Driver App',
                ),
              );
            }

            if ((hState == 'picked_up' || hState.contains('pick')) &&
                hPick != null &&
                pickedUpOn == null &&
                !activities.any((a) => a.title.toLowerCase().contains('pick'))) {
              activities.add(
                ShippingActivityModel(
                  title: 'Driver picked up: $hDriver',
                  timestamp: formatIso(hPick),
                  description: 'Driver App · Picked up',
                ),
              );
            }
            if (hState == 'accepted' &&
                hResp != null &&
                respondedOn == null &&
                !activities.any((a) => a.title.toLowerCase().contains('accepted'))) {
              activities.add(
                ShippingActivityModel(
                  title: 'Accepted by driver: $hDriver',
                  timestamp: formatIso(hResp),
                  description: 'Driver App · Accepted',
                ),
              );
            }
            if (hAssigned != null &&
                assignedOn == null &&
                !activities.any((a) => a.title.toLowerCase().contains('assigned'))) {
              activities.add(
                ShippingActivityModel(
                  title: 'Driver assigned: $hDriver',
                  timestamp: formatIso(hAssigned),
                  description: 'Assigned by $hBy · Admin',
                ),
              );
            }
          }
        }
      }

      if (activities.isEmpty) {
        activities.add(
          ShippingActivityModel(
            title: 'Driver assigned: $dName',
            timestamp: assignedOn != null ? formatIso(assignedOn) : 'Today',
            description: 'Assigned by $assignedBy · Admin',
          ),
        );
      }

      shippingActivities.assignAll(activities);
    }
  }

  Future<void> fetchAssignmentDetails({String? orderKeyParam}) async {
    final String keyToUse =
        (orderKeyParam != null && orderKeyParam.trim().isNotEmpty)
        ? orderKeyParam.trim()
        : orderKey.value.trim();
    if (keyToUse.isEmpty) return;

    try {
      final res = await _orderService.checkAssignmentStatus(orderKey: keyToUse);
      if (res != null) {
        _applyAssignmentData(res);
      }
    } catch (e) {
      print('[OrderDetailsController.fetchAssignmentDetails] error: $e');
    }
  }

  Future<void> _checkDriverAcceptance(
    String driverId,
    ShippingDriverModel driver,
  ) async {
    String orderKeyToCheck = (driverAssignmentKeys[driverId] ?? '').trim();
    if (orderKeyToCheck.isEmpty) {
      orderKeyToCheck = orderKey.value.trim();
    }
    if (orderKeyToCheck.isEmpty) {
      print('[CheckDriverAcceptance] No orderkey found for $driverId');
      return;
    }

    driverIsCheckingStatus[driverId] = true;

    try {
      final res = await _orderService.checkAssignmentStatus(
        orderKey: orderKeyToCheck,
      );

      print('=== CHECK ASSIGNMENT STATUS RESPONSE ===');
      print(res);
      print('========================================');

      final dynamic data = (res != null && res['data'] is Map)
          ? res['data']
          : res;

      final dynamic currentMap = (data is Map && data['current'] is Map)
          ? data['current']
          : ((res is Map && res!['current'] is Map) ? res['current'] : null);

      final String state =
          (currentMap?['state'] ??
                  currentMap?['status'] ??
                  data?['state'] ??
                  data?['status'] ??
                  data?['orderstatus'] ??
                  data?['assignmentstatus'] ??
                  res?['state'] ??
                  res?['status'] ??
                  res?['orderstatus'] ??
                  '')
              .toString()
              .toLowerCase()
              .trim();

      final bool isAccepted =
          state == 'accepted' ||
          state == 'order_accepted' ||
          state == 'driver_accepted' ||
          currentMap?['is_accepted'] == true ||
          currentMap?['accepted'] == true ||
          data?['is_accepted'] == true ||
          data?['accepted'] == true ||
          res?['is_accepted'] == true ||
          res?['accepted'] == true;

      if (isAccepted) {
        driverHasAccepted[driverId] = true;
        final acceptedDriverName =
            (currentMap is Map &&
                currentMap['drivername'] != null &&
                currentMap['drivername'].toString().trim().isNotEmpty)
            ? currentMap['drivername'].toString().trim()
            : driver.name;
        assignedDriverName.value = acceptedDriverName;

        if (currentMap is Map) {
          if (currentMap['phone'] != null) {
            assignedDriverPhone.value = currentMap['phone'].toString().trim();
          } else if (driver.phone != null) {
            assignedDriverPhone.value = driver.phone!;
          }

          if (currentMap['vehicle'] is Map) {
            final v = currentMap['vehicle'];
            final vName = v['name']?.toString().trim() ?? '';
            final vReg =
                v['registrationnumber']?.toString().trim() ??
                v['reg_number']?.toString().trim() ??
                '';
            final vType = v['type']?.toString().trim() ?? '';
            assignedDriverVehicle.value = [
              if (vName.isNotEmpty) vName else if (vType.isNotEmpty) vType,
              if (vReg.isNotEmpty) vReg,
            ].join(' · ');
          } else if (driver.vehicle != null) {
            assignedDriverVehicle.value = driver.vehicle!;
          }
        } else {
          if (driver.phone != null) assignedDriverPhone.value = driver.phone!;
          if (driver.vehicle != null)
            assignedDriverVehicle.value = driver.vehicle!;
        }

        currentShippingStep.value = 1; // Switch to 'Driver assigned'
        shipmentStatus.value = shippingSteps[1];

        if (Get.isRegistered<OrderController>()) {
          Get.find<OrderController>().syncOrderUpdates(
            orderKey: orderKey.value,
            orderId: orderId.value,
            orderStatus: orderStatus.value,
            shippingStatus: shipmentStatus.value,
            paymentStatus: paymentMethod.value,
          );
        }

        Get.snackbar(
          'Driver Accepted',
          '$acceptedDriverName has accepted the order!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      } else {
        // Driver did not accept yet
        driverHasAccepted[driverId] = false;
        assignedDriverName.value = '';
        final int attemptsUsed = driverAssignClickCount[driverId] ?? 0;
        if (attemptsUsed >= 3) {
          Get.snackbar(
            'Driver Did Not Accept',
            '${driver.name} did not accept. Please choose another driver.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFEF4444),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          );
        } else {
          Get.snackbar(
            'Order Not Accepted Yet',
            '${driver.name} has not accepted yet. You can assign again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFF59E0B),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      print('[CheckDriverAcceptance] Error: $e');
    } finally {
      driverIsCheckingStatus[driverId] = false;
    }
  }

  Future<void> assignDriver(ShippingDriverModel driver) async {
    // If an assignment is already in progress, prevent any new driver assignment
    if (isAssigningDriver.value) {
      Get.snackbar(
        'Please Wait',
        'Another driver assignment is in progress. Please wait a moment.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF59E0B),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final String driverId = getDriverIdentifier(driver);
    final int currentClicks = driverAssignClickCount[driverId] ?? 0;

    // If driver already accepted
    if (driverHasAccepted[driverId] == true) {
      Get.snackbar(
        'Already Accepted',
        '${driver.name} has already accepted this order.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // If currently checking acceptance status
    if (driverIsCheckingStatus[driverId] == true) {
      Get.snackbar(
        'Checking Status',
        'Checking if ${driver.name} accepted the order. Please wait a moment.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF59E0B),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // If already clicked 3 times, 4th click shows "Please choose another driver"
    if (currentClicks >= 3) {
      Get.snackbar(
        'Driver Assignment',
        'Please choose another driver',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Cooldown check: admin must wait 30 seconds between clicks
    final int cooldown = driverAssignCooldown[driverId] ?? 0;
    if (cooldown > 0) {
      Get.snackbar(
        'Please Wait',
        'Please wait $cooldown seconds before clicking again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF59E0B),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final String currentOrderKey = orderKey.value.trim();
    if (currentOrderKey.isEmpty) {
      Get.snackbar(
        'Order Key Missing',
        'Cannot assign driver without order key.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final String driverKeyToAssign =
        (driver.driverUserKey ?? driver.driverKey ?? '').trim();
    if (driverKeyToAssign.isEmpty) {
      Get.snackbar(
        'Driver Key Missing',
        'Cannot assign driver: driveruserkey not found.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isAssigningDriver.value = true;
    assigningDriverUserKey.value = driverKeyToAssign;

    try {
      final res = await _orderService.assignDriver(
        orderkey: currentOrderKey,
        driveruserkey: driverKeyToAssign,
        force: false,
        remarks: "Manual assignment from ops portal",
      );

      print('=== ASSIGN DRIVER API RESPONSE ===');
      print(res);
      print('===================================');

      final isSuccess =
          res != null &&
          (res['success'] == true ||
              res['code'] == 200 ||
              res['code'] == '200' ||
              res['status'] == 'success' ||
              res['status'] == true);

      if (isSuccess) {
        // Extract orderkey from assign driver response (as required for dispatch/v1/assignment API)
        final dynamic dataMap = res['data'];
        String extractedOrderKey = '';
        if (dataMap is Map) {
          extractedOrderKey =
              (dataMap['orderkey'] ??
                      dataMap['order_key'] ??
                      dataMap['orderKey'] ??
                      '')
                  .toString()
                  .trim();
        }
        if (extractedOrderKey.isEmpty && res['orderkey'] != null) {
          extractedOrderKey = res['orderkey'].toString().trim();
        }
        if (extractedOrderKey.isEmpty) {
          extractedOrderKey = currentOrderKey.trim();
        }
        if (extractedOrderKey.isNotEmpty) {
          driverAssignmentKeys[driverId] = extractedOrderKey;
        }

        // Call driverOrderPush API as requested upon successful driver assign
        try {
          String resolvedFcmToken =
              'fzS--ip3SqeI4KSEB4yjfn:APA91bEjVnX7a8MUAGQXK3z1fPBcF_iJpkS7dL1hOF_E0joVVKCCU8iKXwkxNrIjpI-xtMlQFKp_JRVeu-VwX-QFYg17VZOzLRY9i4b09IZom6AA_udtrrQ';
          if (resolvedFcmToken.isEmpty && dataMap is Map) {
            resolvedFcmToken =
                (dataMap['fcmtoken'] ??
                        dataMap['fcmToken'] ??
                        dataMap['fcm_token'] ??
                        dataMap['devicetoken'] ??
                        '')
                    .toString()
                    .trim();
          }
          if (resolvedFcmToken.isEmpty && res['fcmtoken'] != null) {
            resolvedFcmToken = res['fcmtoken'].toString().trim();
          }

          final String resolvedOrderKey = extractedOrderKey.isNotEmpty
              ? extractedOrderKey
              : currentOrderKey.trim();
          String resolvedOrderNumber = orderNo.value.trim().replaceAll('#', '');
          if (resolvedOrderNumber.isEmpty ||
              resolvedOrderNumber == '-' ||
              resolvedOrderNumber == 'null') {
            resolvedOrderNumber = (selectedOrder.value?.id ?? '')
                .trim()
                .replaceAll('#', '');
          }
          if (resolvedOrderNumber.isEmpty ||
              resolvedOrderNumber == '-' ||
              resolvedOrderNumber == 'null') {
            resolvedOrderNumber = salesOrderId.value.trim().replaceAll('#', '');
          }
          if ((resolvedOrderNumber.isEmpty ||
                  resolvedOrderNumber == '-' ||
                  resolvedOrderNumber == 'null') &&
              dataMap is Map) {
            resolvedOrderNumber =
                (dataMap['ordernumber'] ??
                        dataMap['order_number'] ??
                        dataMap['salesorder_number'] ??
                        dataMap['salesorder'] ??
                        dataMap['salesorderid'] ??
                        '')
                    .toString()
                    .trim()
                    .replaceAll('#', '');
          }

          print(
            '[OrderDetailsController.assignDriver] Triggering driverOrderPush with fcmtoken: $resolvedFcmToken, orderkey: $resolvedOrderKey, ordernumber: $resolvedOrderNumber',
          );

          if (resolvedFcmToken.isNotEmpty && resolvedOrderKey.isNotEmpty) {
            final pushRes = await _orderService.sendDriverOrderPush(
              fcmtoken: resolvedFcmToken,
              orderkey: resolvedOrderKey,
              ordernumber: resolvedOrderNumber,
            );
            print(
              '[OrderDetailsController.assignDriver] driverOrderPush result: $pushRes',
            );
            if (pushRes != null && pushRes['data'] is Map) {
              final pushOrderKey =
                  (pushRes['data']['orderkey'] ??
                          pushRes['data']['order_key'] ??
                          pushRes['data']['orderKey'] ??
                          '')
                      .toString()
                      .trim();
              if (pushOrderKey.isNotEmpty) {
                driverAssignmentKeys[driverId] = pushOrderKey;
              }
            }
          } else {
            print(
              '[OrderDetailsController.assignDriver] Warning: Skipping driverOrderPush because fcmtoken ($resolvedFcmToken) or orderkey ($resolvedOrderKey) is empty',
            );
          }
        } catch (pushError) {
          print(
            '[OrderDetailsController.assignDriver] Error invoking driverOrderPush: $pushError',
          );
        }

        // Increment the attempt count and start the 30-second wait timer ONLY on success
        final int updatedClicks = (driverAssignClickCount[driverId] ?? 0) + 1;
        driverAssignClickCount[driverId] = updatedClicks;
        _startDriverCooldown(driverId, 30, driver);
      } else {
        final errMsg =
            res?['message']?.toString() ??
            res?['error']?.toString() ??
            'Failed to assign driver.';
        Get.snackbar(
          'Assignment Failed',
          errMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('=== ASSIGN DRIVER ERROR ===');
      print(e);
      print('===========================');
      Get.snackbar(
        'Assignment Error',
        'An error occurred while assigning driver.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isAssigningDriver.value = false;
      assigningDriverUserKey.value = '';
    }
  }

  void setShippingStep(int index) {
    if (index >= 0 && index < shippingSteps.length) {
      currentShippingStep.value = index;
      shipmentStatus.value = shippingSteps[index];
      if (index >= 1 &&
          assignedDriverName.value.isEmpty &&
          drivers.isNotEmpty) {
        final primary =
            drivers.firstWhereOrNull((d) => d.isPrimary) ?? drivers.first;
        assignedDriverName.value = primary.name;
      }

      final dName = assignedDriverName.value.isNotEmpty
          ? assignedDriverName.value
          : 'Driver';
      final now = DateTime.now();
      final hour = now.hour.toString().padLeft(2, '0');
      final min = now.minute.toString().padLeft(2, '0');
      final timeStr = 'Today $hour:$min';

      if (index >= 2) {
        final hasPickup = shippingActivities.any((a) =>
            a.title.toLowerCase().contains('pick') ||
            a.description.toLowerCase().contains('pick'));
        if (!hasPickup) {
          shippingActivities.insert(
            0,
            ShippingActivityModel(
              title: 'Driver picked up: $dName',
              timestamp: pickedUpTime.value.isNotEmpty ? pickedUpTime.value : timeStr,
              description: 'Driver App · Picked up',
            ),
          );
        }
      }
      if (index >= 3) {
        final hasInTransit = shippingActivities.any((a) =>
            a.title.toLowerCase().contains('transit'));
        if (!hasInTransit) {
          shippingActivities.insert(
            0,
            ShippingActivityModel(
              title: 'In Transit',
              timestamp: inTransitTime.value.isNotEmpty ? inTransitTime.value : timeStr,
              description: 'On the way to delivery location · Driver App',
            ),
          );
        }
      }
      if (index >= 4) {
        final hasOutForDelivery = shippingActivities.any((a) =>
            a.title.toLowerCase().contains('out for delivery') ||
            a.title.toLowerCase().contains('out'));
        if (!hasOutForDelivery) {
          shippingActivities.insert(
            0,
            ShippingActivityModel(
              title: 'Out for Delivery',
              timestamp: outForDeliveryTime.value.isNotEmpty ? outForDeliveryTime.value : timeStr,
              description: 'Reaching customer location · Driver App',
            ),
          );
        }
      }
      if (index >= 5) {
        if (deliveredTime.value.isEmpty) {
          final day = now.day.toString().padLeft(2, '0');
          final mon = now.month.toString().padLeft(2, '0');
          deliveredTime.value = '$day-$mon-${now.year} $hour:$min';
        }
        final hasDelivered = shippingActivities.any((a) =>
            a.title.toLowerCase().contains('deliver'));
        if (!hasDelivered) {
          shippingActivities.insert(
            0,
            ShippingActivityModel(
              title: 'Delivered',
              timestamp: deliveredTime.value.isNotEmpty ? deliveredTime.value : timeStr,
              description: 'Order delivered successfully · Driver App',
            ),
          );
        }
      }
    }
  }

  void advanceShippingStatus() {
    if (currentShippingStep.value < 3) {
      currentShippingStep.value = 3; // Switch to 'In transit'
    } else if (currentShippingStep.value < 5) {
      currentShippingStep.value = 5; // Switch to 'Delivered'
    } else {
      currentShippingStep.value = 0; // Switch back to 'Accepted'
    }
    shipmentStatus.value = shippingSteps[currentShippingStep.value];
  }

  final ScrollController leftScrollController = ScrollController();
  final ScrollController rightScrollController = ScrollController();
  final ScrollController driverScrollController = ScrollController();

  @override
  void onClose() {
    _clearDriverTimers();
    leftScrollController.dispose();
    rightScrollController.dispose();
    driverScrollController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    String salesorderId = '';

    final args = Get.arguments;
    if (args is OrderModel) {
      selectedOrder.value = args;
      salesorderId = args.orderkey;
      if (args.id.isNotEmpty && args.id != '-') {
        orderNo.value = args.id;
      }
      if (args.customerName.isNotEmpty && args.customerName != '-') {
        customer.value = formatTitleCase(args.customerName);
      }
      if (args.companyName.isNotEmpty) {
        company.value = args.companyName;
      }
      if (args.channel.isNotEmpty) {
        channel.value = args.channel;
      }
      if (args.paymentStatus.isNotEmpty) {
        paymentMethod.value = args.paymentStatus;
      }
      if (args.orderStatus.isNotEmpty) {
        orderStatus.value = args.orderStatus;
      }
      final lowerOrderStatus = args.orderStatus.toLowerCase().trim();
      final lowerShippingStatus = args.shippingStatus.toLowerCase().trim();
      if (args.shippingStatus.isNotEmpty) {
        shipmentStatus.value = formatTitleCase(args.shippingStatus);
        if (lowerShippingStatus.contains('deliver') &&
            !lowerShippingStatus.contains('out')) {
          currentShippingStep.value = 5;
        } else if (lowerShippingStatus.contains('out')) {
          currentShippingStep.value = 4;
        } else if (lowerShippingStatus.contains('transit')) {
          currentShippingStep.value = 3;
        } else if (lowerShippingStatus.contains('pick')) {
          currentShippingStep.value = 2;
        } else if (lowerShippingStatus == 'accepted' ||
            (lowerShippingStatus.contains('accept') &&
                !lowerShippingStatus.contains('assign'))) {
          currentShippingStep.value = 1;
        } else {
          currentShippingStep.value = 0;
        }

        final isAcceptedShipping = lowerShippingStatus == 'accepted' ||
            (lowerShippingStatus.contains('accept') &&
                !lowerShippingStatus.contains('assign'));
        final k = args.orderkey.isNotEmpty
            ? args.orderkey
            : (args.id.isNotEmpty ? args.id : salesorderId);
        if (k.isNotEmpty &&
            (currentShippingStep.value >= 1 || isAcceptedShipping)) {
          fetchAssignmentDetails(orderKeyParam: k);
        }
      } else {
        currentShippingStep.value = 0;
      }
      if (lowerOrderStatus == 'accepted' ||
          lowerOrderStatus == 'confirmed' ||
          lowerOrderStatus == 'approved' ||
          lowerOrderStatus == 'open' ||
          lowerOrderStatus == 'invoiced' ||
          lowerShippingStatus == 'packed' ||
          lowerShippingStatus == 'dispatched' ||
          lowerShippingStatus == 'shipped' ||
          lowerShippingStatus.contains('transit') ||
          lowerShippingStatus.contains('deliver')) {
        isOrderAccepted.value = true;
      }
      if (args.amount.isNotEmpty) {
        grandTotal.value = _formatPriceVal(args.amount);
      }
      if (args.date.isNotEmpty && args.date != '-') {
        date.value = formatDateOnly(args.date);
        time.value = formatDateOnly(args.date);
      }
    } else if (args is String) {
      salesorderId = args;
    } else if (Get.parameters.containsKey('orderkey')) {
      salesorderId = Get.parameters['orderkey'] ?? '';
    } else if (Get.parameters.containsKey('id')) {
      salesorderId = Get.parameters['id'] ?? '';
    }

    if (salesorderId.startsWith('#')) {
      salesorderId = salesorderId.substring(1);
    }

    salesorderId = salesorderId.trim();

    if (salesorderId.isNotEmpty) {
      fetchOrderDetails(salesorderId);
    } else {
      _redirectToOrderList('Order key not found');
    }
    debounce(driverSearchQuery, (_) {
      if (orderKey.value.trim().isNotEmpty) {
        fetchDrivers();
      }
    }, time: const Duration(milliseconds: 400));
  }

  bool _isRedirecting = false;

  void _redirectToOrderList([String? message]) {
    if (_isRedirecting) return;
    _isRedirecting = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.currentRoute != '/orders') {
        Get.offAllNamed('/orders');
      }
      if (message != null && message.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 300), () {
          // Get.snackbar(
          //   'Order Not Found',
          //   message,
          //   snackPosition: SnackPosition.BOTTOM,
          //   backgroundColor: const Color(0xFFEF4444),
          //   colorText: Colors.white,
          //   margin: const EdgeInsets.all(16),
          //   duration: const Duration(seconds: 3),
          // );
        });
      }
    });
  }

  Future<void> refreshOrderDetails() async {
    if (isRefreshingPage.value) return;

    final String k = orderKey.value.trim().isNotEmpty
        ? orderKey.value.trim()
        : (salesOrderId.value.trim().isNotEmpty
            ? salesOrderId.value.trim()
            : (orderNo.value.trim().isNotEmpty ? orderNo.value.trim() : ''));

    if (k.isEmpty) {
      Get.snackbar(
        'Refresh',
        'Order key not found to refresh',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF59E0B),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    isRefreshingPage.value = true;
    try {
      await fetchOrderDetails(k);
      await fetchDrivers(orderKeyParam: k);
      await fetchAssignmentDetails(orderKeyParam: k);

      if (Get.isRegistered<OrderController>()) {
        Get.find<OrderController>().fetchOrders();
      }

      Get.snackbar(
        'Refreshed',
        'Order details refreshed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Refresh Error',
        'Failed to refresh: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    } finally {
      isRefreshingPage.value = false;
    }
  }

  Future<void> fetchOrderDetails(String salesorderId) async {
    //print("salesorderId...$salesorderId");
    final cleanId = salesorderId.trim();
    if (cleanId.isEmpty) {
      _redirectToOrderList('Order key not found');
      return;
    }

    orderKey.value = cleanId;
    isLoading.value = true;
    isError.value = false;
    isInvoiceDownloaded.value = false;
    _clearDriverTimers();
    driverAssignClickCount.clear();

    try {
      final responseMap = await _orderService.getOrderDetails(
        orderKey: cleanId,
      );
      if (responseMap != null) {
        final isSuccess = responseMap['success'] ?? responseMap['status'];
        final message =
            (responseMap['message'] ??
                    responseMap['error'] ??
                    responseMap['msg'] ??
                    '')
                .toString();

        if (isSuccess == false ||
            isSuccess == 0 ||
            message.toLowerCase().contains('not found') ||
            message.toLowerCase().contains('invalid') ||
            message.toLowerCase().contains('no order')) {
          isError.value = true;
          _redirectToOrderList(
            message.isNotEmpty ? message : 'Order not found for key: $cleanId',
          );
          return;
        }

        _populateFromApiResponse(responseMap);
        fetchDrivers(orderKeyParam: orderKey.value);

        final lowerShip = shipmentStatus.value.toLowerCase().trim();
        final isAcceptedShip = lowerShip == 'accepted' ||
            (lowerShip.contains('accept') && !lowerShip.contains('assign'));
        if (isAcceptedShip || currentShippingStep.value >= 1) {
          fetchAssignmentDetails(orderKeyParam: orderKey.value);
        }

        if (orderNo.value.isEmpty && orderItems.isEmpty) {
          isError.value = true;
          _redirectToOrderList('Order not found for key: $cleanId');
          return;
        }
      } else {
        isError.value = true;
        _redirectToOrderList('Order not found for key: $cleanId');
      }
    } catch (e) {
      // if (kDebugMode) {
      //   debugPrint('[OrderDetailsController] Error fetching details: $e');
      // }
      isError.value = true;
      _redirectToOrderList('Failed to load order details');
    } finally {
      isLoading.value = false;
    }
  }

  /// Deeply drills down into response map to find the map containing actual order data
  Map<String, dynamic> _extractTargetOrderMap(
    Map<String, dynamic> responseMap,
  ) {
    // if (kDebugMode) {
    //   debugPrint('[OrderDetailsController] Raw responseMap: $responseMap');
    // }

    Map<String, dynamic> current = responseMap;

    for (int i = 0; i < 5; i++) {
      if (current.containsKey('salesorder_number') ||
          current.containsKey('customer_name') ||
          current.containsKey('line_items') ||
          current.containsKey('salesorder_id') ||
          current.containsKey('paid_status')) {
        return current;
      }

      if (current.containsKey('salesorder') &&
          current['salesorder'] is Map<String, dynamic>) {
        current = Map<String, dynamic>.from(current['salesorder']);
        continue;
      }
      if (current.containsKey('sales_order') &&
          current['sales_order'] is Map<String, dynamic>) {
        current = Map<String, dynamic>.from(current['sales_order']);
        continue;
      }
      if (current.containsKey('data') &&
          current['data'] is Map<String, dynamic>) {
        current = Map<String, dynamic>.from(current['data']);
        continue;
      }
      if (current.containsKey('result') &&
          current['result'] is Map<String, dynamic>) {
        current = Map<String, dynamic>.from(current['result']);
        continue;
      }
      if (current.containsKey('order') &&
          current['order'] is Map<String, dynamic>) {
        current = Map<String, dynamic>.from(current['order']);
        continue;
      }
      if (current.containsKey('data') &&
          current['data'] is List &&
          (current['data'] as List).isNotEmpty &&
          (current['data'] as List)[0] is Map) {
        current = Map<String, dynamic>.from((current['data'] as List)[0]);
        continue;
      }
      break;
    }

    return current;
  }

  void _populateFromApiResponse(Map<String, dynamic> responseMap) {
    final data = _extractTargetOrderMap(responseMap);

    final rawOrderId =
        data['orderid'] ??
        data['salesorderid'] ??
        data['salesorder_id'] ??
        data['order_id'] ??
        data['id'];
    if (rawOrderId != null && rawOrderId.toString().trim().isNotEmpty) {
      orderId.value = rawOrderId.toString().trim();
    }

    final rawOrderKey =
        data['orderkey'] ??
        data['order_key'] ??
        (responseMap['data'] is Map ? responseMap['data']['orderkey'] : null) ??
        responseMap['orderkey'];
    if (rawOrderKey != null &&
        rawOrderKey.toString().trim().isNotEmpty &&
        rawOrderKey.toString().trim() != 'null') {
      orderKey.value = rawOrderKey.toString().trim();
    }

    final rawSalesOrderId =
        data['salesorderid'] ??
        data['salesorder_id'] ??
        data['sales_order_id'] ??
        data['sales_orderid'] ??
        data['zoho_salesorder_id'] ??
        data['zoho_salesorderid'] ??
        data['zoho_order_id'] ??
        data['zoho_orderid'] ??
        responseMap['salesorderid'] ??
        responseMap['salesorder_id'] ??
        (responseMap['salesorder'] is Map
            ? responseMap['salesorder']['salesorder_id'] ??
                  responseMap['salesorder']['salesorderid']
            : null) ??
        (responseMap['data'] is Map
            ? responseMap['data']['salesorderid'] ??
                  responseMap['data']['salesorder_id'] ??
                  responseMap['data']['sales_order_id']
            : null);
    if (rawSalesOrderId != null &&
        rawSalesOrderId.toString().trim().isNotEmpty &&
        rawSalesOrderId.toString().trim() != 'null') {
      salesOrderId.value = rawSalesOrderId.toString().trim();
    } else if (orderKey.value.isNotEmpty &&
        int.tryParse(orderKey.value) != null) {
      salesOrderId.value = orderKey.value.trim();
    }

    final rawCustomerId = data['customerid'] ?? data['customer_id'];
    if (rawCustomerId != null && rawCustomerId.toString().trim().isNotEmpty) {
      customerId.value = rawCustomerId.toString().trim();
    }

    // 1. Summary details (if key is missing, make blank "")
    final num =
        data['ordernumber'] ??
        data['order_number'] ??
        data['salesorder_number'] ??
        data['salesorder_no'] ??
        data['salesorderid'] ??
        data['orderkey'] ??
        data['order_id'] ??
        data['id'];

    if (num != null && num.toString().trim().isNotEmpty) {
      final numStr = num.toString().trim();
      orderNo.value = numStr;
    } else {
      orderNo.value = '';
    }

    final dateVal = data['createdtime'];
    date.value = dateVal != null ? formatDateOnly(dateVal.toString()) : '';

    final timeVal = data['createdtime'];
    time.value = timeVal != null ? formatDateOnly(timeVal.toString()) : '';

    customer.value = formatTitleCase(
      (data['customername'] ??
                  data['customer_name'] ??
                  data['customerName'] ??
                  data['customer'] ??
                  data['name'])
              ?.toString() ??
          '',
    );

    // 2. Shipping Address (if key missing -> blank "")
    final shipMap =
        data['shiptoaddress'] ??
        data['shipping_address'] ??
        data['shippingAddress'] ??
        data['shipping'] ??
        data['delivery_address'];

    company.value =
        (data['company_name'] ??
                data['companyName'] ??
                data['company'] ??
                data['restaurant_name'] ??
                data['restaurantname'] ??
                data['resturentname'] ??
                (shipMap is Map ? shipMap['company_name'] : null))
            ?.toString() ??
        '';

    final rawChannel =
        data['channel'] ??
        data['channel_name'] ??
        data['channelName'] ??
        data['sales_channel'];
    if (rawChannel != null &&
        rawChannel.toString().trim().isNotEmpty &&
        rawChannel.toString().trim() != 'null') {
      channel.value = rawChannel.toString().trim();
    } else {
      channel.value = '';
    }

    paymentMethod.value =
        (data['paymentstatus'] ??
                data['paid_status'] ??
                data['payment_status'] ??
                data['payment_mode'] ??
                data['payment_method'] ??
                data['payment'])
            ?.toString() ??
        '';

    final rawOrderStat =
        (data['orderstatus'] ??
                data['order_status'] ??
                data['salesorder_status'] ??
                data['status'])
            ?.toString()
            .trim();
    orderStatus.value =
        (rawOrderStat != null &&
            rawOrderStat.isNotEmpty &&
            rawOrderStat != 'null')
        ? rawOrderStat
        : 'Pending';

    final rawShipping = (data['shippingstatus'] ??
            data['shipping_status'] ??
            data['shipped_status'])
        ?.toString()
        .trim();
    if (rawShipping != null &&
        rawShipping.isNotEmpty &&
        rawShipping != 'null') {
      shipmentStatus.value = formatTitleCase(rawShipping);
    } else {
      shipmentStatus.value = 'Pending';
    }
    final lowerShipStatus = shipmentStatus.value.toLowerCase().trim();
    final lowerOrderStatus = orderStatus.value.toLowerCase().trim();
    if (lowerShipStatus.contains('deliver') &&
        !lowerShipStatus.contains('out')) {
      currentShippingStep.value = 5;
    } else if (lowerShipStatus.contains('out')) {
      currentShippingStep.value = 4;
    } else if (lowerShipStatus.contains('transit')) {
      currentShippingStep.value = 3;
    } else if (lowerShipStatus.contains('pick')) {
      currentShippingStep.value = 2;
    } else if (lowerShipStatus == 'accepted' ||
        (lowerShipStatus.contains('accept') &&
            !lowerShipStatus.contains('assign'))) {
      currentShippingStep.value = 1;
    } else {
      // When shipment status is 'assigned', 'pending', etc., green dot stays on 'Accepted' (step 0)
      currentShippingStep.value = 0;
    }

    final isAcceptedShip = lowerShipStatus == 'accepted' ||
        (lowerShipStatus.contains('accept') &&
            !lowerShipStatus.contains('assign'));
    final k = orderKey.value.trim();
    if (k.isNotEmpty && (isAcceptedShip || currentShippingStep.value >= 1)) {
      fetchAssignmentDetails(orderKeyParam: k);
    }

    if (shipMap is Map) {
      shippingName.value = formatTitleCase(
        (shipMap['attention'] ??
                    shipMap['name'] ??
                    shipMap['customer_name'] ??
                    shipMap['recipient_name'] ??
                    data['customername'] ??
                    data['customer_name'])
                ?.toString() ??
            '',
      );
      shippingPhone.value =
          (shipMap['phone'] ??
                  shipMap['mobile'] ??
                  shipMap['contact'] ??
                  data['mobilenumber'] ??
                  data['phonenumber'])
              ?.toString() ??
          '';
      shippingAddress.value = _buildAddressString(shipMap);
      shippingPincode.value =
          (shipMap['zip'] ??
                  shipMap['pincode'] ??
                  shipMap['zip_code'] ??
                  shipMap['postal_code'] ??
                  data['pincode'])
              ?.toString() ??
          '';
    } else if (shipMap is String) {
      shippingAddress.value = shipMap;
      shippingName.value = '';
      shippingPhone.value = '';
      shippingPincode.value = '';
    } else {
      shippingName.value = data['customername'] != null
          ? formatTitleCase(data['customername'].toString())
          : '';
      shippingPhone.value = data['mobilenumber']?.toString() ?? '';
      shippingAddress.value = '';
      shippingPincode.value = data['pincode']?.toString() ?? '';
    }

    // 3. Billing Address (if key missing -> blank "")
    final billMap =
        data['billtoaddress'] ??
        data['billing_address'] ??
        data['billingAddress'] ??
        data['billing'];
    if (billMap is Map) {
      billingName.value = formatTitleCase(
        (billMap['attention'] ??
                    billMap['name'] ??
                    billMap['customer_name'] ??
                    data['customername'] ??
                    data['customer_name'])
                ?.toString() ??
            '',
      );
      billingPhone.value =
          (billMap['phone'] ??
                  billMap['mobile'] ??
                  billMap['contact'] ??
                  data['mobilenumber'] ??
                  data['phonenumber'])
              ?.toString() ??
          '';
      billingAddress.value = _buildAddressString(billMap);
      billingPincode.value =
          (billMap['zip'] ??
                  billMap['pincode'] ??
                  billMap['zip_code'] ??
                  billMap['postal_code'] ??
                  data['pincode'])
              ?.toString() ??
          '';
    } else if (billMap is String) {
      billingAddress.value = billMap;
      billingName.value = '';
      billingPhone.value = '';
      billingPincode.value = '';
    } else {
      billingName.value = data['customername'] != null
          ? formatTitleCase(data['customername'].toString())
          : '';
      billingPhone.value = data['mobilenumber']?.toString() ?? '';
      billingAddress.value = '';
      billingPincode.value = data['pincode']?.toString() ?? '';
    }

    if (currentShippingStep.value >= 1 || isAcceptedShip) {
      final assignedDriver =
          data['driver'] ?? data['assigned_driver'] ?? data['driver_details'];
      if (assignedDriver is Map) {
        final name =
            (assignedDriver['name'] ??
                    assignedDriver['drivername'] ??
                    assignedDriver['driver_name'])
                ?.toString();
        if (name != null && name.trim().isNotEmpty) {
          assignedDriverName.value = name.trim();
        }
        final phone =
            (assignedDriver['phone'] ??
                    assignedDriver['mobile'] ??
                    assignedDriver['mobilenumber'])
                ?.toString();
        if (phone != null && phone.trim().isNotEmpty) {
          assignedDriverPhone.value = phone.trim();
        }
        final vehicle = assignedDriver['vehicle'];
        if (vehicle is Map) {
          final vName =
              (vehicle['name'] ?? vehicle['model'] ?? vehicle['vehiclename'])
                  ?.toString()
                  .trim() ??
              '';
          final vReg =
              (vehicle['registrationnumber'] ??
                      vehicle['registration_number'] ??
                      vehicle['number'])
                  ?.toString()
                  .trim() ??
              '';
          final vType = vehicle['type']?.toString().trim() ?? '';
          assignedDriverVehicle.value = [
            if (vName.isNotEmpty) vName else if (vType.isNotEmpty) vType,
            if (vReg.isNotEmpty) vReg,
          ].join(' · ');
        }
      } else if (data['drivername'] != null || data['driver_name'] != null) {
        final name = (data['drivername'] ?? data['driver_name'])?.toString();
        if (name != null && name.trim().isNotEmpty) {
          assignedDriverName.value = formatTitleCase(name.trim());
        }
        final phone = (data['driverphone'] ?? data['driver_phone'])?.toString();
        if (phone != null && phone.trim().isNotEmpty) {
          assignedDriverPhone.value = phone.trim();
        }
      }
    } else {
      assignedDriverName.value = '';
      assignedDriverPhone.value = '';
      assignedDriverVehicle.value = '';
      pickedUpTime.value = '';
      inTransitTime.value = '';
      outForDeliveryTime.value = '';
      deliveredTime.value = '';
      shippingActivities.clear();
    }

    // 4. Price Breakdown (if key missing -> blank "")
    double calculatedSubtotal = 0.0;
    final itemsRaw =
        data['items'] ??
        data['line_items'] ??
        data['order_items'] ??
        data['products'];
    if (itemsRaw is List) {
      for (final item in itemsRaw) {
        if (item is Map) {
          final itemTot =
              double.tryParse(
                (item['item_sub_total'] ??
                        item['item_total'] ??
                        item['total'] ??
                        item['rate'] ??
                        '0')
                    .toString(),
              ) ??
              0.0;
          calculatedSubtotal += itemTot;
        }
      }
    }

    final rawSubtotal =
        data['sub_total'] ??
        data['subtotal'] ??
        data['item_sub_total'] ??
        data['sub_total_inclusive_of_tax'];
    if (rawSubtotal != null &&
        rawSubtotal.toString().trim().isNotEmpty &&
        rawSubtotal.toString().trim() != 'null') {
      subtotal.value = _formatPriceVal(rawSubtotal);
    } else if (calculatedSubtotal > 0) {
      subtotal.value = _formatPriceVal(calculatedSubtotal);
    } else {
      subtotal.value = '';
    }

    shippingFee.value = _formatPriceVal(data['shippingcharge']);
    platformFee.value = _formatPriceVal(
      data['platform_fee'] ?? data['platform_charge'],
    );

    // Calculate bankFee by summing bankcharges from payments array
    double totalBankCharges = 0.0;
    bool foundBankChargesInPayments = false;
    final paymentsList = data['payments'];
    if (paymentsList is List && paymentsList.isNotEmpty) {
      for (final p in paymentsList) {
        if (p is Map) {
          final val = p['bankcharges'];
          if (val != null) {
            final cleanStr = val
                .toString()
                .replaceAll('₹', '')
                .replaceAll(',', '')
                .replaceAll(RegExp(r'\s+'), '')
                .trim();
            final parsed = double.tryParse(cleanStr);
            if (parsed != null) {
              totalBankCharges += parsed;
              foundBankChargesInPayments = true;
            }
          }
        }
      }
    }

    if (foundBankChargesInPayments) {
      bankFee.value = _formatPriceVal(totalBankCharges);
    } else {
      bankFee.value = _formatPriceVal(data['bankcharges']);
    }

    discountPercent.value = _formatPriceVal(
      data['discount'] ?? data['discount_total'] ?? data['discount_amount'],
    );
    couponDiscount.value = _formatPriceVal(data['coupondiscount']);
    if (data['coupon_code'] != null || data['coupon_name'] != null) {
      couponCode.value = (data['coupon_code'] ?? data['coupon_name'])
          .toString();
    }
    tax.value = _formatPriceVal(data['taxamount']);

    // Tax breakdown from taxes array, line_item_taxes, or line items
    double calculatedCgst = 0.0;
    double calculatedSgst = 0.0;
    double calculatedIgst = 0.0;
    bool foundCgstInTaxes = false;
    bool foundSgstInTaxes = false;
    bool foundIgstInTaxes = false;

    void processTaxMap(Map t) {
      final taxSpecificType = (t['tax_specific_type'] ?? '')
          .toString()
          .toLowerCase()
          .trim();
      final taxName =
          (t['tax_name'] ?? t['name'] ?? t['tax_type'] ?? t['tax_label'] ?? '')
              .toString()
              .toUpperCase();
      final amtVal =
          t['tax_amount_formatted'] ??
          t['tax_amount'] ??
          t['amount'] ??
          t['val'];
      double amt = 0.0;
      if (amtVal != null) {
        final cleanStr = amtVal
            .toString()
            .replaceAll('₹', '')
            .replaceAll(',', '')
            .replaceAll(RegExp(r'\s+'), '')
            .trim();
        amt = double.tryParse(cleanStr) ?? 0.0;
      }

      if (taxSpecificType == 'cgst' || taxName.contains('CGST')) {
        calculatedCgst += amt;
        foundCgstInTaxes = true;
      } else if (taxSpecificType == 'sgst' || taxName.contains('SGST')) {
        calculatedSgst += amt;
        foundSgstInTaxes = true;
      } else if (taxSpecificType == 'igst' || taxName.contains('IGST')) {
        calculatedIgst += amt;
        foundIgstInTaxes = true;
      }
    }

    final topTaxes = data['taxes'];
    if (topTaxes is List && topTaxes.isNotEmpty) {
      for (final t in topTaxes) {
        if (t is Map) processTaxMap(t);
      }
    } else {
      final rawItems =
          data['line_items'] ??
          data['order_items'] ??
          data['items'] ??
          data['products'];
      if (rawItems is List && rawItems.isNotEmpty) {
        for (final item in rawItems) {
          if (item is Map) {
            final itemTaxes =
                item['line_item_taxes'] ?? item['item_taxes'] ?? item['taxes'];
            if (itemTaxes is List && itemTaxes.isNotEmpty) {
              for (final t in itemTaxes) {
                if (t is Map) processTaxMap(t);
              }
            }
          }
        }
      }
    }

    final directCgst =
        data['cgst'] ??
        data['cgst_amount'] ??
        data['cgst_total'] ??
        data['cgst_tax_amount'];
    final directSgst =
        data['sgst'] ??
        data['sgst_amount'] ??
        data['sgst_total'] ??
        data['sgst_tax_amount'];
    final directIgst =
        data['igst'] ??
        data['igst_amount'] ??
        data['igst_total'] ??
        data['igst_tax_amount'];

    if (foundCgstInTaxes || calculatedCgst > 0) {
      cgst.value = _formatPriceVal(calculatedCgst);
    } else if (directCgst != null &&
        directCgst.toString().trim().isNotEmpty &&
        directCgst.toString().trim() != 'null' &&
        directCgst.toString().trim() != '-') {
      cgst.value = _formatPriceVal(directCgst);
    } else {
      cgst.value = '';
    }

    if (foundSgstInTaxes || calculatedSgst > 0) {
      sgst.value = _formatPriceVal(calculatedSgst);
    } else if (directSgst != null &&
        directSgst.toString().trim().isNotEmpty &&
        directSgst.toString().trim() != 'null' &&
        directSgst.toString().trim() != '-') {
      sgst.value = _formatPriceVal(directSgst);
    } else {
      sgst.value = '';
    }

    if (foundIgstInTaxes || calculatedIgst > 0) {
      igst.value = _formatPriceVal(calculatedIgst);
    } else if (directIgst != null &&
        directIgst.toString().trim().isNotEmpty &&
        directIgst.toString().trim() != 'null' &&
        directIgst.toString().trim() != '-') {
      igst.value = _formatPriceVal(directIgst);
    } else {
      igst.value = '';
    }

    grandTotal.value = _formatPriceVal(data['finalamount']);

    // Extract dueamount & paidamount directly from API data
    if (data.containsKey('dueamount') ||
        data.containsKey('due_amount') ||
        data.containsKey('dueAmount')) {
      final rawDue =
          data['dueamount'] ?? data['due_amount'] ?? data['dueAmount'];
      if (rawDue != null) {
        final cleanDue = rawDue
            .toString()
            .replaceAll('₹', '')
            .replaceAll('\$', '')
            .replaceAll(',', '')
            .trim();
        final parsedDue = double.tryParse(cleanDue);
        if (parsedDue != null) {
          dueAmount.value = parsedDue;
          hasExplicitDueAmount.value = true;
        }
      }
    } else {
      hasExplicitDueAmount.value = false;
    }

    if (data.containsKey('paidamount') ||
        data.containsKey('paid_amount') ||
        data.containsKey('paidAmount')) {
      final rawPaid =
          data['paidamount'] ?? data['paid_amount'] ?? data['paidAmount'];
      if (rawPaid != null) {
        final cleanPaid = rawPaid
            .toString()
            .replaceAll('₹', '')
            .replaceAll('\$', '')
            .replaceAll(',', '')
            .trim();
        final parsedPaid = double.tryParse(cleanPaid);
        if (parsedPaid != null) {
          paidAmount.value = parsedPaid;
        }
      }
    }

    // Extract invoice_id & invoice_number from data['invoices'] list or top-level keys
    invoiceId.value = '';
    invoiceNumber.value = '';

    final invoicesList = data['invoices'];
    if (invoicesList is List && invoicesList.isNotEmpty) {
      for (final inv in invoicesList) {
        if (inv is Map) {
          if (!hasExplicitDueAmount.value &&
              (inv.containsKey('dueamount') || inv.containsKey('due_amount'))) {
            final rawDue = inv['dueamount'] ?? inv['due_amount'];
            if (rawDue != null) {
              final parsedDue = double.tryParse(
                rawDue
                    .toString()
                    .replaceAll('₹', '')
                    .replaceAll(',', '')
                    .trim(),
              );
              if (parsedDue != null) {
                dueAmount.value = parsedDue;
                hasExplicitDueAmount.value = true;
              }
            }
          }
          final id = (inv['invoiceid']).toString().trim();
          if (id.isNotEmpty && id != 'null') {
            invoiceId.value = id;
            invoiceNumber.value = (inv['invoicenumber']).toString().trim();
            break;
          }
        }
      }
    } else if (invoicesList is Map) {
      if (!hasExplicitDueAmount.value &&
          (invoicesList.containsKey('dueamount') ||
              invoicesList.containsKey('due_amount'))) {
        final rawDue = invoicesList['dueamount'] ?? invoicesList['due_amount'];
        if (rawDue != null) {
          final parsedDue = double.tryParse(
            rawDue.toString().replaceAll('₹', '').replaceAll(',', '').trim(),
          );
          if (parsedDue != null) {
            dueAmount.value = parsedDue;
            hasExplicitDueAmount.value = true;
          }
        }
      }
      final id = (invoicesList['invoiceid']).toString().trim();
      if (id.isNotEmpty && id != 'null') {
        invoiceId.value = id;
        invoiceNumber.value = (invoicesList['invoicenumber']).toString().trim();
      }
    }

    if (invoiceId.value.isEmpty &&
        data['invoiceid'] != null &&
        data['invoiceid'].toString().trim().isNotEmpty &&
        data['invoiceid'].toString().trim() != 'null') {
      invoiceId.value = data['invoiceid'].toString().trim();
      invoiceNumber.value = (data['invoicenumber']).toString().trim();
    }

    if (invoiceId.value.trim().isNotEmpty && invoiceId.value.trim() != 'null') {
      isInvoiceDownloaded.value = true;
    }

    // 5. Documents (if key missing -> empty list)
    final docsList = data['documents'] ?? data['document_list'] ?? data['docs'];
    final List<DocumentModel> parsedDocs = [];
    if (docsList is List && docsList.isNotEmpty) {
      for (final d in docsList) {
        if (d is Map) {
          parsedDocs.add(
            DocumentModel(
              title:
                  (d['title'] ??
                          d['name'] ??
                          d['type'] ??
                          d['document_type'] ??
                          'Document')
                      .toString(),
              code:
                  (d['code'] ??
                          d['document_number'] ??
                          d['doc_number'] ??
                          d['id'] ??
                          '')
                      .toString(),
            ),
          );
        } else {
          parsedDocs.add(DocumentModel(title: 'Document', code: d.toString()));
        }
      }
    }

    // Ensure 'Invoice' document entry in documents list matches invoiceId / invoiceNumber
    final int existingInvoiceIdx = parsedDocs.indexWhere(
      (doc) => doc.title.toLowerCase().replaceAll(' ', '') == 'invoice',
    );
    final String invoiceCodeToUse = invoiceId.value.isNotEmpty
        ? (invoiceNumber.value.isNotEmpty
              ? invoiceNumber.value
              : invoiceId.value)
        : '';

    if (existingInvoiceIdx != -1) {
      parsedDocs[existingInvoiceIdx] = DocumentModel(
        title: 'Invoice',
        code: invoiceCodeToUse,
      );
    } else {
      parsedDocs.insert(
        0,
        DocumentModel(title: 'Invoice', code: invoiceCodeToUse),
      );
    }

    documents.assignAll(parsedDocs);

    // 6. Payment Transactions (if key missing -> empty list)
    double totalBankFee = 0.0;
    bool hasBankCharges = false;

    final txList = data['payments'];
    if (txList is List && txList.isNotEmpty) {
      transactions.assignAll(
        txList.map((tx) {
          if (tx is Map) {
            final bcRaw = tx['bankcharges'];
            if (bcRaw != null) {
              final cleanStr = bcRaw
                  .toString()
                  .replaceAll('₹', '')
                  .replaceAll(',', '')
                  .replaceAll(RegExp(r'\s+'), '')
                  .trim();
              final parsed = double.tryParse(cleanStr);
              if (parsed != null) {
                totalBankFee += parsed;
                hasBankCharges = true;
              }
            }
            return PaymentTransactionModel(
              issuedBy: (tx['issuedby'] ?? tx['issued_by'] ?? "-").toString(),
              createdOn: formatDateOnly(
                (tx['paymentdate'] ??
                        tx['payment_date'] ??
                        tx['created_on'] ??
                        "-")
                    .toString(),
              ),
              paymentId: (tx['paymentid'] ?? tx['payment_id'] ?? "-")
                  .toString(),
              paymentMethod: (tx['paymentmode'] ?? tx['payment_mode'] ?? "-")
                  .toString(),
              rrnUtr: () {
                final rrn =
                    (tx['transactionref'] ??
                            tx['rrn_utr'] ??
                            tx['rrn'] ??
                            tx['utr'] ??
                            tx['reference_number'] ??
                            "-")
                        .toString()
                        .trim();
                return (rrn.isEmpty || rrn == 'null') ? '-' : rrn;
              }(),
              status:
                  (tx['paymentstatus'] ?? tx['status'] ?? "-")
                          .toString()
                          .trim()
                          .toLowerCase() ==
                      'paid'
                  ? 'Paid'
                  : (tx['paymentstatus'] ?? tx['status'] ?? "-").toString(),
              amount: _formatPriceVal(
                tx['paymentamount'] ?? tx['amount'] ?? "-",
              ),
            );
          }
          return PaymentTransactionModel(
            issuedBy: '',
            createdOn: '',
            paymentId: '',
            paymentMethod: '',
            rrnUtr: '',
            status: '',
            amount: '',
          );
        }).toList(),
      );
    } else {
      transactions.clear();
    }

    if (hasBankCharges) {
      bankFee.value = _formatPriceVal(totalBankFee);
    }

    // 7. Order Items (if key missing -> empty list)
    final itemsList =
        data['line_items'] ??
        data['order_items'] ??
        data['items'] ??
        data['products'];
    if (itemsList is List && itemsList.isNotEmpty) {
      orderItems.assignAll(
        itemsList.map((item) {
          if (item is Map) {
            final qtyVal =
                int.tryParse(
                  item['quantity']?.toString() ??
                      item['qty']?.toString() ??
                      '0',
                ) ??
                0;

            final List<LineItemTaxModel> itemTaxList = [];
            final rawItemTaxes =
                item['line_item_taxes'] ?? item['item_taxes'] ?? item['taxes'];
            if (rawItemTaxes is List && rawItemTaxes.isNotEmpty) {
              for (final t in rawItemTaxes) {
                if (t is Map) {
                  itemTaxList.add(
                    LineItemTaxModel(
                      taxName:
                          (t['tax_name'] ?? t['name'] ?? t['tax_type'] ?? '')
                              .toString(),
                      taxAmount: _formatPriceVal(
                        t['tax_amount'] ?? t['amount'] ?? t['val'],
                      ),
                      taxPercent:
                          double.tryParse(
                            (t['tax_percentage'] ??
                                    t['tax_percent'] ??
                                    t['rate'] ??
                                    '0')
                                .toString(),
                          ) ??
                          0.0,
                    ),
                  );
                }
              }
            }

            final statusStr = (item['status'] ?? item['item_status'] ?? '')
                .toString()
                .toLowerCase();
            final isItemAccepted =
                statusStr == 'accepted' || statusStr == 'approved';
            final isItemRejected =
                statusStr == 'rejected' || statusStr == 'cancelled';

            final rawSku =
                item['sku'] ??
                item['item_sku'] ??
                item['sku_code'] ??
                item['item_code'] ??
                item['hsn_or_sac'] ??
                item['itemid'] ??
                item['item_id'] ??
                '-';
            final skuStr =
                (rawSku.toString().trim().isEmpty ||
                    rawSku.toString().trim() == 'null')
                ? '-'
                : rawSku.toString().trim();

            return OrderItemModel(
              sku: skuStr,
              name: (item['name'] ?? '').toString(),
              itemType: (item['group_name'] ?? '').toString(),
              description: (item['description'] ?? '').toString(),
              price: _formatPriceVal(
                item['rate'] ?? item['price'] ?? item['unit_price'],
              ),
              qty: qtyVal,
              total: _formatPriceVal(
                item['item_total'] ?? item['total'] ?? item['line_total'],
              ),
              lineItemTaxes: itemTaxList,
              initialAccepted: isItemAccepted,
              initialRejected: isItemRejected,
            );
          }
          return OrderItemModel(
            sku: '-',
            name: '',
            itemType: '',
            description: '',
            price: '',
            qty: 0,
            total: '',
          );
        }).toList(),
      );
    } else {
      orderItems.clear();
    }

    final rawOrderStatus = orderStatus.value.trim().toLowerCase();
    final rawShipStatus = shipmentStatus.value.trim().toLowerCase();

    final isDraftOrPendingStatus =
        rawOrderStatus == 'draft' || rawOrderStatus == 'pending';

    final isStatusAccepted =
        !isDraftOrPendingStatus &&
        (rawOrderStatus == 'accepted' ||
            rawOrderStatus == 'confirmed' ||
            rawOrderStatus == 'approved' ||
            rawOrderStatus == 'open' ||
            rawOrderStatus == 'invoiced' ||
            rawOrderStatus == 'fulfilled' ||
            rawShipStatus == 'packed' ||
            rawShipStatus == 'dispatched' ||
            rawShipStatus == 'shipped' ||
            rawShipStatus.contains('transit') ||
            rawShipStatus.contains('deliver'));

    final hasAcceptedItems =
        !isDraftOrPendingStatus &&
        orderItems.isNotEmpty &&
        orderItems.any((item) => item.isAccepted.value);

    final isExplicitlyAccepted =
        !isDraftOrPendingStatus &&
        (data['is_accepted'] == true ||
            data['isAccepted'] == true ||
            data['accepted'] == true);

    final isStatusVoidOrRejected =
        rawOrderStatus == 'void' ||
        rawOrderStatus == 'rejected' ||
        rawOrderStatus == 'cancelled';

    if (isStatusVoidOrRejected) {
      isOrderAccepted.value = false;
      for (final item in orderItems) {
        item.isRejected.value = true;
        item.isAccepted.value = false;
      }
    } else if (isStatusAccepted || hasAcceptedItems || isExplicitlyAccepted) {
      isOrderAccepted.value = true;
      for (final item in orderItems) {
        item.isAccepted.value = true;
        item.isRejected.value = false;
      }
    } else {
      isOrderAccepted.value = false;
    }

    // 8. Shipping Activities (if key missing -> empty list)
    final actList =
        data['shipping_activities'] ??
        data['activities'] ??
        data['history'] ??
        data['tracking'];
    if (actList is List && actList.isNotEmpty) {
      shippingActivities.assignAll(
        actList.map((act) {
          if (act is Map) {
            return ShippingActivityModel(
              title: (act['title'] ?? act['status'] ?? act['event'] ?? '')
                  .toString(),
              timestamp: (act['timestamp'] ?? act['time'] ?? act['date'] ?? '')
                  .toString(),
              description:
                  (act['description'] ?? act['details'] ?? act['notes'] ?? '')
                      .toString(),
              isCompleted: act['is_completed'] ?? act['completed'] ?? true,
              highlightText: act['highlight_text']?.toString(),
            );
          }
          return ShippingActivityModel(
            title: '',
            timestamp: '',
            description: '',
          );
        }).toList(),
      );
    } else {
      shippingActivities.clear();
    }
  }

  String _formatPriceVal(dynamic raw) {
    if (raw == null) return '-';
    final str = raw.toString().trim();
    if (str.isEmpty || str == 'null') return '-';
    final cleanStr = str.replaceAll('₹', '').trim();
    final parsed = double.tryParse(cleanStr);
    if (parsed != null) {
      return '₹ ${parsed.toStringAsFixed(2)}';
    }
    return str;
  }

  String formatDateOnly(dynamic dateRaw) {
    if (dateRaw == null) return '-';
    final String inputString = dateRaw.toString().trim();
    if (inputString.isEmpty || inputString == 'null' || inputString == '-') {
      return '-';
    }

    try {
      DateTime dateTime = DateTime.parse(inputString);
      String formattedDate = DateFormat(
        'dd-MM-yyyy',
      ).format(dateTime.toLocal());
      String formattedTime = DateFormat(
        'hh:mm:ss a',
      ).format(dateTime.toLocal());
      return '$formattedDate $formattedTime';
    } catch (_) {
      DateTime? dt = DateTime.tryParse(inputString);
      if (dt == null && inputString.contains(' ')) {
        dt = DateTime.tryParse(inputString.replaceFirst(' ', 'T'));
      }
      if (dt != null) {
        String formattedDate = DateFormat('dd-MM-yyyy').format(dt.toLocal());
        String formattedTime = DateFormat('hh:mm:ss a').format(dt.toLocal());
        return '$formattedDate $formattedTime';
      }
      return inputString;
    }
  }

  String extractDateOnly(String fullDateStr) {
    final trimmed = fullDateStr.trim();
    if (trimmed.isEmpty || trimmed == 'null' || trimmed == '-') return '-';
    final parts = trimmed.split(' ');
    return parts.isNotEmpty ? parts[0] : trimmed;
  }

  String extractTimeOnly(String fullTimeStr) {
    final trimmed = fullTimeStr.trim();
    if (trimmed.isEmpty || trimmed == 'null' || trimmed == '-') return '-';
    final parts = trimmed.split(' ');
    if (parts.length >= 3) {
      return '${parts[1]} ${parts[2]}';
    } else if (parts.length == 2) {
      return parts[1];
    }
    return '-';
  }

  String _buildAddressString(Map map) {
    final parts = [
      map['address'],
      map['street'],
      map['address_1'],
      map['city'],
      map['state'],
      map['country'],
    ].where((p) => p != null && p.toString().trim().isNotEmpty).toList();
    return parts.join(', ');
  }

  Future<void> downloadInvoiceById(String invId) async {
    final targetInvoiceId = invId.trim().isNotEmpty && invId.trim() != 'null'
        ? invId.trim()
        : (invoiceId.value.trim().isNotEmpty && invoiceId.value.trim() != 'null'
              ? invoiceId.value.trim()
              : (invoiceNumber.value.trim().isNotEmpty &&
                        invoiceNumber.value.trim() != 'null'
                    ? invoiceNumber.value.trim()
                    : ''));

    if (targetInvoiceId.isEmpty || targetInvoiceId == 'null') {
      Get.snackbar(
        'Invoice',
        'There is no invoice',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    isDownloadingInvoice.value = true;
    Get.snackbar(
      'Download Started',
      'Downloading invoice...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );

    try {
      final bytes = await _orderService.downloadInvoice(
        invoiceId: targetInvoiceId,
      );

      if (bytes != null && bytes.isNotEmpty) {
        final filename = invoiceNumber.value.isNotEmpty
            ? "Invoice_${invoiceNumber.value}.pdf"
            : "Invoice_$targetInvoiceId.pdf";
        downloadBlob(bytes, filename, mimeType: 'application/pdf');
        isInvoiceDownloaded.value = true;
        Get.snackbar(
          'Success',
          'Invoice downloaded successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      } else {
        Get.snackbar(
          'Download Failed',
          'Failed to download invoice for ID: $targetInvoiceId.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download invoice: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isDownloadingInvoice.value = false;
    }
  }

  Future<void> generateInvoice() async {
    final status = orderStatus.value.trim().toLowerCase();
    if (status == 'void' || status == 'rejected' || status == 'cancelled') {
      return;
    }
    isDownloadingInvoice.value = true;
    try {
      if (orderKey.value.trim().isNotEmpty) {
        await fetchOrderDetails(orderKey.value.trim());
      }
    } catch (_) {
    } finally {
      isDownloadingInvoice.value = false;
    }

    final targetInvoiceId = invoiceId.value.trim();
    final hasInvoice = targetInvoiceId.isNotEmpty && targetInvoiceId != 'null';

    if (hasInvoice) {
      isInvoiceDownloaded.value = true;
      if (invoiceNumber.value.trim().isEmpty ||
          invoiceNumber.value.trim() == 'null' ||
          invoiceNumber.value.trim() == '-') {
        invoiceNumber.value = targetInvoiceId;
      }
      Get.snackbar(
        'Invoice Ready',
        'Invoice $targetInvoiceId is ready',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    } else {
      isInvoiceDownloaded.value = false;
      Get.snackbar(
        'Invoice',
        'There is no invoice',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    }
  }

  void downloadDocument(DocumentModel doc) {
    if (doc.title.toLowerCase().replaceAll(' ', '') == 'invoice') {
      downloadInvoiceById(invoiceId.value);
      return;
    }

    Get.snackbar(
      'Download Started',
      'Downloading ${doc.title} (${doc.code})...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  Future<bool> submitPayment({
    required String orderNumber,
    required String dueAmount,
    required String issuedBy,
    required DateTime selectedDate,
    required TimeOfDay selectedTime,
    required String createdDateText,
    required String createdTimeText,
    required String rrnUtr,
    required String amount,
    required String status,
    String? receiptFileName,
  }) async {
    if (orderNumber.trim().isEmpty ||
        dueAmount.trim().isEmpty ||
        issuedBy.trim().isEmpty ||
        createdDateText.trim().isEmpty ||
        createdTimeText.trim().isEmpty ||
        rrnUtr.trim().isEmpty ||
        amount.trim().isEmpty ||
        status.trim().isEmpty) {
      return false;
    }

    final cleanAmount = amount
        .replaceAll('₹', '')
        .replaceAll('\$', '')
        .replaceAll(',', '')
        .trim();
    final cleanDueAmount = dueAmount
        .replaceAll('₹', '')
        .replaceAll('\$', '')
        .replaceAll(',', '')
        .trim();

    final parsedAmountVal = double.tryParse(cleanAmount);
    final parsedDueAmountVal = double.tryParse(cleanDueAmount) ?? 0.0;
    if (parsedAmountVal == null ||
        parsedAmountVal < 0.01 ||
        parsedAmountVal > parsedDueAmountVal) {
      return false;
    }
    final cleanOrderNo = orderNumber.trim().isNotEmpty
        ? orderNumber.trim().replaceAll('#', '')
        : orderNo.value.replaceAll('#', '').trim();

    final dt = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    final isoDate =
        '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}T${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00+05:30';

    final paymentType = issuedBy == 'Bank Transfer'
        ? 'Bank Transfer'
        : (issuedBy == 'Cash' ? 'Cash' : 'UPI');
    final dateStamp =
        '${dt.year}${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}';
    final nowMs = DateTime.now().millisecondsSinceEpoch.toString();
    final shortSuffix = nowMs.length > 4
        ? nowMs.substring(nowMs.length - 4)
        : nowMs;
    final txnId = 'TXN-$dateStamp-$shortSuffix';
    final cleanRrn = rrnUtr.trim().isNotEmpty
        ? rrnUtr.trim()
        : nowMs.padLeft(12, '0').substring(0, 12);
    final txnRef = rrnUtr.trim().isNotEmpty
        ? rrnUtr.trim()
        : 'TXN-REF-$shortSuffix';

    final parsedOrderId = int.tryParse(orderId.value.trim()) ?? 0;
    final parsedCustomerId = int.tryParse(customerId.value.trim()) ?? 0;

    final cgstVal = _parseItemAmount(cgst.value);
    final sgstVal = _parseItemAmount(sgst.value);
    final taxVal = _parseItemAmount(tax.value);

    final hasValidInv =
        invoiceNumber.value.trim().isNotEmpty &&
        invoiceNumber.value.trim() != '-' &&
        invoiceNumber.value.trim() != 'null';
    final invoicesJson = hasValidInv
        ? jsonEncode([
            {
              "invoicenumber": invoiceNumber.value.trim(),
              "amount": _parseItemAmount(grandTotal.value),
            },
          ])
        : "[]";

    final Map<String, dynamic> payload = {
      "orderid": parsedOrderId,
      "ordernumber": cleanOrderNo,
      "customerid": parsedCustomerId,
      "customername": customer.value,
      "transactionref": txnRef,
      "paymentdate": isoDate,
      "paymenttype": paymentType,
      "paymentamount": cleanAmount,
      "isocurrency": "INR",
      "transactionid": txnId,
      "gatewaytransactionid": "WL-$shortSuffix",
      "paymentmode": paymentType,
      "paymentgateway": issuedBy.toLowerCase(),
      "terminal": "TID-0042",
      "channel": "POS",
      "dueamount": cleanDueAmount.isNotEmpty ? cleanDueAmount : "0",
      "conveniencefee": "0",
      "taxamount": taxVal > 0 ? taxVal.toStringAsFixed(2) : "0",
      "taxdetails": jsonEncode({"cgst": cgstVal, "sgst": sgstVal}),
      "statuscode": status.toLowerCase() == 'success' ? "00" : "01",
      "statusmessage": status.toLowerCase() == 'success'
          ? "Transaction successful"
          : "Transaction $status",
      "cardtype": "",
      "cardlast4": "",
      "cardexpiry": "",
      "bankname": "",
      "accountlast4": "",
      "upiid": "",
      "invoices": invoicesJson,
      "receipturl": receiptFileName ?? "",
      "receiptid": receiptFileName != null && receiptFileName.isNotEmpty
          ? "RCPT-$shortSuffix"
          : "",
      "isrefund": false,
      "refundstatus": "",
      "refundamount": "0",
      "refundreason": "",
      "ischargeback": false,
      "disputeid": "",
      "installmentnumber": 1,
      "totalinstallments": 1,
      "isrecurring": false,
      "subscriptionid": "",
      "authcode": "",
      "rrn": cleanRrn,
      "metadata": jsonEncode({
        "gateway_status": status == 'Success' ? "Completed" : status,
        "fraud_check": "Passed",
      }),
      "notes": "Paid at counter",
      "details": jsonEncode({"source": "pos"}),
      "paymentstatus": status,
      "issuedby": issuedBy,
    };

    isSubmittingPayment.value = true;
    try {
      final res = await _orderService.addPayment(payload: payload);
      final isSuccess =
          res != null &&
          (res['success'] == true ||
              res['status'] == true ||
              res['status'] == 1 ||
              res['status'] == 'success' ||
              res['code'] == 200 ||
              res['code'] == 201 ||
              !res.containsKey('error'));

      final formattedAmount = _formatPriceVal(cleanAmount);
      //print("IsSuccess in order details....$isSuccess");

      if (isSuccess) {
        transactions.insert(
          0,
          PaymentTransactionModel(
            issuedBy: issuedBy,
            createdOn: '$createdDateText $createdTimeText',
            paymentId: txnId,
            paymentMethod: paymentType,
            rrnUtr: cleanRrn,
            status: status,
            amount: formattedAmount,
          ),
        );

        if (orderKey.value.isNotEmpty) {
          fetchOrderDetails(orderKey.value);
        }

        Get.snackbar(
          'Payment Added',
          (res['message'] ?? 'Payment of $formattedAmount added successfully')
              .toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return true;
      } else {
        final errMsg =
            (res?['message'] ?? res?['error'] ?? 'Failed to add payment')
                .toString();
        Get.snackbar(
          'Error',
          errMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add payment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isSubmittingPayment.value = false;
    }
  }

  void downloadReceipt(PaymentTransactionModel transaction) {
    Get.snackbar(
      'Receipt Download',
      'Downloading receipt for ${transaction.issuedBy} (${transaction.rrnUtr})...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  double _parseItemAmount(String raw) {
    final cleanStr = raw
        .replaceAll('₹', '')
        .replaceAll(',', '')
        .replaceAll(RegExp(r'\s+'), '')
        .trim();
    return double.tryParse(cleanStr) ?? 0.0;
  }

  double get totalSuccessTransactionAmount {
    double sum = 0.0;
    for (final tx in transactions) {
      final s = tx.status.trim().toLowerCase();
      if (s == 'success' || s == 'paid' || s == 'completed') {
        sum += _parseItemAmount(tx.amount);
      }
    }
    if (sum > 0) return sum;
    if (paidAmount.value > 0) return paidAmount.value;
    return sum;
  }

  double get paidAmountValue {
    if (hasExplicitDueAmount.value) {
      if (paidAmount.value > 0) {
        return paidAmount.value;
      }
      final total = orderTotalValue;
      final derived = total - dueAmount.value;
      return derived >= 0 ? derived : 0.0;
    }
    if (paidAmount.value > 0) {
      return paidAmount.value;
    }
    return totalSuccessTransactionAmount;
  }

  double get orderTotalValue => _parseItemAmount(grandTotal.value);

  double get dueAmountValue {
    if (hasExplicitDueAmount.value) {
      return dueAmount.value;
    }
    final total = orderTotalValue;
    return (total - totalSuccessTransactionAmount).clamp(0.0, double.infinity);
  }

  String get paymentDueDisplay {
    if (hasExplicitDueAmount.value) {
      if (dueAmount.value <= 0) {
        return 'Paid';
      }
      return 'Due ₹ ${dueAmount.value.toStringAsFixed(2)}';
    }
    final pStatus = paymentMethod.value.trim().toLowerCase();
    if (pStatus == 'paid') {
      return 'Paid';
    }
    if (dueAmountValue <= 0) {
      return 'Paid';
    }
    return 'Due ₹ ${dueAmountValue.toStringAsFixed(2)}';
  }

  int get totalRejectedItems {
    final isVoid =
        orderStatus.value.trim().toLowerCase() == 'void' ||
        orderStatus.value.trim().toLowerCase() == 'rejected' ||
        orderStatus.value.trim().toLowerCase() == 'cancelled';
    if (isVoid) return orderItems.length;
    return orderItems.where((item) => item.isRejected.value).length;
  }

  String get totalDeclinedAmount {
    final isVoid =
        orderStatus.value.trim().toLowerCase() == 'void' ||
        orderStatus.value.trim().toLowerCase() == 'rejected' ||
        orderStatus.value.trim().toLowerCase() == 'cancelled';
    double sum = 0.0;
    for (final item in orderItems) {
      if (item.isRejected.value || isVoid) {
        sum += _parseItemAmount(item.total.value);
      }
    }
    return '₹${sum.toStringAsFixed(2)}';
  }

  int get totalAcceptedItems {
    final isVoid =
        orderStatus.value.trim().toLowerCase() == 'void' ||
        orderStatus.value.trim().toLowerCase() == 'rejected' ||
        orderStatus.value.trim().toLowerCase() == 'cancelled';
    if (isVoid) return 0;
    return orderItems.where((item) => item.isAccepted.value).length;
  }

  String get acceptedOrderAmount {
    final isVoid =
        orderStatus.value.trim().toLowerCase() == 'void' ||
        orderStatus.value.trim().toLowerCase() == 'rejected' ||
        orderStatus.value.trim().toLowerCase() == 'cancelled';
    if (isVoid) return '₹0.00';
    double sum = 0.0;
    for (final item in orderItems) {
      if (item.isAccepted.value) {
        sum += _parseItemAmount(item.total.value);
      }
    }
    return '₹${sum.toStringAsFixed(2)}';
  }

  void updateItemQty(int index, String value) {
    if (index >= 0 && index < orderItems.length) {
      final item = orderItems[index];
      final parsed = int.tryParse(value.trim());
      final newQty = (parsed != null && parsed >= 0) ? parsed : 0;
      item.qty.value = newQty;
      final unitPrice = _parseItemAmount(item.price);
      item.total.value = '₹ ${(unitPrice * newQty).toStringAsFixed(2)}';
    }
  }

  void incrementItemQty(int index) {
    if (index >= 0 && index < orderItems.length) {
      final item = orderItems[index];
      item.qty.value++;
      final textVal = item.qty.value.toString();
      item.qtyController.value = TextEditingValue(
        text: textVal,
        selection: TextSelection.collapsed(offset: textVal.length),
      );
      final unitPrice = _parseItemAmount(item.price);
      item.total.value = '₹ ${(unitPrice * item.qty.value).toStringAsFixed(2)}';
    }
  }

  void decrementItemQty(int index) {
    if (index >= 0 && index < orderItems.length) {
      final item = orderItems[index];
      if (item.qty.value > 1) {
        item.qty.value--;
        final textVal = item.qty.value.toString();
        item.qtyController.value = TextEditingValue(
          text: textVal,
          selection: TextSelection.collapsed(offset: textVal.length),
        );
        final unitPrice = _parseItemAmount(item.price);
        item.total.value =
            '₹ ${(unitPrice * item.qty.value).toStringAsFixed(2)}';
      }
    }
  }

  void toggleAcceptItem(int index) {
    if (index >= 0 && index < orderItems.length) {
      final item = orderItems[index];
      if (item.isAccepted.value) {
        // item.isAccepted.value = false;
      } else {
        // item.isAccepted.value = true;
        // item.isRejected.value = false;
      }
    }
  }

  void toggleRejectItem(int index) {
    if (index >= 0 && index < orderItems.length) {
      final item = orderItems[index];
      if (item.isRejected.value) {
        //item.isRejected.value = false;
      } else {
        // item.isRejected.value = true;
        // item.isAccepted.value = false;
      }
    }
  }

  Future<void> acceptAllItems() async {
    if (isAcceptingOrder.value) return;

    final String targetSalesOrderId = (salesOrderId.value.trim().isNotEmpty
        ? salesOrderId.value.trim()
        : orderId.value.trim());

    if (targetSalesOrderId.isEmpty || targetSalesOrderId == 'null') {
      Get.snackbar(
        'Error',
        'Sales order ID not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFCF4340),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      isAcceptingOrder.value = true;
      final response = await _orderService.acceptAllOrder(
        salesOrderId: targetSalesOrderId,
      );

      final isFailure =
          response == null ||
          response['success'] == false ||
          response['status'] == false ||
          (response.containsKey('code') &&
              response['code'] != 0 &&
              response['code'] != 200 &&
              response['code'] != '0' &&
              response['code'] != '200') ||
          (response['error'] != null &&
              response['error'].toString().trim().isNotEmpty);

      if (!isFailure) {
        // 1. Immediately hide accept/reject buttons and mark order as accepted
        isAcceptingOrder.value = false;
        isOrderAccepted.value = true;
        orderStatus.value = 'Accepted';

        for (final item in orderItems) {
          item.isAccepted.value = true;
          item.isRejected.value = false;
        }

        final successMsg =
            (response['message'] ??
                    response['msg'] ??
                    'All order items have been accepted.')
                .toString();

        Get.snackbar(
          'Success',
          successMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 2),
        );

        // Also refresh the order list in background if registered
        try {
          if (Get.isRegistered<OrderController>()) {
            Get.find<OrderController>().fetchOrders();
          }
        } catch (_) {}
      } else {
        final errorMsg =
            (response?['message'] ??
                    response?['error'] ??
                    response?['msg'] ??
                    'Failed to accept order')
                .toString();
        Get.snackbar(
          'Error',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFCF4340),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while accepting order: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFCF4340),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isAcceptingOrder.value = false;
    }
  }

  Future<void> rejectAllItems() async {
    if (isRejectingOrder.value || isAcceptingOrder.value) return;

    final targetSalesOrderId =
        (salesOrderId.value.trim().isNotEmpty &&
            salesOrderId.value.trim() != 'null'
        ? salesOrderId.value.trim()
        : orderId.value.trim());

    if (targetSalesOrderId.isEmpty || targetSalesOrderId == 'null') {
      Get.snackbar(
        'Error',
        'Sales order ID not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFCF4340),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      isRejectingOrder.value = true;
      final response = await _orderService.rejectAllOrder(
        salesOrderId: targetSalesOrderId,
      );

      final isFailure =
          response == null ||
          response['success'] == false ||
          response['status'] == false ||
          (response.containsKey('code') &&
              response['code'] != 0 &&
              response['code'] != 200 &&
              response['code'] != '0' &&
              response['code'] != '200') ||
          (response['error'] != null &&
              response['error'].toString().trim().isNotEmpty);

      if (!isFailure) {
        isRejectingOrder.value = false;
        isOrderAccepted.value = false;

        final data = response['data'];
        if (data is Map && data['orderstatus'] != null) {
          orderStatus.value = data['orderstatus'].toString();
        } else if (data is Map && data['status'] != null) {
          orderStatus.value = data['status'].toString();
        } else {
          orderStatus.value = 'Void';
        }

        for (final item in orderItems) {
          item.isRejected.value = true;
          item.isAccepted.value = false;
        }

        final successMsg =
            (response['message'] ??
                    response['msg'] ??
                    'All order items have been rejected.')
                .toString();

        Get.snackbar(
          'Success',
          successMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 2),
        );

        // Also update order in order controller if registered
        try {
          if (Get.isRegistered<OrderController>()) {
            Get.find<OrderController>().syncOrderUpdates(
              orderKey: orderKey.value,
              orderId: orderId.value,
              orderStatus: orderStatus.value,
            );
          }
        } catch (_) {}
      } else {
        final errorMsg =
            (response?['message'] ??
                    response?['error'] ??
                    response?['msg'] ??
                    'Failed to reject order')
                .toString();
        Get.snackbar(
          'Error',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFCF4340),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while rejecting order: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFCF4340),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isRejectingOrder.value = false;
    }
  }

  String formatTitleCase(String input) {
    final clean = input.trim().replaceAll('_', ' ').replaceAll('-', ' ');
    if (clean.isEmpty || clean == 'null' || clean == '-') return clean;
    return clean
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map(
          (w) => w.length == 1
              ? w.toUpperCase()
              : w[0].toUpperCase() + w.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}
