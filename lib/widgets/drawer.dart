import 'package:teknurpay/widgets/custom_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teknurpay/controllers/drawer_controller.dart';
import 'package:teknurpay/controllers/sign_in_controller.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/global_controller/page_controller.dart';
import 'package:teknurpay/pages/homepages.dart';
import 'package:teknurpay/screens/helpscreen.dart';
import 'package:teknurpay/screens/profile_screen.dart';
import 'package:teknurpay/screens/welcomescreen.dart';
import 'package:teknurpay/screens/termscondition.dart';
import 'package:teknurpay/utils/colors.dart';

import '../controllers/dashboard_controller.dart';
import '../screens/sign_in_screen.dart';

class DrawerWidget extends StatefulWidget {
  DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final Mypagecontroller mypagecontroller = Get.find();

  final box = GetStorage();

  final dashboardController = Get.find<DashboardController>();

  LanguagesController languagesController = Get.put(LanguagesController());

  MyDrawerController drawerController = Get.put(MyDrawerController());

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: screenHeight,
      width: 250,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 20, 20, 20).withOpacity(0.99),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: ListView(
        children: [
          SizedBox(height: 50),
          Obx(
            () => Padding(
              padding: EdgeInsets.all(5.0),
              child: dashboardController.isLoading.value == false
                  ? CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          dashboardController
                                  .alldashboardData
                                  .value
                                  .data!
                                  .userInfo!
                                  .profileImageUrl
                                  .toString() !=
                              "null"
                          ? NetworkImage(
                              dashboardController
                                  .alldashboardData
                                  .value
                                  .data!
                                  .userInfo!
                                  .profileImageUrl
                                  .toString(),
                            )
                          : null, // Remove background image if null
                      child:
                          dashboardController
                                  .alldashboardData
                                  .value
                                  .data!
                                  .userInfo!
                                  .profileImageUrl
                                  .toString() ==
                              "null"
                          ? Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ) // Placeholder icon
                          : null,
                    )
                  : SizedBox(),
            ),
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(
                () => dashboardController.isLoading.value == false
                    ? Column(
                        children: [
                          Text(
                            dashboardController
                                .alldashboardData
                                .value
                                .data!
                                .userInfo!
                                .resellerName
                                .toString(),
                            style: TextStyle(
                              fontSize: screenHeight * 0.022,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            dashboardController
                                .alldashboardData
                                .value
                                .data!
                                .userInfo!
                                .email
                                .toString(),
                            style: TextStyle(
                              fontSize: screenHeight * 0.022,
                              color: Colors.grey,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      )
                    : SizedBox(),
              ),
            ],
          ),
          SizedBox(height: 50),
          Obx(
            () => drawermenu(
              imagelink: "assets/icons/user.png",
              menuname: languagesController.tr("PROFILE"),
              onpressed: () {
                mypagecontroller.changePage(ProfileScreen(), isMainPage: false);
                drawerController.isOpen.value = false;
              },
            ),
          ),
          SizedBox(height: screenHeight * 0.025),
          drawermenu(
            imagelink: "assets/icons/security-safe.png",
            menuname: languagesController.tr("TERMS_AND_CONDITIONS"),
            onpressed: () {
              mypagecontroller.changePage(Termscondition(), isMainPage: false);
              drawerController.isOpen.value = false;
            },
          ),
          SizedBox(height: screenHeight * 0.025),
          drawermenu(
            imagelink: "assets/icons/note-text.png",
            menuname: languagesController.tr("HELP"),
            onpressed: () {
              mypagecontroller.changePage(Helpscreen(), isMainPage: false);
            },
          ),
          SizedBox(height: screenHeight * 0.025),
          drawermenu(
            imagelink: "assets/icons/whatsapp.png",
            menuname: languagesController.tr("CONTACTUS"),
            onpressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                    contentPadding: EdgeInsets.all(0),
                    content: ContactDialogBox(),
                  );
                },
              );
            },
          ),
          SizedBox(height: screenHeight * 0.025),
          drawermenu(
            imagelink: "assets/icons/global.png",
            menuname: languagesController.tr("LANGUAGES"),
            onpressed: () {
              // Open the AlertDialog when the text is tapped
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Change Language"),
                    content: Container(
                      height: 350,
                      width: screenWidth,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: languagesController.alllanguagedata.length,
                        itemBuilder: (context, index) {
                          final data =
                              languagesController.alllanguagedata[index];
                          return GestureDetector(
                            onTap: () {
                              languagesController.changeLanguage(
                                data["name"].toString(),
                              );
                              box.write("language", data["name"]);
                              if (data["direction"].toString() == "ltr") {
                                box.write("direction", "ltr");
                                setState(() {
                                  EasyLocalization.of(
                                    context,
                                  )!.setLocale(Locale('en', 'US'));
                                });
                                print("LRT Mode.....................");
                              } else {
                                box.write("direction", "rtl");
                                setState(() {
                                  EasyLocalization.of(
                                    context,
                                  )!.setLocale(Locale('ar', 'AE'));
                                });
                              }
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 5),
                              height: 45,
                              width: screenWidth,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey.shade100,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Row(
                                  children: [
                                    Center(
                                      child: Text(
                                        languagesController
                                            .alllanguagedata[index]["name"]
                                            .toString(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(height: screenHeight * 0.025),
          drawermenu(
            imagelink: "assets/icons/logout.png",
            menuname: languagesController.tr("LOGOUT"),
            onpressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    contentPadding: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    content: LogoutDialogBox(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class drawermenu extends StatelessWidget {
  drawermenu({super.key, this.menuname, this.imagelink, this.onpressed});

  String? menuname;
  String? imagelink;
  VoidCallback? onpressed;

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onpressed,
      child: Row(
        children: [
          SizedBox(width: 10),
          Image.asset(imagelink.toString(), height: 30),
          SizedBox(width: 10),
          Text(
            menuname.toString(),
            style: TextStyle(
              color: Color(0xff919EAB),
              fontSize: screenHeight * 0.022,
            ),
          ),
        ],
      ),
    );
  }
}

class LogoutDialogBox extends StatelessWidget {
  LogoutDialogBox({super.key});

  final signInController = Get.find<SignInController>();
  final Mypagecontroller mypagecontroller = Get.find();

  final box = GetStorage();

  LanguagesController languagesController = Get.put(LanguagesController());

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 200,
      width: screenWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/icons/rejected.png", height: 40),
              SizedBox(width: 15),
              KText(
                text: languagesController.tr("DO_YOU_WANT_TO_LOG_OUT"),
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          // SizedBox(
          //   height: 20,
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 45,
              width: screenWidth,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        signInController.usernameController.clear();
                        signInController.passwordController.clear();

                        box.remove("userToken");
                        mypagecontroller.changePage(
                          Homepages(),
                          isMainPage: false,
                        );

                        Get.to(() => SignInScreen());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: KText(
                            text: languagesController.tr("YES_IAMGOING_OUT"),
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: KText(
                            text: languagesController.tr("CANCEL"),
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContactDialogBox extends StatelessWidget {
  ContactDialogBox({super.key});

  LanguagesController languagesController = Get.put(LanguagesController());

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 300,
      width: screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset("assets/icons/whatsapp2.png", height: 80),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "You will be redirected to the WhatsApp page to contact us. Continue?",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 50,
              width: screenWidth,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            languagesController.tr("YES"),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            languagesController.tr("CANCEL"),
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
