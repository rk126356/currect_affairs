import 'package:currect_affairs/admin/delete_quizzes.dart';
import 'package:currect_affairs/common/colors.dart';
import 'package:currect_affairs/providers/ad_provider.dart';

import 'package:currect_affairs/screens/give_rating_screen.dart';

import 'package:currect_affairs/screens/my_bookmarks_screen.dart';
import 'package:currect_affairs/screens/recently_taken_screen.dart';
import 'package:currect_affairs/screens/remove_ads_screen.dart';
import 'package:currect_affairs/screens/settings_screen.dart';
import 'package:currect_affairs/utils/url_launcher.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  String version = '1.0.0';

  void checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      version = packageInfo.version;
    });
  }

  @override
  void initState() {
    super.initState();
    checkVersion();
  }

  @override
  Widget build(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context);
    return Drawer(
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              !adProvider.isPremium
                  ? 'Daily Current Affairs & GK'
                  : 'Daily Current Affairs & GK Pro',
            ),
            accountEmail: Text('Version: $version'),
            currentAccountPicture: Image.asset('assets/images/app_logo.png'),
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.history,
              color: AppColors.primaryColor,
            ),
            title: const Text('Recently Taken'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const RecentlyTakenScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.bookmark,
              color: AppColors.primaryColor,
            ),
            title: const Text('My Bookmarks'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MyBookmarksScreen(),
                ),
              );
            },
          ),
          if (!adProvider.isPremium)
            ListTile(
                leading: const Icon(
                  Icons.hide_image_rounded,
                  color: AppColors.primaryColor,
                ),
                title: const Text('Remove Ads'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const RemoveAdsScreen();
                    },
                  );
                }),
          ListTile(
            leading: const Icon(
              Icons.help,
              color: AppColors.primaryColor,
            ),
            title: const Text('Help & Support'),
            onTap: () => open('https://raihansk.com/contact/'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.star,
              color: AppColors.primaryColor,
            ),
            title: const Text('Give Rating'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GiveRatingScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.settings,
              color: AppColors.primaryColor,
            ),
            title: const Text(
              'Settings',
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Exit'),
            leading: const Icon(Icons.logout),
            onTap: () async {
              SystemNavigator.pop();
            },
          ),
          if (kDebugMode)
            ListTile(
              leading: const Icon(
                Icons.delete,
                color: AppColors.primaryColor,
              ),
              title: const Text('Delete Quizzes'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DeleteQuizzes(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
