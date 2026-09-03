import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/global_controller/verify_pin_controller.dart';

import '../accounting/accounting_base.dart';

import '../utils/colors.dart';

LanguagesController languagesController = Get.put(LanguagesController());

class AccountingPinPad {
  static void show(BuildContext context) {
    String enteredNumber = '';

    final VerifyPinController verifyPinController =
        Get.isRegistered<VerifyPinController>()
        ? Get.find<VerifyPinController>()
        : Get.put(VerifyPinController());

    // Clear previous error whenever PIN sheet opens
    verifyPinController.clearError();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            void addNumber(String number) {
              // Maximum 6 digits
              if (enteredNumber.length >= 4) return;

              verifyPinController.clearError();

              setState(() {
                enteredNumber += number;
              });
            }

            void removeNumber() {
              verifyPinController.clearError();

              if (enteredNumber.isNotEmpty) {
                setState(() {
                  enteredNumber = enteredNumber.substring(
                    0,
                    enteredNumber.length - 1,
                  );
                });
              }
            }

            Future<void> submitPin() async {
              if (enteredNumber.length != 4) {
                Get.snackbar(
                  languagesController.tr("INVALID_PIN"),
                  languagesController.tr("PIN_MUST_BE_4_DIGITS"),
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(15),
                );

                return;
              }

              final String pin = enteredNumber;

              final bool isCorrect = await verifyPinController.verifyPin(pin);

              if (!context.mounted) return;

              if (isCorrect) {
                Navigator.of(context).pop();

                Get.to(() => AccountingBaseScreen());
              } else {
                setState(() {
                  enteredNumber = '';
                });
              }
            }

            return Obx(() {
              final bool isLoading = verifyPinController.isLoading.value;

              final String errorMessage =
                  verifyPinController.errorMessage.value;

              return SafeArea(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag Indicator
                      Container(
                        height: 5,
                        width: 45,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Title
                      Text(
                        languagesController.tr("ENTER_PIN"),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        languagesController.tr("ENTER_YOUR_ACCOUNTING_PIN"),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // PIN Display
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 220,
                        height: 65,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: errorMessage.isNotEmpty
                              ? Colors.red.withOpacity(0.04)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: errorMessage.isNotEmpty
                                ? Colors.red.shade300
                                : enteredNumber.isNotEmpty
                                ? AppColors.primaryColor.withOpacity(0.5)
                                : Colors.grey.shade300,
                            width: errorMessage.isNotEmpty ? 1.5 : 1.2,
                          ),
                        ),
                        child: enteredNumber.isEmpty
                            ? Text(
                                "0",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade400,
                                ),
                              )
                            : FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  enteredNumber,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 8,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                      ),

                      // API Error Message
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: errorMessage.isNotEmpty
                            ? Padding(
                                key: ValueKey(errorMessage),
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      size: 17,
                                      color: Colors.red.shade600,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        errorMessage,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red.shade600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 22),

                      // 1 2 3
                      Row(
                        children: [
                          _numberButton(
                            "1",
                            onTap: () => addNumber("1"),
                            enabled: !isLoading,
                          ),
                          _numberButton(
                            "2",
                            onTap: () => addNumber("2"),
                            enabled: !isLoading,
                          ),
                          _numberButton(
                            "3",
                            onTap: () => addNumber("3"),
                            enabled: !isLoading,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // 4 5 6
                      Row(
                        children: [
                          _numberButton(
                            "4",
                            onTap: () => addNumber("4"),
                            enabled: !isLoading,
                          ),
                          _numberButton(
                            "5",
                            onTap: () => addNumber("5"),
                            enabled: !isLoading,
                          ),
                          _numberButton(
                            "6",
                            onTap: () => addNumber("6"),
                            enabled: !isLoading,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // 7 8 9
                      Row(
                        children: [
                          _numberButton(
                            "7",
                            onTap: () => addNumber("7"),
                            enabled: !isLoading,
                          ),
                          _numberButton(
                            "8",
                            onTap: () => addNumber("8"),
                            enabled: !isLoading,
                          ),
                          _numberButton(
                            "9",
                            onTap: () => addNumber("9"),
                            enabled: !isLoading,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Blank / 0 / Backspace
                      Row(
                        children: [
                          const Expanded(child: SizedBox(height: 58)),

                          _numberButton(
                            "0",
                            onTap: () => addNumber("0"),
                            enabled: !isLoading,
                          ),

                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: Material(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(14),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: isLoading ? null : removeNumber,
                                  child: SizedBox(
                                    height: 58,
                                    child: Center(
                                      child: Icon(
                                        Icons.backspace_outlined,
                                        size: 25,
                                        color: isLoading
                                            ? Colors.grey.shade400
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Cancel & Submit
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        verifyPinController.clearError();

                                        Navigator.pop(context);
                                      },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                                child: Text(
                                  languagesController.tr("CANCEL"),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : submitPin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: AppColors
                                      .primaryColor
                                      .withOpacity(0.6),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 21,
                                        height: 21,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        languagesController.tr("SUBMIT"),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            });
          },
        );
      },
    );
  }

  static Widget _numberButton(
    String number, {
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Material(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: enabled ? onTap : null,
            child: SizedBox(
              height: 58,
              child: Center(
                child: Text(
                  number,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: enabled ? Colors.black87 : Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
