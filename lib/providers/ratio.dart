import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indian/main.dart';

class Ratios {
  static Map stoneKeys = {};

  static getRatio() async {
    DocumentSnapshot ratio = await FirebaseFirestore.instance.collection(
        MyApp.company).doc("Ratio").get();
    ratio.data().keys.forEach((key) {
      stoneKeys[key] = ratio.data()[key];
    });
  }
}