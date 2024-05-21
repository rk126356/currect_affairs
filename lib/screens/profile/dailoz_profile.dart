import 'package:currect_affairs/common/colors.dart';
import 'package:currect_affairs/providers/ad_provider.dart';
import 'package:currect_affairs/providers/user_provider.dart';
import 'package:currect_affairs/screens/give_rating_screen.dart';
import 'package:currect_affairs/screens/my_bookmarks_screen.dart';
import 'package:currect_affairs/screens/profile/dailoz_color.dart';
import 'package:currect_affairs/screens/profile/dailoz_fontstyle.dart';
import 'package:currect_affairs/screens/recently_taken_screen.dart';
import 'package:currect_affairs/screens/remove_ads_screen.dart';
import 'package:currect_affairs/screens/settings_screen.dart';
import 'package:currect_affairs/utils/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailozProfile extends StatefulWidget {
  const DailozProfile({Key? key}) : super(key: key);

  @override
  State<DailozProfile> createState() => _DailozProfileState();
}

class _DailozProfileState extends State<DailozProfile> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    final user = Provider.of<UserProvider>(context).userData;
    final adProvider = Provider.of<AdProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.thirdColor,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: InkWell(
              splashColor: DailozColor.transparent,
              highlightColor: DailozColor.transparent,
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                height: height / 20,
                width: height / 20,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: DailozColor.white,
                    boxShadow: const [
                      BoxShadow(color: DailozColor.textgray, blurRadius: 5)
                    ]),
                child: SizedBox(
                  height: height / 22,
                  width: height / 26,
                  child: PopupMenuButton<int>(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            const Icon(Icons.exit_to_app),
                            SizedBox(
                              width: width / 36,
                            ),
                            Text(
                              "Exit",
                              style: hsRegular.copyWith(
                                  fontSize: 16, color: DailozColor.black),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.exclamationmark_octagon),
                            SizedBox(
                              width: width / 36,
                            ),
                            Text(
                              "Log Out",
                              style: hsRegular.copyWith(
                                  fontSize: 16, color: DailozColor.black),
                            ),
                          ],
                        ),
                      )
                    ],
                    offset: const Offset(5, 50),
                    color: DailozColor.white,
                    constraints: BoxConstraints(
                      maxWidth: width / 2.8,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    icon: const Icon(Icons.more_vert),
                    elevation: 2,
                    onSelected: (value) {
                      // if value 1 show dialog
                      if (value == 1) {
                        SystemNavigator.pop();
                        // if value 2 show dialog
                      } else if (value == 2) {
                        logout();
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width / 36, vertical: height / 36),
          child: Column(
            children: [
              Container(
                height: height / 10,
                width: height / 10,
                decoration: BoxDecoration(
                    image:
                        DecorationImage(image: NetworkImage(user.avatarUrl!)),
                    color: DailozColor.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: const [
                      BoxShadow(color: DailozColor.bggray, blurRadius: 5)
                    ]),
              ),
              SizedBox(
                height: height / 56,
              ),
              Text(
                user.name!,
                style: hsSemiBold.copyWith(fontSize: 20),
              ),
              Text(
                user.email!,
                style: hsRegular.copyWith(
                  fontSize: 14,
                ),
              ),
              SizedBox(
                height: height / 36,
              ),
              Row(
                children: [
                  InkWell(
                    splashColor: DailozColor.transparent,
                    highlightColor: DailozColor.transparent,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const MyBookmarksScreen();
                        },
                      ));
                    },
                    child: Container(
                      height: height / 5.9,
                      width: width / 2.2,
                      decoration: BoxDecoration(
                          color: DailozColor.bgpurple,
                          borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: width / 36, vertical: height / 36),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.bookmark_outline,
                              size: 50,
                            ),
                            SizedBox(
                              height: height / 56,
                            ),
                            Text(
                              "My Bookmarks",
                              style: hsMedium.copyWith(
                                  fontSize: 18, color: DailozColor.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    splashColor: DailozColor.transparent,
                    highlightColor: DailozColor.transparent,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const RecentlyTakenScreen();
                        },
                      ));
                    },
                    child: Container(
                      height: height / 5.9,
                      width: width / 2.2,
                      decoration: BoxDecoration(
                          color: DailozColor.bgpurple,
                          borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: width / 36, vertical: height / 36),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.history,
                              size: 50,
                            ),
                            SizedBox(
                              height: height / 56,
                            ),
                            Text(
                              "Recently Taken",
                              style: hsMedium.copyWith(
                                  fontSize: 18, color: DailozColor.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: height / 36,
              ),
              Row(
                children: [
                  InkWell(
                    splashColor: DailozColor.transparent,
                    highlightColor: DailozColor.transparent,
                    onTap: () {
                      open('https://raihansk.com/contact/');
                    },
                    child: Container(
                      height: height / 5.9,
                      width: width / 2.2,
                      decoration: BoxDecoration(
                          color: DailozColor.bgpurple,
                          borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: width / 36, vertical: height / 36),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.help_outline,
                              size: 50,
                            ),
                            SizedBox(
                              height: height / 56,
                            ),
                            Text(
                              "Help & Support",
                              style: hsMedium.copyWith(
                                  fontSize: 18, color: DailozColor.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    splashColor: DailozColor.transparent,
                    highlightColor: DailozColor.transparent,
                    onTap: () {
                      if (!adProvider.isPremium) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const RemoveAdsScreen();
                          },
                        );
                      }
                    },
                    child: Container(
                      height: height / 5.9,
                      width: width / 2.2,
                      decoration: BoxDecoration(
                          color: DailozColor.bgpurple,
                          borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: width / 36, vertical: height / 36),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.workspace_premium,
                              size: 50,
                            ),
                            SizedBox(
                              height: height / 56,
                            ),
                            Text(
                              !adProvider.isPremium
                                  ? "Remove Ads"
                                  : "Thank You",
                              style: hsMedium.copyWith(
                                  fontSize: 18, color: DailozColor.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: height / 36,
              ),
              Row(
                children: [
                  InkWell(
                    splashColor: DailozColor.transparent,
                    highlightColor: DailozColor.transparent,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const GiveRatingScreen(),
                        ),
                      );
                    },
                    child: Container(
                      height: height / 5.9,
                      width: width / 2.2,
                      decoration: BoxDecoration(
                          color: DailozColor.bgpurple,
                          borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: width / 36, vertical: height / 36),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.star_outline,
                              size: 50,
                            ),
                            SizedBox(
                              height: height / 56,
                            ),
                            Text(
                              "Give Rating",
                              style: hsMedium.copyWith(
                                  fontSize: 18, color: DailozColor.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    splashColor: DailozColor.transparent,
                    highlightColor: DailozColor.transparent,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const SettingsScreen();
                        },
                      ));
                    },
                    child: Container(
                      height: height / 5.9,
                      width: width / 2.2,
                      decoration: BoxDecoration(
                          color: DailozColor.bgpurple,
                          borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: width / 36, vertical: height / 36),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.settings,
                              size: 50,
                            ),
                            SizedBox(
                              height: height / 56,
                            ),
                            Text(
                              "Settings",
                              style: hsMedium.copyWith(
                                  fontSize: 18, color: DailozColor.black),
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
        ),
      ),
    );
  }

  Future<bool> logout() async {
    return await showDialog(
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: width / 56, vertical: height / 96),
                  child: Column(
                    children: [
                      Text("Log Out", style: hsSemiBold.copyWith(fontSize: 22)),
                      SizedBox(
                        height: height / 56,
                      ),
                      Text("Are you sure to log out from this account",
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: hsRegular.copyWith(fontSize: 16)),
                      SizedBox(
                        height: height / 36,
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              splashColor: DailozColor.transparent,
                              highlightColor: DailozColor.transparent,
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: height / 20,
                                width: width / 4,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: DailozColor.appcolor)),
                                child: Center(
                                    child: Text(
                                  "Cancel",
                                  style: hsRegular.copyWith(
                                      fontSize: 14,
                                      color: DailozColor.appcolor),
                                )),
                              ),
                            ),
                            SizedBox(
                              width: width / 36,
                            ),
                            InkWell(
                              onTap: () async {
                                final user = Provider.of<UserProvider>(context,
                                    listen: false);
                                user.setIsNewOpen(true);
                                Navigator.pop(context);
                                SharedPreferences preferences =
                                    await SharedPreferences.getInstance();
                                await preferences.clear();
                                await GoogleSignIn().signOut();
                                await FirebaseAuth.instance.signOut();
                              },
                              child: Container(
                                height: height / 20,
                                width: width / 4,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: DailozColor.appcolor),
                                child: Center(
                                    child: Text(
                                  "Sure",
                                  style: hsRegular.copyWith(
                                      fontSize: 14, color: DailozColor.white),
                                )),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: height / 56,
                      ),
                    ],
                  ),
                )
              ],
            ),
        context: context);
  }
}
