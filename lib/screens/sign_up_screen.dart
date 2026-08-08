import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teknurpay/controllers/currency_controller.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/utils/colors.dart';
import 'package:teknurpay/widgets/custom_text.dart';
import 'package:teknurpay/widgets/socialbuttonbox.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/country_list_controller.dart';
import '../controllers/district_controller.dart';
import '../controllers/province_controller.dart';
import '../controllers/sign_up_controller.dart';
import '../models/currency_model.dart';
import '../widgets/bottomsheet.dart';
import '../widgets/button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final LanguagesController languagesController =
      Get.find<LanguagesController>();

  final CountryListController countryListController = Get.put(
    CountryListController(),
  );

  final ProvinceController provinceController = Get.put(ProvinceController());

  final DistrictController districtController = Get.put(DistrictController());

  final CurrencyController currencyController = Get.put(CurrencyController());

  final SignUpController signUpController = Get.put(SignUpController());

  final box = GetStorage();

  final String phoneNumber = "+93708488200";

  String selectedCountry = "";
  String selectedProvince = "";
  String selectedDistrict = "";

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    countryListController.fetchCountryData();
    districtController.fetchDistrict();
    provinceController.fetchProvince();
    currencyController.fetchCurrencyList();
  }

  bool get isRtl {
    final direction = box.read("direction")?.toString().toLowerCase();
    return direction == "rtl";
  }

  Alignment get fieldAlignment =>
      isRtl ? Alignment.centerRight : Alignment.centerLeft;

  TextAlign get fieldTextAlign => isRtl ? TextAlign.right : TextAlign.left;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            children: [
              const SizedBox(height: 20),

              /// =========================
              /// LOGO
              /// =========================
              Image.asset("assets/icons/logo.png", height: 80),

              const SizedBox(height: 28),

              Container(
                width: screenWidth,

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    KText(
                      text: languagesController.tr("REGISTER"),
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// =========================
              /// PERSONAL INFORMATION
              /// =========================
              _fieldLabel(languagesController.tr("FULL_NAME")),

              const SizedBox(height: 7),

              _authField(
                controller: signUpController.resellerNameController,
                hintText: languagesController.tr("ENTER_YOUR_FULL_NAME"),
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 14),

              _fieldLabel(languagesController.tr("CONTACT_NAME")),

              const SizedBox(height: 7),

              _authField(
                controller: signUpController.contactNameController,
                hintText: languagesController.tr("ENTER_CONTACT_NAME"),
                icon: Icons.badge_outlined,
              ),

              const SizedBox(height: 14),

              _fieldLabel(languagesController.tr("PHONE_NUMBER")),

              const SizedBox(height: 7),

              _authField(
                controller: signUpController.phoneController,
                hintText: languagesController.tr("ENTER_PHONE_NUMBER"),
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 14),

              _fieldLabel(languagesController.tr("EMAIL"), optional: true),

              const SizedBox(height: 7),

              _authField(
                controller: signUpController.emailController,
                hintText: languagesController.tr("EMAIL_ADDRESS"),
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              /// =========================
              /// LOCATION INFORMATION
              /// =========================
              _fieldLabel(languagesController.tr("CURRENCY")),

              const SizedBox(height: 7),

              _currencyDropdown(screenHeight),

              const SizedBox(height: 14),

              _fieldLabel(languagesController.tr("COUNTRY_OF_RESIDENCE")),

              const SizedBox(height: 7),

              _countryDropdown(screenHeight),

              const SizedBox(height: 14),

              _fieldLabel(languagesController.tr("PROVINCE"), optional: true),

              const SizedBox(height: 7),

              _provinceDropdown(screenHeight),

              const SizedBox(height: 14),

              _fieldLabel(languagesController.tr("DISTRICT"), optional: true),

              const SizedBox(height: 7),

              _districtDropdown(screenHeight),

              const SizedBox(height: 25),

              /// =========================
              /// PROFILE IMAGE
              /// =========================
              Center(
                child: Obx(
                  () => GestureDetector(
                    onTap: () async {
                      await signUpController.uploadImage();

                      if (mounted) {
                        setState(() {});
                      }
                    },
                    child: DottedBorder(
                      color: AppColors.primaryColor.withOpacity(.45),
                      strokeWidth: 1.5,
                      dashPattern: const [6, 4],
                      borderType: BorderType.Circle,
                      child: Container(
                        height: 112,
                        width: 112,
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: CircleAvatar(
                          backgroundColor: const Color(0xffF4F7FC),
                          child:
                              signUpController.selectedImagePath.value.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/icons/upload_image.png",
                                      height: 28,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      languagesController.tr("UPLOAD_PHOTO"),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.fontColor,
                                      ),
                                    ),
                                  ],
                                )
                              : ClipOval(
                                  child: Image.file(
                                    signUpController.imageFile!,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// =========================
              /// IDENTITY
              /// =========================
              _fieldLabel(
                languagesController.tr("IDENTITY_ATTACHMENT"),
                optional: true,
              ),

              const SizedBox(height: 8),

              Obx(
                () => _uploadBox(
                  hasImage:
                      signUpController.selectedIdentityPath.value.isNotEmpty,
                  imagePath: signUpController.selectedIdentityPath.value,
                  emptyText: languagesController.tr(
                    "TAP_TO_UPLOAD_IDENTITY_IMAGE",
                  ),
                  onTap: () async {
                    await signUpController.uploadIdentityAttachment();

                    if (mounted) {
                      setState(() {});
                    }
                  },
                  onRemove: () {
                    signUpController.selectedIdentityPath.value = '';
                  },
                ),
              ),

              const SizedBox(height: 16),

              /// =========================
              /// EXTRA PROOF
              /// =========================
              _fieldLabel(
                languagesController.tr("EXTRA_PROOF"),
                optional: true,
              ),

              const SizedBox(height: 8),

              Obx(
                () => _uploadBox(
                  hasImage:
                      signUpController.selectedExtraProofPath.value.isNotEmpty,
                  imagePath: signUpController.selectedExtraProofPath.value,
                  emptyText: languagesController.tr(
                    "TAP_TO_UPLOAD_EXTRA_PROOF",
                  ),
                  onTap: () async {
                    await signUpController.uploadExtraOptionalProof();

                    if (mounted) {
                      setState(() {});
                    }
                  },
                  onRemove: () {
                    signUpController.selectedExtraProofPath.value = '';
                  },
                ),
              ),

              const SizedBox(height: 22),

              /// =========================
              /// SECURITY
              /// =========================
              _fieldLabel(
                languagesController.tr("ENTER_YOUR_PIN"),
                optional: true,
              ),

              const SizedBox(height: 7),

              _authField(
                controller: signUpController.pinController,
                hintText: languagesController.tr("NEW_PIN"),
                icon: Icons.pin_outlined,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 14),

              _fieldLabel(
                languagesController.tr("CONFIRM_PIN"),
                optional: true,
              ),

              const SizedBox(height: 7),

              _authField(
                controller: signUpController.confirmPinController,
                hintText: languagesController.tr("CONFIRM_PIN"),
                icon: Icons.verified_user_outlined,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 14),

              _fieldLabel(languagesController.tr("PASSWORD")),

              const SizedBox(height: 7),

              _authField(
                controller: signUpController.passwordController,
                hintText: languagesController.tr("PASSWORD"),
                icon: Icons.lock_outline,
                obscureText: !isPasswordVisible,
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                  child: Icon(
                    isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 21,
                    color: AppColors.fontColor,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              _fieldLabel(languagesController.tr("CONFIRM_PASSWORD")),

              const SizedBox(height: 7),

              _authField(
                controller: signUpController.confirmPassController,
                hintText: languagesController.tr("CONFIRM_PASSWORD"),
                icon: Icons.lock_reset_outlined,
                obscureText: !isConfirmPasswordVisible,
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      isConfirmPasswordVisible = !isConfirmPasswordVisible;
                    });
                  },
                  child: Icon(
                    isConfirmPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 21,
                    color: AppColors.fontColor,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// =========================
              /// SIGN UP BUTTON
              /// =========================
              Obx(
                () => DefaultButton1(
                  buttonName: signUpController.isLoading.value
                      ? languagesController.tr("PLEASE_WAIT")
                      : languagesController.tr("REGISTER"),
                  height: 50,
                  onpressed: () async {
                    if (signUpController.isLoading.value) {
                      return;
                    }

                    final error = signUpController.validateInputs();

                    if (error != null) {
                      Get.snackbar(
                        languagesController.tr("INVALID_INPUT"),
                        error,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    await signUpController.registernow();
                  },
                ),
              ),

              const SizedBox(height: 22),

              /// =========================
              /// ALREADY REGISTERED
              /// =========================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: KText(
                      text: languagesController.tr("ALREADY_REGISTERED"),
                      color: AppColors.fontColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: KText(
                      text: languagesController.tr("LOGIN"),
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 45),

              /// =========================
              /// SOCIAL SECTION
              /// =========================
              _socialSection(screenWidth),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("--"),
                  KText(
                    text: languagesController.tr("FIND_US_ON"),
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  const Text("--"),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text, {bool optional = false}) {
    return Row(
      mainAxisAlignment: isRtl
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Flexible(
          child: KText(
            text: text,
            color: const Color(0xff233F78),
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 5),
          KText(
            text: "(${languagesController.tr("OPTIONAL")})",
            color: AppColors.fontColor,
            fontSize: 12,
          ),
        ],
      ],
    );
  }

  Widget _authField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.fontColor.withOpacity(.22),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(.035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 13),

          Icon(icon, size: 20, color: AppColors.fontColor.withOpacity(.8)),

          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              textAlign: fieldTextAlign,
              cursorColor: AppColors.primaryColor,
              style: TextStyle(
                color: const Color(0xff233F78),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(
                  color: AppColors.fontColor.withOpacity(.7),
                  fontSize: 14,
                ),
                isDense: true,
              ),
            ),
          ),

          if (suffixIcon != null) suffixIcon,

          const SizedBox(width: 13),
        ],
      ),
    );
  }

  Widget _dropdownWrapper({required Widget child}) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.fontColor.withOpacity(.22),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(.035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _dropdownIcon() {
    return Icon(
      FontAwesomeIcons.chevronDown,
      color: AppColors.primaryColor,
      size: 14,
    );
  }

  TextStyle _dropdownTextStyle(double screenHeight) {
    return TextStyle(
      fontSize: 14,
      color: const Color(0xff233F78),
      fontWeight: FontWeight.w500,
    );
  }

  // =====================================================
  // CURRENCY DROPDOWN
  // =====================================================

  Widget _currencyDropdown(double screenHeight) {
    return _dropdownWrapper(
      child: Obx(() {
        final List<Currency> currencies =
            currencyController.allcurrencylist.value.data?.currencies ??
            <Currency>[];

        final List<Currency> usable = currencies
            .where((currency) => currency.id != null)
            .toList();

        final String? selectedCurrencyId =
            signUpController.currencyId.value.isEmpty
            ? null
            : signUpController.currencyId.value;

        final bool selectedExists =
            selectedCurrencyId != null &&
            usable.any(
              (currency) => currency.id.toString() == selectedCurrencyId,
            );

        final String? currentValue = selectedExists ? selectedCurrencyId : null;

        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: currentValue,
            dropdownColor: Colors.white,
            icon: _dropdownIcon(),
            borderRadius: BorderRadius.circular(12),
            hint: Align(
              alignment: fieldAlignment,
              child: Text(
                languagesController.tr("CURRENCY"),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.fontColor.withOpacity(.7),
                  fontSize: 14,
                ),
              ),
            ),
            selectedItemBuilder: (context) {
              return usable.map<Widget>((currency) {
                return Align(
                  alignment: fieldAlignment,
                  child: Text(
                    _currencyName(currency),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _dropdownTextStyle(screenHeight),
                  ),
                );
              }).toList();
            },
            items: usable.map<DropdownMenuItem<String>>((currency) {
              return DropdownMenuItem<String>(
                value: currency.id.toString(),
                child: Align(
                  alignment: fieldAlignment,
                  child: Text(
                    _currencyName(currency),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _dropdownTextStyle(screenHeight),
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }

              signUpController.currencyId.value = value;
            },
          ),
        );
      }),
    );
  }

  String _currencyName(Currency currency) {
    final name = (currency.name ?? '').trim();

    final code = (currency.code ?? '').trim();

    final symbol = (currency.symbol ?? '').trim();

    if (name.isNotEmpty && code.isNotEmpty) {
      return "$name ($code)";
    }

    if (code.isNotEmpty && symbol.isNotEmpty) {
      return "$code ($symbol)";
    }

    if (code.isNotEmpty) {
      return code;
    }

    if (symbol.isNotEmpty) {
      return symbol;
    }

    return name;
  }

  // =====================================================
  // COUNTRY DROPDOWN
  // =====================================================

  Widget _countryDropdown(double screenHeight) {
    return _dropdownWrapper(
      child: Obx(() {
        final countries =
            countryListController.allcountryListData.value.data?.countries ??
            <dynamic>[];

        final String? selectedCountryId =
            signUpController.countryId.value.isEmpty
            ? null
            : signUpController.countryId.value;

        final bool selectedExists =
            selectedCountryId != null &&
            countries.any(
              (country) =>
                  ((country?.id) ?? '').toString() == selectedCountryId,
            );

        final String? currentValue = selectedExists ? selectedCountryId : null;

        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: currentValue,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            icon: _dropdownIcon(),
            hint: Align(
              alignment: fieldAlignment,
              child: Text(
                languagesController.tr("COUNTRY_OF_RESIDENCE"),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.fontColor.withOpacity(.7),
                  fontSize: 14,
                ),
              ),
            ),
            selectedItemBuilder: (context) {
              return countries.map<Widget>((country) {
                final name = ((country?.countryName) ?? '').toString();

                return Align(
                  alignment: fieldAlignment,
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _dropdownTextStyle(screenHeight),
                  ),
                );
              }).toList();
            },
            items: countries.map<DropdownMenuItem<String>>((country) {
              final id = ((country?.id) ?? '').toString();

              final name = ((country?.countryName) ?? '').toString();

              final flagUrl = ((country?.countryFlagImageUrl) ?? '').toString();

              return DropdownMenuItem<String>(
                value: id,
                child: Row(
                  children: [
                    if (flagUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          flagUrl,
                          height: 24,
                          width: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox();
                          },
                        ),
                      ),
                    if (flagUrl.isNotEmpty) const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _dropdownTextStyle(screenHeight),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }

              dynamic picked;

              for (final country in countries) {
                if (((country?.id) ?? '').toString() == value) {
                  picked = country;
                  break;
                }
              }

              signUpController.countryId.value = value;

              selectedCountry = ((picked?.countryName) ?? '').toString();

              setState(() {});
            },
          ),
        );
      }),
    );
  }

  // =====================================================
  // PROVINCE DROPDOWN
  // =====================================================

  Widget _provinceDropdown(double screenHeight) {
    return _dropdownWrapper(
      child: Obx(() {
        final provinces =
            provinceController.allprovincelist.value.data?.provinces ??
            <dynamic>[];

        final String? selectedProvinceId =
            signUpController.provinceId.value.isEmpty
            ? null
            : signUpController.provinceId.value;

        final bool selectedExists =
            selectedProvinceId != null &&
            provinces.any(
              (province) =>
                  ((province?.id) ?? '').toString() == selectedProvinceId,
            );

        final String? currentValue = selectedExists ? selectedProvinceId : null;

        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: currentValue,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            icon: _dropdownIcon(),
            hint: Align(
              alignment: fieldAlignment,
              child: Text(
                languagesController.tr("PROVINCE"),
                style: TextStyle(
                  color: AppColors.fontColor.withOpacity(.7),
                  fontSize: 14,
                ),
              ),
            ),
            selectedItemBuilder: (context) {
              return provinces.map<Widget>((province) {
                final name = ((province?.provinceName) ?? '').toString();

                return Align(
                  alignment: fieldAlignment,
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _dropdownTextStyle(screenHeight),
                  ),
                );
              }).toList();
            },
            items: provinces.map<DropdownMenuItem<String>>((province) {
              final id = ((province?.id) ?? '').toString();

              final name = ((province?.provinceName) ?? '').toString();

              return DropdownMenuItem<String>(
                value: id,
                child: Align(
                  alignment: fieldAlignment,
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _dropdownTextStyle(screenHeight),
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }

              dynamic picked;

              for (final province in provinces) {
                if (((province?.id) ?? '').toString() == value) {
                  picked = province;
                  break;
                }
              }

              signUpController.provinceId.value = value;

              selectedProvince = ((picked?.provinceName) ?? '').toString();

              setState(() {});
            },
          ),
        );
      }),
    );
  }

  // =====================================================
  // DISTRICT DROPDOWN
  // =====================================================

  Widget _districtDropdown(double screenHeight) {
    return _dropdownWrapper(
      child: Obx(() {
        final districts =
            districtController.alldistrictList.value.data?.districts ??
            <dynamic>[];

        final String? selectedDistrictId =
            signUpController.districtID.value.isEmpty
            ? null
            : signUpController.districtID.value;

        final bool selectedExists =
            selectedDistrictId != null &&
            districts.any(
              (district) =>
                  ((district?.id) ?? '').toString() == selectedDistrictId,
            );

        final String? currentValue = selectedExists ? selectedDistrictId : null;

        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: currentValue,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            icon: _dropdownIcon(),
            hint: Align(
              alignment: fieldAlignment,
              child: Text(
                languagesController.tr("DISTRICT"),
                style: TextStyle(
                  color: AppColors.fontColor.withOpacity(.7),
                  fontSize: 14,
                ),
              ),
            ),
            selectedItemBuilder: (context) {
              return districts.map<Widget>((district) {
                final name = ((district?.districtName) ?? '').toString();

                return Align(
                  alignment: fieldAlignment,
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _dropdownTextStyle(screenHeight),
                  ),
                );
              }).toList();
            },
            items: districts.map<DropdownMenuItem<String>>((district) {
              final id = ((district?.id) ?? '').toString();

              final name = ((district?.districtName) ?? '').toString();

              return DropdownMenuItem<String>(
                value: id,
                child: Align(
                  alignment: fieldAlignment,
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _dropdownTextStyle(screenHeight),
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }

              dynamic picked;

              for (final district in districts) {
                if (((district?.id) ?? '').toString() == value) {
                  picked = district;
                  break;
                }
              }

              signUpController.districtID.value = value;

              selectedDistrict = ((picked?.districtName) ?? '').toString();

              setState(() {});
            },
          ),
        );
      }),
    );
  }

  // =====================================================
  // UPLOAD BOX
  // =====================================================

  Widget _uploadBox({
    required bool hasImage,
    required String imagePath,
    required String emptyText,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        color: AppColors.primaryColor.withOpacity(.4),
        strokeWidth: 1.4,
        dashPattern: const [6, 4],
        borderType: BorderType.RRect,
        radius: const Radius.circular(10),
        child: Container(
          width: double.infinity,
          height: 115,
          decoration: BoxDecoration(
            color: const Color(0xffFAFBFE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: hasImage
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.file(File(imagePath), fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 7,
                      right: 7,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/icons/upload_image.png", height: 28),
                    const SizedBox(height: 7),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        emptyText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.fontColor,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // =====================================================
  // SOCIAL FOOTER
  // =====================================================

  Widget _socialSection(double screenWidth) {
    return SizedBox(
      height: 60,
      width: screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              whatsapp();
            },
            child: const Icon(FontAwesomeIcons.whatsapp, size: 40),
          ),

          const SizedBox(width: 50),

          GestureDetector(
            onTap: () {
              showSocialPopup(context);
            },
            child: Image.asset("assets/icons/social-media.png", height: 40),
          ),

          const SizedBox(width: 50),

          GestureDetector(
            onTap: () {
              _makePhoneCall(phoneNumber);
            },
            child: const Icon(FontAwesomeIcons.phone, size: 28),
          ),
        ],
      ),
    );
  }
}

Future<void> _makePhoneCall(String number) async {
  final Uri url = Uri(scheme: 'tel', path: number);

  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}
