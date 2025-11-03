import 'package:flutter/material.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teknurpay/utils/colors.dart';

import '../global_controller/font_controller.dart';
import 'custom_text.dart';

class DefaultButton1 extends StatelessWidget {
  final double? width; // nullable
  final double height;
  final String? buttonName;
  final VoidCallback? onpressed;

  DefaultButton1({
    this.width, // now optional
    required this.height,
    this.buttonName,
    this.onpressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onpressed,
      child: Container(
        width: width ?? double.infinity, // if null → full width
        height: height,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white.withOpacity(0.3), Colors.transparent],
                  ),
                ),
                child: Center(
                  child: KText(
                    text: buttonName ?? "",
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DefaultButton2 extends StatelessWidget {
  final double width;
  final double height;
  final String? buttonName;
  final VoidCallback? onpressed;

  DefaultButton2({
    required this.width,
    required this.height,
    this.buttonName,
    this.onpressed,
  });
  final box = GetStorage();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onpressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Color(0xff04B75D),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white.withOpacity(0.3), Colors.transparent],
                  ),
                ),
                child: Center(
                  child: KText(
                    text: buttonName.toString(),
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: box.read("language").toString() == "Fa"
                        ? Get.find<FontController>().currentFont
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BlankButton extends StatelessWidget {
  final double? width; // nullable
  final double height;
  final String? buttonName;
  final VoidCallback? onpressed;

  BlankButton({
    this.width, // now optional
    required this.height,
    this.buttonName,
    this.onpressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onpressed,
      child: Container(
        width: width ?? double.infinity, // if null → full width
        height: height,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: AppColors.primaryColor.withOpacity(0.4),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                  ),
                ),
                child: Center(
                  child: KText(
                    text: buttonName ?? "",
                    color: AppColors.primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: 100,
      child: InnerShadow(
        shadows: [
          Shadow(
            color: Colors.white.withOpacity(0.4), // your green shadow
            blurRadius: 6,
            offset: Offset.zero, // ✅ no offset, shadow appears on all sides
          ),
        ],
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors.primaryColor,
          ),
          alignment: Alignment.center,
          child: Text("Button", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
