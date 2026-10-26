import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teknurpay/widgets/bottomsheet.dart';
import 'package:lottie/lottie.dart';
import 'package:teknurpay/controllers/bundle_controller.dart';
import 'package:teknurpay/controllers/confirm_pin_controller.dart';
import 'package:teknurpay/controllers/country_list_controller.dart';
import 'package:teknurpay/controllers/service_controller.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/global_controller/page_controller.dart';
import 'package:teknurpay/helpers/price.dart';
import 'package:teknurpay/utils/colors.dart';
import '../widgets/custom_text.dart';

class SocialBundles extends StatefulWidget {
  const SocialBundles({super.key});

  @override
  State<SocialBundles> createState() => _SocialBundlesState();
}

class _SocialBundlesState extends State<SocialBundles> {
  final serviceController = Get.find<ServiceController>();
  final bundleController = Get.find<BundleController>();
  final languagesController = Get.put(LanguagesController());
  final confirmPinController = Get.find<ConfirmPinController>();
  final ScrollController scrollController = ScrollController();
  final box = GetStorage();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    confirmPinController.numberController.clear();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    bundleController.finalList.clear();
    bundleController.initialpage = 1;
    scrollController.addListener(_loadNextPageWhenNeeded);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      serviceController.fetchservices();
      bundleController.fetchallbundles();
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(_loadNextPageWhenNeeded);
    scrollController.dispose();
    super.dispose();
  }

  // Infinite-scroll pagination, formerly mixed into the RefreshIndicator callback.
  void _loadNextPageWhenNeeded() {
    if (!scrollController.hasClients || bundleController.isLoading.value) {
      return;
    }

    final int totalPages =
        bundleController.allbundleslist.value.payload?.pagination?.totalPages ??
        0;
    if (totalPages <= 0 || bundleController.initialpage >= totalPages) {
      return;
    }
    if (scrollController.position.extentAfter > 0) return;

    bundleController.initialpage++;
    bundleController.fetchallbundles();
  }

  // Pull-down refresh loads the first page again.
  Future<void> _refreshBundles() async {
    bundleController.initialpage = 1;
    bundleController.finalList.clear();
    await Future<void>.sync(() => bundleController.fetchallbundles());
  }

  void _showBundleDialog(int index) {
    final data = bundleController.finalList[index];
    // ID / NUMBER selector is available only for IMO bundles.
    final String companyCode =
        (data.service?.company?.companyCode?.toString() ?? '')
            .trim()
            .toUpperCase();
    final bool isImo = companyCode == 'IMO';
    print(companyCode);
    box.write('bundleID', data.id.toString());

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        content: SocialdialogBox(
          isImo: isImo,
          companyname: data.service!.company!.companyName.toString(),
          title: data.bundleTitle,
          validity: data.validityType,
          buyingprice: data.buyingPrice,
          sellingprice: data.sellingPrice,
          imagelink: data.service!.company!.companyLogo.toString(),
        ),
      ),
    );
  }

  // Compact reusable price row for the right-hand column of a bundle card.
  // The label and amount are width-constrained so large values cannot overflow.
  Widget _buildCompactPriceRow({
    required String labelKey,
    required String price,
    required String currency,
    required Color color,
  }) {
    return SizedBox(
      height: 19,
      child: Row(
        children: [
          SizedBox(
            width: 39,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Obx(
                () => KText(
                  text: languagesController.tr(labelKey),
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: FittedBox(
              alignment: Alignment.centerRight,
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PriceTextView(
                    price: price,
                    textStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    currency,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: color,
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

  Widget _buildBundleItem(int index, double screenWidth) {
    final data = bundleController.finalList[index];
    final currency = box.read('currency_code')?.toString() ?? '';
    final priceColumnWidth = (screenWidth * 0.365)
        .clamp(108.0, 160.0)
        .toDouble();

    return GestureDetector(
      onTap: () => _showBundleDialog(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 2,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: Image.network(
                  data.service!.company!.companyLogo.toString(),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_not_supported_outlined,
                    size: 24,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  data.bundleTitle.toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(height: 35, width: 1, color: const Color(0xFFE9EDF2)),
              const SizedBox(width: 8),
              // SALE and BUY sit vertically on the right, on the same line
              // as the logo/title. This keeps each bundle card compact.
              SizedBox(
                width: priceColumnWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCompactPriceRow(
                      labelKey: 'SALE',
                      price: data.sellingPrice.toString(),
                      currency: currency,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 5),
                    _buildCompactPriceRow(
                      labelKey: 'BUY',
                      price: data.buyingPrice.toString(),
                      currency: currency,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Single RefreshIndicator and ListView for loading and loaded states.
  Widget _buildBundleList(double screenWidth) {
    return RefreshIndicator(
      onRefresh: _refreshBundles,
      child: ListView.separated(
        controller: scrollController,
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: bundleController.finalList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 2),
        itemBuilder: (context, index) => _buildBundleItem(index, screenWidth),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Mypagecontroller mypagecontroller = Get.find();
    final double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: mypagecontroller.goBack,
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: Image.asset(
                        'assets/icons/backicon.png',
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(
                      () => Text(
                        languagesController.tr('COMMUNICATION_PACKAGES'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: (screenWidth * 0.045)
                              .clamp(13.0, 17.0)
                              .toDouble(),
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => CustomFullScreenSheet.show(context),
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: Image.asset(
                        'assets/icons/drawericon.png',
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Obx(() {
                  if (bundleController.isLoading.value &&
                      bundleController.finalList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.grey),
                    );
                  }
                  return _buildBundleList(screenWidth);
                }),
              ),
            ),
            Obx(
              () =>
                  bundleController.isLoading.value &&
                      bundleController.finalList.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// IMO NUMBER input: keep a single leading '+' in both the field and the
// shared ConfirmPinController.numberController, even after editing or pasting.
class _InternationalNumberFormatter extends TextInputFormatter {
  const _InternationalNumberFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final rawText = newValue.text;
    final cursorPosition = newValue.selection.baseOffset
        .clamp(0, rawText.length)
        .toInt();
    final digitsBeforeCursor = RegExp(
      r'[0-9]',
    ).allMatches(rawText.substring(0, cursorPosition)).length;
    final digits = rawText.replaceAll(RegExp(r'[^0-9]'), '');
    final formatted = '+$digits';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: (digitsBeforeCursor + 1).clamp(1, formatted.length).toInt(),
      ),
    );
  }
}

class SocialdialogBox extends StatefulWidget {
  SocialdialogBox({
    super.key,
    this.title,
    this.validity,
    this.buyingprice,
    this.sellingprice,
    this.imagelink,
    this.companyname,
    this.isImo = false,
  });

  // Only IMO bundles require choosing between ID and NUMBER.
  final bool isImo;
  String? companyname;
  String? title;
  String? validity;
  String? buyingprice;
  String? sellingprice;
  String? imagelink;

  @override
  State<SocialdialogBox> createState() => _SocialdialogBoxState();
}

class _SocialdialogBoxState extends State<SocialdialogBox> {
  String selectedCode = "+93";

  final countrylistController = Get.find<CountryListController>();

  final confirmPinController = Get.find<ConfirmPinController>();

  final box = GetStorage();

  final FocusNode _focusNode = FocusNode();

  LanguagesController languagesController = Get.put(LanguagesController());

  @override
  void initState() {
    super.initState();

    // Always start with no account type selected. For IMO, the user must
    // select ID or NUMBER; other companies never send an account-type key.
    confirmPinController.rechargebleAccountType.value = '';
    confirmPinController.numberController.clear();
    confirmPinController.pinController.clear();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    // Avoid passing the account-type field in other recharge flows.
    confirmPinController.rechargebleAccountType.value = '';
    super.dispose();
  }

  // Each price fits in half of the dialog's horizontal price row.
  Widget _buildDialogPriceRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String amount,
    required Color amountColor,
  }) {
    final currency = box.read('currency_code')?.toString() ?? '';

    return SizedBox(
      height: 24,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 5),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              amount,
              maxLines: 1,
              style: TextStyle(
                color: amountColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              currency,
              maxLines: 1,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Clean, text-only account-type buttons (no icons).
  Widget _buildAccountTypeOption(String type, bool isSelected) {
    final bool isId = type == 'ID';
    final Color accentColor = isId
        ? AppColors.primaryColor
        : const Color(0xFF079A87);
    final Color lightColor = isId
        ? const Color(0xFFEEF4FF)
        : const Color(0xFFEAF9F5);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!widget.isImo) return;
          if (confirmPinController.rechargebleAccountType.value != type) {
            // NUMBER begins with '+'. ID remains a normal, empty text input.
            final prefix = type == 'NUMBER' ? '+' : '';
            confirmPinController.numberController.value = TextEditingValue(
              text: prefix,
              selection: TextSelection.collapsed(offset: prefix.length),
            );
          }
          // Send exactly ID or NUMBER, never the company code IMO.
          confirmPinController.rechargebleAccountType.value = type;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? null : lightColor,
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor,
                      Color.lerp(accentColor, Colors.black, 0.16)!,
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: isSelected ? accentColor : accentColor.withOpacity(0.20),
              width: isSelected ? 1.6 : 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(isSelected ? 0.20 : 0.04),
                blurRadius: isSelected ? 10 : 4,
                offset: Offset(0, isSelected ? 4 : 2),
              ),
            ],
          ),
          child: Text(
            languagesController.tr(type),
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.35,
              color: isSelected ? Colors.white : accentColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: (screenHeight * 0.80).clamp(0.0, 600.0).toDouble(),
      width: screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Obx(
        () => confirmPinController.isLoading.value == false
            ? ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,

                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xff1890FF).withOpacity(0.3),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Company Logo
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Image.network(
                                widget.imagelink.toString(),
                                height: 60,
                              ),
                            ),
                            SizedBox(height: 8),

                            // Company Name
                            Text(
                              widget.companyname.toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 5),

                            // Bundle Title
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Flexible(
                                    flex: 2,
                                    child: Text(
                                      languagesController.tr('BUNDLE_TITLE'),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      widget.title.toString(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),

                            // Buy and Sale appear side by side in one row.
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildDialogPriceRow(
                                      icon: Icons.shopping_bag_outlined,
                                      iconColor: const Color(0xff1890FF),
                                      label: languagesController.tr('BUY'),
                                      amount: widget.buyingprice.toString(),
                                      amountColor: Colors.black,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    height: 24,
                                    width: 1,
                                    color: Colors.grey.shade200,
                                  ),
                                  Expanded(
                                    child: _buildDialogPriceRow(
                                      icon: Icons.sell_outlined,
                                      iconColor: Colors.green,
                                      label: languagesController.tr('SALE'),
                                      amount: widget.sellingprice.toString(),
                                      amountColor: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 8),

                    // Only IMO needs the ID / NUMBER selector.
                    if (widget.isImo) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Obx(
                          () => Text(
                            languagesController.tr('SELECT_ACCOUNT_TYPE'),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Obx(() {
                        final selectedType =
                            confirmPinController.rechargebleAccountType.value;
                        return Row(
                          children: [
                            _buildAccountTypeOption('ID', selectedType == 'ID'),
                            const SizedBox(width: 12),
                            _buildAccountTypeOption(
                              'NUMBER',
                              selectedType == 'NUMBER',
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 5),
                    ],

                    // IMO: input hidden until an option is chosen.
                    // Other companies: show the original Enter ID field.
                    Obx(() {
                      final selectedType =
                          confirmPinController.rechargebleAccountType.value;

                      if (widget.isImo && selectedType.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final isNumber = widget.isImo && selectedType == 'NUMBER';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isNumber)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                right: 4,
                                bottom: 8,
                              ),
                              child: Text(
                                "${languagesController.tr('ENTER_WITH_COUNTRY_CODE')} (+93, +98, +90)",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.phone_android,
                                    color: Color(0xff1890FF),
                                    size: 22,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      // Rebuilds the input when changing ID / NUMBER,
                                      // including its keyboard configuration.
                                      key: ValueKey(
                                        'account_input_$selectedType',
                                      ),
                                      controller:
                                          confirmPinController.numberController,
                                      keyboardType: isNumber
                                          ? TextInputType.phone
                                          : TextInputType.text,
                                      // Keep '+' visible and non-removable for NUMBER.
                                      // The shared controller contains '+930...' directly.
                                      inputFormatters: isNumber
                                          ? [
                                              const _InternationalNumberFormatter(),
                                            ]
                                          : null,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: widget.isImo
                                            ? (isNumber
                                                  ? languagesController.tr(
                                                      "ENTER_NUMBER",
                                                    )
                                                  : languagesController.tr(
                                                      "ENTER_ID",
                                                    ))
                                            : languagesController.tr(
                                                'ENTER_ID',
                                              ),
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 15,
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                    SizedBox(height: 5),

                    // PIN Input
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 50,
                        width: 130,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 1.5,
                            color: Colors.grey.shade200,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextField(
                              maxLength: 4,
                              controller: confirmPinController.pinController,
                              keyboardType: TextInputType.phone,
                              textAlign: TextAlign.center,
                              obscureText: true,
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: languagesController.tr("PIN"),
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 5),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: () {
                              final selectedType = confirmPinController
                                  .rechargebleAccountType
                                  .value;

                              if (widget.isImo &&
                                  selectedType != 'ID' &&
                                  selectedType != 'NUMBER') {
                                Fluttertoast.showToast(
                                  msg: 'Please select ID or NUMBER',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.TOP,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                                return;
                              }

                              final enteredNumber = confirmPinController
                                  .numberController
                                  .text
                                  .trim();
                              // A lone '+' is not a valid NUMBER.
                              if (enteredNumber.isEmpty ||
                                  (widget.isImo &&
                                      selectedType == 'NUMBER' &&
                                      enteredNumber
                                          .replaceAll(RegExp(r'[^0-9]'), '')
                                          .isEmpty)) {
                                Fluttertoast.showToast(
                                  msg: widget.isImo
                                      ? (selectedType == 'ID'
                                            ? languagesController.tr("ENTER_ID")
                                            : languagesController.tr(
                                                "ENTER_NUMBER",
                                              ))
                                      : languagesController.tr('ENTER_ID'),
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.TOP,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                                return;
                              }

                              if (confirmPinController
                                  .pinController
                                  .text
                                  .isEmpty) {
                                Fluttertoast.showToast(
                                  msg: languagesController.tr("ENTER_YOUR_PIN"),
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.TOP,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                                return;
                              }

                              // Only IMO sends the selected account type.
                              // ID     => rechargeble_account_type: ID
                              // NUMBER => rechargeble_account_type: NUMBER
                              // Other companies omit the account-type key.
                              confirmPinController
                                  .rechargebleAccountType
                                  .value = widget.isImo
                                  ? selectedType
                                  : '';

                              confirmPinController.placeOrder(context);
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.shade400,
                                    Colors.green.shade600,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      languagesController.tr('CONFIRMATION'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  width: 1.5,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.close,
                                    color: Colors.grey.shade700,
                                    size: 20,
                                  ),
                                  SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      languagesController.tr('CANCEL'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Center(
                child: Container(
                  height: 250,
                  width: 250,
                  child: Lottie.asset('assets/loties/recharge.json'),
                ),
              ),
      ),
    );
  }
}
