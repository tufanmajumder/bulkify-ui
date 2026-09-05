import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'app/data/utils/app_theme.dart';
import 'app/data/utils/idle_detector_widget.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size designSize = kIsWeb
            ? Size(constraints.maxWidth, constraints.maxHeight)
            : const Size(360, 690);

        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: false,
          builder: (context, child) {
            return IdleDetectorWidget(
              idleDuration: const Duration(minutes: 5),
              child: GetMaterialApp(
                debugShowCheckedModeBanner: false,
                title: "Bulkify",
                theme: AppTheme.lightTheme,
                initialRoute: AppPages.INITIAL,
                getPages: AppPages.routes,
              ),
            );
          },
        );
      },
    );
  }
}
