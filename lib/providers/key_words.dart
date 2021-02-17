import 'package:flutter/material.dart';

class KeyWords with ChangeNotifier {
  List<Map<String, String>> keys = [];

  setKeys(List<Map<String, String>> keys) {
    this.keys = keys;
    // this.keys.sort();

    // notifyListeners();
  }

  List<String> getStone() {
    List<String> val = [];
    for (var map in keys) {
      if (map["unit"] == "num") {
        val.add(map["key"]);
      }
    }
    return val;
  }

  List<String> getRaw() {
    List<String> val = [];
    for (var map in keys) {
      if (map["unit"] != "num") {
        val.add(map["key"]);
      }
    }
    return val;
  }
}
