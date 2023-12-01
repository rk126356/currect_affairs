import 'package:currect_affairs/common/colors.dart';
import 'package:currect_affairs/utils/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          ListTile(
            leading:
                const Icon(CupertinoIcons.info, color: AppColors.primaryColor),
            title: const Text("About Us"),
            trailing: const Icon(
              CupertinoIcons.forward,
              color: AppColors.primaryColor,
            ),
            onTap: () {
              open('https://raihansk.com/current-affairs-and-gk/');
            },
          ),
          ListTile(
            leading:
                const Icon(CupertinoIcons.mail, color: AppColors.primaryColor),
            title: const Text("Contact Us"),
            trailing: const Icon(
              CupertinoIcons.forward,
              color: AppColors.primaryColor,
            ),
            onTap: () {
              open('https://raihansk.com/contact/');
            },
          ),
          ListTile(
            leading:
                const Icon(CupertinoIcons.lock, color: AppColors.primaryColor),
            title: const Text("Privacy Policy"),
            trailing: const Icon(
              CupertinoIcons.forward,
              color: AppColors.primaryColor,
            ),
            onTap: () {
              open(
                  'https://raihansk.com/current-affairs-and-gk/privacy-policy-daily-current-affairs-and-gk/');
            },
          ),
          if (kDebugMode)
            ListTile(
              leading: const Icon(CupertinoIcons.lock,
                  color: AppColors.primaryColor),
              title: const Text("Clear Data"),
              trailing: const Icon(
                CupertinoIcons.forward,
                color: AppColors.primaryColor,
              ),
              onTap: () async {
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                await preferences.clear();
              },
            ),
        ],
      ),
    );
  }
}
