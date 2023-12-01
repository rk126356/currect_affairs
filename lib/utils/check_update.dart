import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currect_affairs/widgets/update_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

updateAppLaunched(context) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  String currentVersion = packageInfo.version;

  FirebaseFirestore.instance
      .collection('appInfo')
      .doc('iO8Yck5WE3uvfxiKxT6E')
      .get()
      .then((DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.exists) {
      // Check if the document exists
      Map<String, dynamic>? data = snapshot.data();
      if (data != null) {
        String version = data['version'];
        bool isUpdateAvailable = data['isUpdateAvailable'];
        String updateMessage = data['updateMessage'];
        String appLink = data['appLink'];
        bool isForceUpdate = data['isForceUpdate'];
        if (isUpdateAvailable && currentVersion != version) {
          void showUpdateDialog(BuildContext context) {
            showDialog(
              context: context,
              barrierDismissible: isForceUpdate,
              builder: (context) {
                return UpdateDialog(
                  version: version,
                  description: updateMessage,
                  appLink: appLink,
                  allowDismissal: !isForceUpdate,
                );
              },
            );
          }

          showUpdateDialog(context);
        } else {
          if (kDebugMode) {
            print('No update available');
          }
        }
      } else {
        if (kDebugMode) {
          print('Field version not found or is null.');
        }
      }
    } else {
      if (kDebugMode) {
        print('Document does not exist.');
      }
    }
  });
}
