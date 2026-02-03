import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/delete_office_controller.dart';
import '../../controllers/office_list_controller.dart';
import '../../controllers/office_transactions_controller.dart';
import '../../global_controller/languages_controller.dart';
import '../create_office_screen.dart';
import '../update_office_screen.dart';
import '../view_office_screen.dart';

class Offices extends StatefulWidget {
  Offices({super.key});

  @override
  State<Offices> createState() => _OfficesState();
}

class _OfficesState extends State<Offices> {
  final languagesController = Get.find<LanguagesController>();

  OfficeListController officeListController = Get.put(OfficeListController());

  final ScrollController scrollController = ScrollController();

  OfficeTransactionsListController transactionsListController = Get.put(
    OfficeTransactionsListController(),
  );

  DeleteOfficeController deleteOfficeController = Get.put(
    DeleteOfficeController(),
  );

  Future<void> refresh() async {
    if (officeListController.finalList.length >=
        (officeListController
                .allofficelist
                .value
                .data!
                .pagination!
                .totalItems ??
            0)) {
      print(
        "End..........................................End.....................",
      );
    } else {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        officeListController.initialpage++;
        // print(orderlistController.initialpage);
        print("Load More...................");
        officeListController.fetchofficelist();
      } else {
        // print("nothing");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    officeListController.initialpage = 1;
    officeListController.finalList.clear();
    officeListController.fetchofficelist();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              languagesController.tr("OFFICES"),
              style: GoogleFonts.rubik(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade100,

              child: Image.asset("assets/icons/headphone.png", height: 25),
            ),
            SizedBox(width: 5),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade100,

              child: Image.asset("assets/icons/bell.png", height: 25),
            ),
            SizedBox(width: 5),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade100,

              child: Image.asset("assets/icons/gridmenu.png", height: 25),
            ),
          ],
        ),
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.white,
        elevation: 0.0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFC5E3FF)],
          ),
        ),

        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            child: Column(
              children: [
                Container(
                  height: 50,
                  width: screenWidth,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    size: 30,
                                    color: Colors.grey.shade500,
                                  ),

                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: languagesController.tr(
                                          "OFFICE_NAME",
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Image.asset("assets/icons/filter.png"),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: Obx(
                    () => officeListController.isLoading.value == false
                        ? ListView.builder(
                            padding: EdgeInsets.all(0.0),
                            physics: BouncingScrollPhysics(),
                            itemCount: officeListController.finalList.length,
                            itemBuilder: (context, index) {
                              final data =
                                  officeListController.finalList[index];

                              return GestureDetector(
                                onTap: () {
                                  transactionsListController.finalList.clear();
                                  transactionsListController.initialpage = 1;
                                  transactionsListController.fetchtransactions(
                                    int.parse(data.id.toString()),
                                  );
                                  Get.to(
                                    () => ViewOfficeScreen(
                                      id: data.id.toString(),
                                      officeId: data.code,
                                      officeName: data.name,
                                      location: data.location,
                                      phone: data.phone,
                                      address: data.address,
                                      notes: data.notes,
                                      isactive: data.isActive,
                                    ),
                                  );
                                },
                                child: Container(
                                  width: screenWidth,
                                  margin: EdgeInsets.only(bottom: 5),
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data.name.toString(),
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Text(
                                                  languagesController.tr("ID"),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                                SizedBox(width: 2),
                                                Text(
                                                  ":",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                                SizedBox(width: 2),
                                                Text(
                                                  data.code.toString(),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Text(
                                                  languagesController.tr(
                                                    "LOCATION",
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                                SizedBox(width: 2),
                                                Text(
                                                  ":",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                                SizedBox(width: 2),
                                                Text(
                                                  data.location.toString(),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Text(
                                                  languagesController.tr(
                                                    "PHONE_NUMBER",
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                                SizedBox(width: 2),
                                                Text(
                                                  ":",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                                SizedBox(width: 2),
                                                Text(
                                                  data.phone.toString(),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                contentPadding: EdgeInsets.zero,

                                                content: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  child: Container(
                                                    height: 130,
                                                    width: screenWidth,
                                                    color: Colors.white,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 8,
                                                          ),
                                                      child: Column(
                                                        children: [
                                                          Expanded(
                                                            child: Container(
                                                              color:
                                                                  Colors.green,
                                                              child: Column(
                                                                children: [
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Container(
                                                                      color: Colors
                                                                          .white,
                                                                      child: GestureDetector(
                                                                        onTap: () {
                                                                          print(
                                                                            Get.to(
                                                                              () => UpdateOfficeScreen(
                                                                                officeName: data.name,
                                                                                phoneNumber: data.phone,
                                                                                codeNumber: data.code.toString(),
                                                                                location: data.location,
                                                                                address: data.address,
                                                                                isActive: data.isActive.toString(),
                                                                                notes: data.notes,
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                        child: Center(
                                                                          child: Text(
                                                                            languagesController.tr(
                                                                              "EDIT_OFFICE",
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    height: 1,
                                                                    width:
                                                                        screenWidth,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade200,
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: GestureDetector(
                                                                      onTap: () {
                                                                        deleteOfficeController.deleteoffice(
                                                                          data.id
                                                                              .toString(),
                                                                        );
                                                                        Navigator.pop(
                                                                          context,
                                                                        );
                                                                      },
                                                                      child: Container(
                                                                        color: Colors
                                                                            .white,
                                                                        child: Center(
                                                                          child: Text(
                                                                            languagesController.tr(
                                                                              "DELETE_OFFICE",
                                                                            ),
                                                                            style: TextStyle(
                                                                              color: Colors.red,
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
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Image.asset(
                                          "assets/icons/more.png",
                                          height: 25,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(child: CircularProgressIndicator()),
                  ),
                ),
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    Get.to(() => CreateOfficeScreen());
                  },
                  child: Container(
                    height: 55,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/svg/abutton.webp"),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        languagesController.tr("ADD_NEW_OFFICE"),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class officeDialog extends StatelessWidget {
  officeDialog({super.key});

  final languagesController = Get.find<LanguagesController>();

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 230,
      width: screenWidth,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.green,
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.white,
                        child: Center(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.close,
                                      color: Colors.grey.shade700,
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => ViewOfficeScreen());
                                },

                                child: Text(
                                  languagesController.tr("VIEW_OFFICE"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      width: screenWidth,
                      color: Colors.grey.shade200,
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.white,
                        child: Center(
                          child: Text(languagesController.tr("EDIT_OFFICE")),
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      width: screenWidth,
                      color: Colors.grey.shade200,
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.white,
                        child: Center(
                          child: Text(
                            languagesController.tr("DELETE_OFFICE"),
                            style: TextStyle(color: Colors.red),
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
      ),
    );
  }
}
