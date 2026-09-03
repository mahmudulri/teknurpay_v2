import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:teknurpay/controllers/currency_controller.dart';
import 'package:teknurpay/controllers/dashboard_controller.dart';
import 'package:teknurpay/controllers/recharge_config_controller.dart';
import 'package:teknurpay/global_controller/afghan_recharge_controller.dart';
import 'package:teknurpay/global_controller/font_controller.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/global_controller/page_controller.dart';
import 'package:teknurpay/global_controller/time_zone_controller.dart';
import 'package:teknurpay/helpers/network_checker.dart';
import 'package:teknurpay/routes/routes.dart';
import 'package:teknurpay/services/firebase_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  log('========== BACKGROUND FCM ==========');
  log('Message ID: ${message.messageId}');
  log('Title: ${message.notification?.title}');
  log('Body: ${message.notification?.body}');
  log('Type: ${message.data['type']}');
  log('Event: ${message.data['event']}');
  log('Notification ID: ${message.data['notification_id']}');
  log('Order ID: ${message.data['order_id']}');
  log('Status: ${message.data['status']}');
  log('Reseller ID: ${message.data['reseller_id']}');
  log('Message: ${message.data['message']}');
  log('Full Data: ${message.data}');
  log('====================================');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  Get.put(CurrencyController(), permanent: true);
  Get.put(RechargeConfigController(), permanent: true);
  Get.put(AfghanRechargeController(), permanent: true);
  Get.put(DashboardController(), permanent: true);
  Get.put(LanguagesController(), permanent: true);
  Get.put(Mypagecontroller(), permanent: true);
  Get.put(FontController(), permanent: true);

  FirebaseNotificationService.instance.configure(
    refreshOrders: (Map<String, dynamic> data) async {
      /*
       * কোনো order status update হবে না।
       * শুধু Firebase notification data log হবে।
       */
      log('========== ORDER NOTIFICATION ==========');
      log('Type: ${data['type']}');
      log('Order ID: ${data['order_id']}');
      log('Status: ${data['status']}');
      log('Message: ${data['message']}');
      log('Full Data: $data');
      log('========================================');
    },

    refreshGeneralNotifications: (Map<String, dynamic> data) async {
      /*
       * কোনো notification API call বা list refresh হবে না।
       * শুধু notification receive করে log করবে।
       */
      log('========== GENERAL NOTIFICATION ==========');
      log('Title: ${data['title']}');
      log('Body: ${data['body']}');
      log('Type: ${data['type']}');
      log('Event: ${data['event']}');
      log('Notification ID: ${data['notification_id']}');
      log('Reseller ID: ${data['reseller_id']}');
      log('Message: ${data['message']}');
      log('Full Data: $data');
      log('==========================================');
    },

    refreshBalance: (Map<String, dynamic> data) async {
      /*
       * Dashboard বা balance history refresh হবে না।
       */
      log('========== BALANCE NOTIFICATION ==========');
      log('Type: ${data['type']}');
      log('Message: ${data['message']}');
      log('Full Data: $data');
      log('==========================================');
    },

    refreshPayments: (Map<String, dynamic> data) async {
      /*
       * Payment history refresh হবে না।
       */
      log('========== PAYMENT NOTIFICATION ==========');
      log('Type: ${data['type']}');
      log('Message: ${data['message']}');
      log('Full Data: $data');
      log('==========================================');
    },

    refreshHawala: (Map<String, dynamic> data) async {
      /*
       * Hawala history refresh হবে না।
       */
      log('========== HAWALA NOTIFICATION ==========');
      log('Type: ${data['type']}');
      log('Message: ${data['message']}');
      log('Full Data: $data');
      log('=========================================');
    },
  );

  await FirebaseNotificationService.instance.initialize();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('fa', 'IR'),
        Locale('ar', 'AE'),
        Locale('ps', 'AF'),
        Locale('tr', 'TR'),
        Locale('bn', 'BD'),
      ],
      path: 'assets/langs',
      fallbackLocale: const Locale('en', 'US'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GetStorage box = GetStorage();

  final TimeZoneController timeZoneController = Get.put(TimeZoneController());

  @override
  void initState() {
    super.initState();
    initTimezone();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DependencyInjection.init();
    });
  }

  void initTimezone() {
    final Duration offset = DateTime.now().timeZoneOffset;

    timeZoneController.sign = offset.isNegative ? '-' : '+';

    timeZoneController.hour = offset.inHours.abs().toString().padLeft(2, '0');

    timeZoneController.minute = (offset.inMinutes.abs() % 60)
        .toString()
        .padLeft(2, '0');

    debugPrint(
      'Offset = '
      '${timeZoneController.sign}'
      '${timeZoneController.hour}:'
      '${timeZoneController.minute}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      initialRoute: splash,
      getPages: myroutes,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Get.updateLocale(context.locale);
    });
  }
}
