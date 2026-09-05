import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'commonMethod/commonFile.dart';
import 'controllers/fruit_controller.dart';
import 'models/fruit_item.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FruitListApp());
}

class FruitListApp extends StatelessWidget {
  const FruitListApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FruitController());

    return GetMaterialApp(
      title: 'SQLite Fruit Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _confirmDelete(FruitController controller, FruitItem fruit) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Fruit'),
        content: Text(
          'Are you sure you want to remove "${fruit.name}" from SQLite database?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Get.back();
              await controller.deleteFruit(fruit);
              Get.snackbar(
                'Fruit Deleted',
                '"${fruit.name}" removed from database',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 4),
                // mainButton: TextButton(
                //   onPressed: () async {
                //     await controller.addFruit(fruit);
                //   },
                //   child: const Text(
                //     'UNDO',
                //     style: TextStyle(
                //       color: Colors.amber,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddEditModal(FruitController controller, {FruitItem? fruit}) {
    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(Get.context!).viewInsets.bottom,
          ),
          child: FruitFormModal(
            fruit: fruit,
            onSave: (savedFruit) async {
              if (fruit == null) {
                await controller.addFruit(savedFruit);
              } else {
                await controller.updateFruit(savedFruit);
              }
            },
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  void _showFruitDetails(
    FruitController controller,
    FruitItem fruit,
    BuildContext context,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          fruit.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              context,
              Icons.currency_rupee,
              'Price per unit',
              '₹${fruit.price.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              Icons.production_quantity_limits,
              'Quantity',
              '${fruit.quantity}',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              Icons.payments,
              'Total Cost',
              '₹${(fruit.price * fruit.quantity).toStringAsFixed(2)}',
            ),
            if (fruit.note.isNotEmpty) ...[
              const Divider(height: 24),
              const Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                fruit.note,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _showAddEditModal(controller, fruit: fruit);
            },
            child: const Text('Edit'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final FruitController controller = Get.find<FruitController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SQLite Fruit Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showDeviceInfoDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.fruitItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No fruits found in SQLite',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditModal(controller),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Fruit to SQLite'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: controller.fruitItems.length,
            itemBuilder: (ctx, idx) {
              final fruit = controller.fruitItems[idx];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withAlpha(80),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          fruit.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        '₹${(fruit.price * fruit.quantity).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Price: ₹${fruit.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Qty: ${fruit.quantity}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (fruit.note.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            fruit.note,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (val) {
                      if (val == 'edit') {
                        _showAddEditModal(controller, fruit: fruit);
                      } else if (val == 'delete') {
                        _confirmDelete(controller, fruit);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _showFruitDetails(controller, fruit, context),
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditModal(controller),
        icon: const Icon(Icons.add),
        label: const Text('Add Fruit'),
      ),
    );
  }

  void _showDeviceInfoDialog(BuildContext context) async {
    final deviceInfo = DeviceInfoPlugin();
    final BaseDeviceInfo info = await deviceInfo.deviceInfo;

    String deviceId = 'Unknown';
    String model = 'Unknown';
    String brand = 'Unknown';
    String deviceType = 'Phone';
    String base64Data = '';

    try {
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        deviceId = webInfo.userAgent ?? 'Web Browser';
        model = webInfo.browserName.name;
        final vendor = webInfo.vendor;
        brand = (vendor != null && vendor.isNotEmpty) ? vendor : 'Web Browser';
        deviceType = 'Web Browser';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        model = androidInfo.model;
        brand = androidInfo.brand;
        final shortestSide = MediaQuery.of(context).size.shortestSide;
        deviceType = shortestSide >= 600 ? 'Tablet' : 'Phone';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'Unknown iOS';
        model = iosInfo.name.isNotEmpty ? iosInfo.name : iosInfo.model;
        brand = 'Apple';
        deviceType = iosInfo.model.toLowerCase().contains('ipad')
            ? 'Tablet'
            : 'Phone';
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        deviceId = windowsInfo.deviceId;
        model = windowsInfo.computerName;
        brand = 'Microsoft';
        deviceType = 'Desktop';
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        final macInfo = await deviceInfo.macOsInfo;
        deviceId = macInfo.systemGUID ?? 'Unknown macOS';
        model = macInfo.model;
        brand = 'Apple';
        deviceType = 'Desktop';
      } else if (defaultTargetPlatform == TargetPlatform.linux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        deviceId = linuxInfo.machineId ?? 'Unknown Linux';
        model = linuxInfo.name;
        brand = linuxInfo.variant ?? 'Linux';
        deviceType = 'Desktop';
      }
      CommonMethod commonMethod = CommonMethod();
      base64Data = commonMethod.convertData(deviceType, deviceId, model, brand);
      print('data in block...$base64Data');
    } catch (e) {
      deviceId = 'Error: $e';
    }

    print("Device ID: $deviceId ($deviceType)");
    print("Device Info Data: ${info.data}");

    if (!context.mounted) return;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.perm_device_info, color: Colors.blue),
            SizedBox(width: 8),
            Text('Device Information'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DEVICE TYPE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      deviceType,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),
                    const Text(
                      'DEVICE ID',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      deviceId,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),
                    const Text(
                      'MODEL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      model,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),
                    const Text(
                      'BRAND',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      brand,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),
                    const Text(
                      'BASE64 DATA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      base64Data,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              //const Divider(),
              // const SizedBox(height: 8),
              // ...info.data.entries.map((entry) {
              //   return Padding(
              //     padding: const EdgeInsets.symmetric(vertical: 4),
              //     child: Row(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           '${entry.key}: ',
              //           style: const TextStyle(fontWeight: FontWeight.bold),
              //         ),
              //         Expanded(child: Text('${entry.value}')),
              //       ],
              //     ),
              //   );
              // }),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class FruitFormModal extends StatefulWidget {
  final FruitItem? fruit;
  final Function(FruitItem) onSave;

  const FruitFormModal({super.key, this.fruit, required this.onSave});

  @override
  State<FruitFormModal> createState() => _FruitFormModalState();
}

class _FruitFormModalState extends State<FruitFormModal> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late double _price;
  late int _quantity;
  late String _note;

  @override
  void initState() {
    super.initState();
    final f = widget.fruit;
    _name = f?.name ?? '';
    _price = f?.price ?? 100.0;
    _quantity = f?.quantity ?? 1;
    _note = f?.note ?? '';
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newItem = FruitItem(
        id: widget.fruit?.id,
        name: _name.trim(),
        price: _price,
        quantity: _quantity,
        note: _note.trim(),
      );
      widget.onSave(newItem);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.fruit == null ? 'Add Fruit to SQLite' : 'Edit Fruit',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: 'Fruit Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please enter fruit name'
                    : null,
                onSaved: (val) => _name = val!,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _price.toStringAsFixed(2),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Price (₹) *',
                        prefixIcon: Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || double.tryParse(val) == null) {
                          return 'Enter price';
                        }
                        return null;
                      },
                      onSaved: (val) => _price = double.parse(val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _quantity.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        prefixIcon: Icon(Icons.production_quantity_limits),
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null ||
                            int.tryParse(val) == null ||
                            int.parse(val) <= 0) {
                          return 'Invalid qty';
                        }
                        return null;
                      },
                      onSaved: (val) => _quantity = int.parse(val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _note,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes / Description (Optional)',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => _note = val ?? '',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submit,
                child: Text(
                  widget.fruit == null
                      ? 'Save Fruit to SQLite'
                      : 'Update Fruit',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
