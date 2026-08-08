import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../global_controller/languages_controller.dart';
import '../utils/colors.dart';

class LanguageSelectorButton extends StatefulWidget {
  const LanguageSelectorButton({super.key, this.size = 40, this.iconSize = 24});

  final double size;
  final double iconSize;

  @override
  State<LanguageSelectorButton> createState() => _LanguageSelectorButtonState();
}

class _LanguageSelectorButtonState extends State<LanguageSelectorButton> {
  final LanguagesController languagesController =
      Get.find<LanguagesController>();

  final GetStorage box = GetStorage();

  Locale _getLocale(String isoCode) {
    switch (isoCode) {
      case 'fa':
        return const Locale('fa', 'IR');

      case 'ar':
        return const Locale('ar', 'AE');

      case 'ps':
        return const Locale('ps', 'AF');

      case 'tr':
        return const Locale('tr', 'TR');

      case 'bn':
        return const Locale('bn', 'BD');

      case 'en':
      default:
        return const Locale('en', 'US');
    }
  }

  Future<void> _changeLanguage({
    required BuildContext dialogContext,
    required Map<String, dynamic> data,
  }) async {
    final String languageName = data['name']?.toString() ?? '';

    if (languageName.isEmpty) {
      return;
    }

    final Map<String, dynamic> matched = languagesController.alllanguagedata
        .cast<Map<String, dynamic>>()
        .firstWhere(
          (language) => language['name']?.toString() == languageName,
          orElse: () => <String, dynamic>{'isoCode': 'en', 'direction': 'ltr'},
        );

    final String languageISO =
        matched['isoCode']?.toString().trim().toLowerCase() ?? 'en';

    final String languageDirection =
        matched['direction']?.toString().trim().toLowerCase() ?? 'ltr';

    languagesController.changeLanguage(languageName);

    await box.write('language', languageName);
    await box.write('direction', languageDirection);

    final Locale locale = _getLocale(languageISO);

    if (!mounted) {
      return;
    }

    await EasyLocalization.of(context)?.setLocale(locale);

    if (!mounted) {
      return;
    }

    setState(() {});

    if (Navigator.of(dialogContext).canPop()) {
      Navigator.of(dialogContext).pop();
    }

    debugPrint(
      'Language changed to $languageName '
      '($languageISO), Direction: $languageDirection',
    );
  }

  void _showLanguageDialog() {
    final double screenWidth = MediaQuery.of(context).size.width;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 24,
              ),
              child: Container(
                width: screenWidth,
                constraints: const BoxConstraints(
                  maxWidth: 430,
                  maxHeight: 500,
                ),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                decoration: BoxDecoration(
                  color: AppColors.listbuilderboxColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 25,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.language_rounded,
                            color: AppColors.primaryColor,
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            languagesController.tr('LANGUAGES'),
                            style: const TextStyle(
                              color: Color(0xFF1D2939),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: languagesController.alllanguagedata.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 9);
                        },
                        itemBuilder: (context, index) {
                          final Map<String, dynamic> data =
                              Map<String, dynamic>.from(
                                languagesController.alllanguagedata[index],
                              );

                          final String languageName =
                              data['name']?.toString() ?? '';

                          final String fullName =
                              data['fullname']?.toString() ?? languageName;

                          final bool isSelected =
                              box.read('language')?.toString() == languageName;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(13),
                              onTap: () async {
                                await _changeLanguage(
                                  dialogContext: dialogContext,
                                  data: data,
                                );

                                if (mounted) {
                                  setDialogState(() {});
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 13,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryColor.withValues(
                                          alpha: 0.10,
                                        )
                                      : AppColors.secondaryColor.withValues(
                                          alpha: 0.55,
                                        ),
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(
                                    width: isSelected ? 1.4 : 1,
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : AppColors.primarycolor2.withValues(
                                            alpha: 0.35,
                                          ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 36,
                                      width: 36,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primaryColor
                                            : AppColors.listbuilderboxColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.translate_rounded,
                                        size: 19,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 11),
                                    Expanded(
                                      child: Text(
                                        fullName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isSelected
                                              ? AppColors.primaryColor
                                              : const Color(0xFF344054),
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.primaryColor,
                                        size: 21,
                                      )
                                    else
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Color(0xFF98A2B3),
                                        size: 14,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showLanguageDialog,
      child: Container(
        height: widget.size,
        width: widget.size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primarycolor2.withValues(alpha: 0.30),
          ),
        ),
        child: Image.asset(
          'assets/icons/gridmenu.png',
          height: widget.iconSize,
          width: widget.iconSize,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.language_rounded,
              color: AppColors.primaryColor,
              size: widget.iconSize,
            );
          },
        ),
      ),
    );
  }
}
