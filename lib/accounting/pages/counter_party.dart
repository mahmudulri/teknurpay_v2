import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:teknurpay/accounting/controllers/counterparty_details_controller.dart';
import 'package:teknurpay/accounting/create_counterpary_screen.dart';
import 'package:teknurpay/helpers/language_changer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../global_controller/languages_controller.dart';
import '../../utils/colors.dart';
import '../controllers/accounting_currency_controller.dart';
import '../controllers/counter_party_controller.dart';
import '../controllers/delete_counterparty_controller.dart';
import '../update_counterparty_screen.dart';
import '../view_counter_party_screen.dart';

class CounterParty extends StatefulWidget {
  const CounterParty({super.key, this.officeName});

  /// The Counterparty Details API does not return an office name.
  /// Pass the currently selected office name from the parent screen when available.
  final String? officeName;

  @override
  State<CounterParty> createState() => _CounterPartyState();
}

class _CounterPartyState extends State<CounterParty> {
  final LanguagesController languagesController =
      Get.find<LanguagesController>();

  final CounterPartyController counterPartyController = Get.put(
    CounterPartyController(),
  );

  final AccountingCurrencyController accountingCurrencyController =
      Get.find<AccountingCurrencyController>();

  final DeleteCounterpartyController deleteCounterpartyController = Get.put(
    DeleteCounterpartyController(),
  );

  final CounterpartyDetailsController detailsController = Get.put(
    CounterpartyDetailsController(),
  );

  @override
  void initState() {
    super.initState();
    counterPartyController.initialpage = 1;
    counterPartyController.finalList.clear();
    counterPartyController.fetchcounterpary();

    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;

    // Bottom-এর একটু আগে next page load হবে
    if (position.extentAfter < 250) {
      _loadMoreCounterParties();
    }
  }

  Future<void> _loadMoreCounterParties() async {
    if (_isLoadingMore) return;

    final int totalPages =
        counterPartyController
            .counterparties
            .value
            .payload
            ?.pagination
            ?.totalPages ??
        0;

    final int currentPage = counterPartyController.initialpage;

    if (totalPages <= 0) return;

    // Last page
    if (currentPage >= totalPages) {
      debugPrint("Counterparty: Last page reached");
      return;
    }

    final int nextPage = currentPage + 1;

    if (mounted) {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      counterPartyController.initialpage = nextPage;

      await counterPartyController.fetchcounterpary();
    } catch (e) {
      // Error হলে আগের page-এ ফিরে যাবে
      counterPartyController.initialpage = currentPage;

      debugPrint("Counterparty load more error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  final ScrollController scrollController = ScrollController();

  /// Load and refresh more

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  bool _isLoadingMore = false;
  String getDisplayValue(dynamic value, {String fallback = 'N/A'}) {
    if (value == null) {
      return fallback;
    }

    final String text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return fallback;
    }

    return text;
  }

  Color getTypeColor(String type) {
    switch (type.trim().toLowerCase()) {
      case 'customer':
        return AppColors.primaryColor;

      case 'supplier':
        return AppColors.primarycolor2;

      case 'both':
        return AppColors.primarycolor2;

      default:
        return AppColors.primaryColor;
    }
  }

  IconData getTypeIcon(String type) {
    switch (type.trim().toLowerCase()) {
      case 'customer':
        return Icons.person_outline_rounded;

      case 'supplier':
        return Icons.inventory_2_outlined;

      case 'both':
        return Icons.people_alt_outlined;

      default:
        return Icons.account_circle_outlined;
    }
  }

  void openCounterPartyDetails(dynamic data) {
    Get.to(
      () => ViewCounterPartyScreen(
        partyID: data.id.toString(),
        partyName: data.name.toString(),
        partyType: data.type.toString(),
        phoneNumber: data.phone.toString(),
        emailaddress: data.email.toString(),
        defaultCurrency: data.defaultCurrencyCode.toString(),
      ),
    );
  }

  void openActionDialog(BuildContext context, dynamic data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondaryColor,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.listbuilderboxColor,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 42,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9E0E8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.business_center_outlined,
                          color: Color(0xFF2584F4),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getDisplayValue(data.name),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1D2939),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              getDisplayValue(data.phone),
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF7A8794),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);

                    Get.to(
                      () => UpdateCounterpartyScreen(
                        partyID: data.id.toString(),
                        partyName: data.name.toString(),
                        partyType: data.type.toString(),
                        phoneNumber: data.phone.toString(),
                        emailaddress: data.email.toString(),
                        currency: data.defaultCurrencyCode.toString(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF2584F4),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          languagesController.tr("EDIT"),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF263445),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Color(0xFF98A2B3),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);

                    deleteCounterpartyController.deleteparty(
                      data.id.toString(),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFE5484D),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          languagesController.tr("DELETE"),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFE5484D),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Color(0xFFE5484D),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildCounterPartyCard({
    required BuildContext context,
    required dynamic data,
  }) {
    final String name = getDisplayValue(data.name);
    final String type = getDisplayValue(data.type);
    final String phone = getDisplayValue(data.phone);
    final String totalaccounts = getDisplayValue(data.accountsCount);
    final Color typeColor = getTypeColor(type);
    final IconData typeIcon = getTypeIcon(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        color: AppColors.listbuilderboxColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primarycolor2.withValues(alpha: 0.24),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF40566B).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            openCounterPartyDetails(data);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(9, 8, 5, 8),
            child: Row(
              children: [
                /// Left type indicator
                Container(
                  height: 46,
                  width: 3,
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(width: 9),

                /// Compact counterparty icon
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: typeColor.withValues(alpha: 0.13),
                    ),
                  ),
                  child: Icon(typeIcon, size: 20, color: typeColor),
                ),

                const SizedBox(width: 10),

                /// Name, type and phone
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E2936),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    totalaccounts,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                /// More actions
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minHeight: 34,
                    minWidth: 34,
                  ),
                  splashRadius: 18,
                  onPressed: () async {
                    final String counterpartyId = data.id.toString();

                    /// Show a blocking waiting dialog while the latest
                    /// counterparty summary is being calculated/fetched.
                    _showCalculatingDialog();

                    final bool success = await detailsController.fetchdetails(
                      counterpartyId,
                    );

                    _hideCalculatingDialog();

                    if (!mounted) {
                      return;
                    }

                    if (success) {
                      openShareDialog(context);
                    } else {
                      Get.snackbar(
                        languagesController.tr("ERROR"),
                        detailsController.errorMessage.value,
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(12),
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  icon: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAFBF0),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.share,
                      size: 20,
                      color: Color(0xFF25D366),
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                /// More actions
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minHeight: 34,
                    minWidth: 34,
                  ),
                  splashRadius: 18,
                  onPressed: () {
                    openActionDialog(context, data);
                  },
                  icon: Container(
                    height: 32,
                    width: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.more_horiz_rounded,
                      size: 20,
                      color: Color(0xFF5F6C79),
                    ),
                  ),
                ),

                const SizedBox(width: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 78,
              width: 78,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.80),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 36,
                color: Color(0xFF83919F),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No counterparty found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF536170),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // String getBalanceRelationText(String? status) {
  //   switch (status?.trim().toLowerCase()) {
  //     case 'receivable':
  //       return languagesController.tr("HE_OWE");

  //     case 'payable':
  //       return languagesController.tr("HE_OWED");

  //     default:
  //       return languagesController.tr("BALANCE_SETTLED");
  //   }
  // }

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString().replaceAll(',', '').trim()) ?? 0;
  }

  String _formatAmount(dynamic value) {
    final double amount = _toDouble(value).abs();
    final bool isWholeNumber = amount == amount.roundToDouble();

    final String rawValue = isWholeNumber
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);

    final List<String> parts = rawValue.split('.');

    final String formattedInteger = parts.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    if (parts.length == 1) {
      return formattedInteger;
    }

    final String decimalPart = parts[1].replaceFirst(RegExp(r'0+$'), '');

    if (decimalPart.isEmpty) {
      return formattedInteger;
    }

    return '$formattedInteger.$decimalPart';
  }

  String _translationKey(dynamic value) {
    final String raw = getDisplayValue(value, fallback: '').trim();

    if (raw.isEmpty) {
      return '';
    }

    return raw
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  String _formatApiLabel(String value) {
    final String raw = value.trim();

    if (raw.isEmpty) {
      return raw;
    }

    /// Keep short uppercase currency codes like AFN, USD, TMN unchanged.
    if (raw.length <= 5 && raw == raw.toUpperCase()) {
      return raw;
    }

    return raw
        .replaceAll('_', ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _translateApiValue(dynamic value, {String fallback = '--'}) {
    final String raw = getDisplayValue(value, fallback: '').trim();

    if (raw.isEmpty) {
      return fallback;
    }

    final String key = _translationKey(raw);

    if (key.isEmpty) {
      return _formatApiLabel(raw);
    }

    final String translated = languagesController.tr(key).trim();

    /// If the translation key does not exist, show a clean API value
    /// instead of exposing the missing translation key.
    if (translated.isEmpty || translated == key) {
      return _formatApiLabel(raw);
    }

    return translated;
  }

  String _currentDate() {
    final DateTime now = DateTime.now();

    return '${now.year}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.day.toString().padLeft(2, '0')}';
  }

  String _balanceTitle(String? status) {
    switch (status?.trim().toLowerCase()) {
      case 'receivable':

        /// The counterparty owes us.
        return languagesController.tr("HE_OWE");

      case 'payable':

        /// The counterparty is owed by us.
        return languagesController.tr("HE_OWED");

      default:
        return languagesController.tr("BALANCE_SETTLED");
    }
  }

  String _translatedOrFallback(String key, String fallback) {
    final String translated = languagesController.tr(key).trim();

    if (translated.isEmpty || translated == key) {
      return fallback;
    }

    return translated;
  }

  void _showCalculatingDialog() {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.listbuilderboxColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const SizedBox(
                    height: 23,
                    width: 23,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _translatedOrFallback("CALCULATING", "Calculating..."),
                        style: const TextStyle(
                          color: Color(0xFF1D2939),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _translatedOrFallback(
                          "PLEASE_WAIT",
                          "Please wait while we prepare the account summary.",
                        ),
                        style: const TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _hideCalculatingDialog() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  String generateCounterPartyShareText() {
    final counterparty = detailsController.alldata.value.data?.counterparty;

    if (counterparty == null) {
      return '';
    }

    final balances = counterparty.summary?.snapshot?.byCurrency ?? [];

    final String name = getDisplayValue(counterparty.name, fallback: '--');

    final String phone = getDisplayValue(counterparty.phone, fallback: '--');

    final String category = _translateApiValue(
      counterparty.type,
      fallback: '--',
    );

    final String officeName = getDisplayValue(widget.officeName, fallback: '');

    final StringBuffer buffer = StringBuffer();

    /// Office name is only added when it was actually provided.
    /// The Counterparty Details API itself does not contain an office field.
    if (officeName.isNotEmpty) {
      buffer.writeln(officeName);
    }

    buffer.writeln('${languagesController.tr("DATE")}: ${_currentDate()}');

    buffer.writeln();
    buffer.writeln('${languagesController.tr("NAME")}: $name');
    buffer.writeln('${languagesController.tr("PHONE")}: $phone');
    buffer.writeln('${languagesController.tr("CATEGORY")}: $category');

    for (final item in balances) {
      final String status = item.status?.toString().trim().toLowerCase() ?? '';

      final String currency = _translateApiValue(
        item.currencyCode,
        fallback: '--',
      );

      final String amount = _formatAmount(item.netBalance);
      final String title = _balanceTitle(status);

      buffer.writeln();
      buffer.writeln('*$title: $amount $currency*');
    }

    return buffer.toString().trim();
  }

  Future<void> shareCounterPartyToWhatsApp() async {
    final String text = generateCounterPartyShareText();

    if (text.trim().isEmpty) {
      Get.snackbar(
        languagesController.tr("ERROR"),
        languagesController.tr("ACCOUNT_INFORMATION_NOT_FOUND"),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final Uri whatsappUrl = Uri.https('wa.me', '/', {'text': text});

    final bool opened = await launchUrl(
      whatsappUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      Get.snackbar(
        languagesController.tr("ERROR"),
        languagesController.tr("UNABLE_TO_OPEN_WHATSAPP"),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void openShareDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.listbuilderboxColor,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Top drag indicator
                Container(
                  height: 4,
                  width: 42,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9E0E8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                /// Copy as Text
                _buildShareAction(
                  icon: Icons.copy_rounded,
                  title: languagesController.tr("COPY_AS_TEXT"),
                  iconColor: AppColors.primaryColor,
                  iconBackground: AppColors.secondaryColor,
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);

                    final String text = generateCounterPartyShareText();

                    await Clipboard.setData(ClipboardData(text: text));

                    Get.snackbar(
                      languagesController.tr("COPPIED"),
                      languagesController.tr(
                        "ACCOUNT_INFORMATION_COPIED_TO_CLIPBOARD",
                      ),
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(12),
                      backgroundColor: AppColors.primaryColor,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.white,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 9),

                /// Send to WhatsApp
                _buildShareAction(
                  icon: Icons.chat_rounded,
                  title: languagesController.tr("SEND_TO_WHATSAPP"),
                  iconColor: const Color(0xFF25D366),
                  iconBackground: const Color(0xFFEAFBF0),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);

                    await shareCounterPartyToWhatsApp();
                  },
                ),

                const SizedBox(height: 9),

                /// Generate Image
                _buildShareAction(
                  icon: Icons.image_outlined,
                  title: languagesController.tr("GENERATE_IMAGE"),
                  iconColor: const Color(0xFF7A5AF8),
                  iconBackground: const Color(0xFFF1EEFF),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);

                    print("Generate Image");
                  },
                ),

                const SizedBox(height: 9),

                /// Generate PDF
                _buildShareAction(
                  icon: Icons.picture_as_pdf_outlined,
                  title: languagesController.tr("GENERATE_PDF"),
                  iconColor: const Color(0xFFD92D20),
                  iconBackground: const Color(0xFFFFEDEC),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);

                    print("Generate PDF");
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareAction({
    required IconData icon,
    required String title,
    required Color iconColor,
    required Color iconBackground,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF263445),
                ),
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFF98A2B3),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                counterPartyController.fetchcounterpary();
              },
              child: Text(
                languagesController.tr("COUNTER_PARTY"),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.fontColor,
                child: Image.asset("assets/icons/telecom.png", height: 25),
              ),
            ),
            const SizedBox(width: 5),
            const LanguageSelectorButton(size: 42, iconSize: 25),
          ],
        ),
        scrolledUnderElevation: 0,
        surfaceTintColor: AppColors.listbuilderboxColor,
        elevation: 0,
        backgroundColor: AppColors.listbuilderboxColor,
        centerTitle: true,
      ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.secondaryColor, AppColors.primarycolor2],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  width: screenWidth,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 28,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      hintText: languagesController.tr("NAME"),
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Container(
                        height: 50,
                        width: 50,
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset("assets/icons/filter.png"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: Obx(() {
                    final bool isLoading =
                        counterPartyController.isLoading.value;

                    final bool hasData =
                        counterPartyController.finalList.isNotEmpty;

                    /// First page loading
                    if (isLoading && !hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    }

                    /// Empty state
                    if (!hasData) {
                      return buildEmptyState();
                    }

                    /// Counter Party List + Load More
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.only(top: 2, bottom: 8),
                      physics: const BouncingScrollPhysics(),
                      itemCount:
                          counterPartyController.finalList.length +
                          (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        /// Bottom pagination loader
                        if (index == counterPartyController.finalList.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Center(
                              child: SizedBox(
                                height: 23,
                                width: 23,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          );
                        }

                        final data = counterPartyController.finalList[index];

                        return buildCounterPartyCard(
                          context: context,
                          data: data,
                        );
                      },
                    );
                  }),
                ),

                const SizedBox(height: 5),

                GestureDetector(
                  onTap: () {
                    Get.to(() => CreateCounterparyScreen());
                  },
                  child: Container(
                    height: 55,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primarycolor2,
                        width: 1.3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        languagesController.tr("ADD_COUNTER_PARTY"),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
