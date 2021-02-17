import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:indian/main.dart';

class AppUserModel {
  final String id;
  final String name;
  final String phone;
  final bool daybookAccess;
  final int userType;
  final int userCompany;

  AppUserModel(this.id, this.userType, this.name, this.phone,
      this.daybookAccess, this.userCompany);
}

class AppUser with ChangeNotifier {
  AppUserModel _appUserModel = AppUserModel("", null, "", null, null, null);
  FirebaseFirestore db = FirebaseFirestore.instance;

  void setId(String id) {
    _appUserModel = AppUserModel(id, null, "", null, null, null);
  }

  Future<void> setUser(String name, String phone, int company) async {
    Map<String, dynamic> user = {
      "name": name,
      "phone": phone,
      "daybookAccess": false,
      "userType": 2,
    };
    await db.collection(MyApp.company).doc(MyApp.company).collection("User").doc(_appUserModel.id).set(user);
    _appUserModel =
        AppUserModel(_appUserModel.id, 2, name, phone, false, company);
    notifyListeners();
  }

  AppUserModel get getUser {
    return _appUserModel;
  }

  Future<void> get getinfoFromDb async {
    var value = await db.collection(MyApp.company).doc(MyApp.company).collection("User").doc(_appUserModel.id).get();
    _appUserModel = AppUserModel(
        _appUserModel.id,
        int.parse(value['userType'].toString()),
        value.data()['name'],
        value.data()['phone'],
        value.data()['daybookAccess'],
        value.data()['userCompany']);
    notifyListeners();
  }
}
