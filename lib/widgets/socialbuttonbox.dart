import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../global_controller/languages_controller.dart';

Future<void> _launchUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}

LanguagesController languagesController = Get.put(LanguagesController());

void showSocialPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Icon + Title

              Text(
                languagesController.tr("FIND_US_ON"),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Buttons in a nice grid-like layout
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _socialButton(
                    icon: Icons.telegram,
                    label: "Telegram",
                    color: Colors.blue,
                    url: "https://t.me/username",
                  ),
                  _socialButton(
                    icon: Icons.facebook,
                    label: "Facebook",
                    color: Colors.blueAccent,
                    url: "https://facebook.com/username",
                  ),
                  _socialButton(
                    icon: Icons.camera_alt,
                    label: "Instagram",
                    color: Colors.purple,
                    url: "https://instagram.com/username",
                  ),
                  _socialButton(
                    icon: FontAwesomeIcons.whatsapp, // works fine
                    label: "WhatsApp",
                    color: Colors.green,
                    url: "https://wa.me/989032926310",
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Close Button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  languagesController.tr("CLOSE"),
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _socialButton({
  required IconData icon,
  required String label,
  required Color color,
  required String url,
}) {
  return SizedBox(
    width: 140,
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      ),
      icon: Icon(icon, color: Colors.white, size: 20),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      onPressed: () => _launchUrl(url),
    ),
  );
}
