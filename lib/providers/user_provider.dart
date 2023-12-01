import 'package:currect_affairs/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  UserProvider() {
    _initializeDataFromPrefs();
  }
  var _userData = UserModel(
      // uid: 'HpWp3pyzgNWzvR2deGOmKPlBFKp2',
      // email: 'rsk126356@gmail.com',
      );
  bool _isFirstLaunch = true;
  bool _isNewOpen = true;

  UserModel get userData => _userData;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isNewOpen => _isNewOpen;

  setIsNewOpen(bool value) {
    _isNewOpen = value;
  }

  setFirstLaunch(bool data) async {
    _isFirstLaunch = data;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstLaunch', data);
  }

  setUserData(UserModel user) {
    _userData = UserModel(
      name: user.name ?? _userData.name,
      email: user.email ?? _userData.email,
      avatarUrl: user.avatarUrl ?? _userData.avatarUrl,
      uid: user.uid ?? _userData.uid,
    );
    notifyListeners();
  }

  Future<void> _initializeDataFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstLaunch = prefs.getBool('firstLaunch');

    if (isFirstLaunch != null) {
      _isFirstLaunch = isFirstLaunch;
    }

    notifyListeners();
  }
}
