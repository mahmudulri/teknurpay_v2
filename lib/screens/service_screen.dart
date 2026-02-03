import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teknurpay/controllers/drawer_controller.dart';
import 'package:teknurpay/utils/colors.dart';
import 'package:teknurpay/widgets/bottomsheet.dart';
import 'package:teknurpay/controllers/bundle_controller.dart';
import 'package:teknurpay/controllers/service_controller.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/global_controller/page_controller.dart';
import '../widgets/custom_text.dart';
import 'social_bundles.dart';

class ServiceScreen extends StatefulWidget {
  ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final serviceController = Get.find<ServiceController>();

  final bundleController = Get.find<BundleController>();
  LanguagesController languagesController = Get.put(LanguagesController());

  // final confirmPinController = Get.find<ConfirmPinController>();

  final ScrollController scrollController = ScrollController();

  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    serviceController.fetchservices();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Status bar background color
        statusBarIconBrightness: Brightness.dark, // For Android
        statusBarBrightness: Brightness.light, // For iOS
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  MyDrawerController drawerController = Get.put(MyDrawerController());

  @override
  Widget build(BuildContext context) {
    final Mypagecontroller mypagecontroller = Get.find();
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        body: Container(
          height: screenHeight,
          width: screenWidth,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15, right: 15, top: 10),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            mypagecontroller.goBack();
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(
                              "assets/icons/backicon.png",
                              height: 40,
                            ),
                          ),
                        ),
                        Spacer(),
                        Obx(
                          () => KText(
                            text: "${languagesController.tr("SERVICES")}",
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                            color: Colors.black,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            CustomFullScreenSheet.show(context);
                          },
                          child: Image.asset(
                            "assets/icons/drawericon.png",
                            height: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Obx(() {
                    if (serviceController.isLoading.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                          strokeWidth: 1.0,
                        ),
                      );
                    }

                    final services =
                        serviceController
                            .allserviceslist
                            .value
                            .data
                            ?.services ??
                        [];

                    if (services.isEmpty) {
                      return Center(
                        child: Text(
                          'No services available',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.62,
                      ),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final data = services[index];

                        return GestureDetector(
                          onTap: () {
                            box.write("company_id", data.companyId);
                            print(data.companyId.toString());
                            mypagecontroller.changePage(
                              SocialBundles(),
                              isMainPage: false,
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.15),
                                      spreadRadius: 4,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: data.company?.companyLogo ?? '',
                                    placeholder: (context, url) {
                                      print('Loading image: $url');
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.grey,
                                          strokeWidth: 2.0,
                                        ),
                                      );
                                    },
                                    errorWidget: (context, url, error) {
                                      print(
                                        'Error loading image: $url, error: $error',
                                      );
                                      return Icon(
                                        Icons.error,
                                        size: 35,
                                        color: Colors.grey.shade400,
                                      );
                                    },
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              SizedBox(height: 8),

                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    data.company?.companyName ?? 'Unknown',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
