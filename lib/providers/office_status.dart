import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import 'company.dart';

class Office with ChangeNotifier {
  final bool isOpen;
  final DateTime openTime;

  // Map<String, List<String>> workerIsPresent;

  Office(this.isOpen, this.openTime);

  var db = FirebaseFirestore.instance;

  Future<void> setOffice(
      DateTime time, String timeS, String workerId, String loc) async {
    var company = Company.name;
    var doc = await db
        .collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company)
        .doc(company)
        .collection("Office")
        .doc(DateFormat.yMMMMd().format(DateTime.now()))
        .get();
    var data;
    if (doc.exists) {
      if(doc.data().keys.contains(workerId)){

      }else{
        if (!doc.data()['isOpen']) {
          data = {
            "isOpen": true,
            "openTime": time,
            workerId: [timeS, loc]
          };
          await db
              .collection(MyApp.company)
              .doc(MyApp.company)
              .collection(company)
              .doc(company)
              .collection("Office")
              .doc(DateFormat.yMMMMd().format(DateTime.now()))
              .update(data);
        }
        else {
          data = {
            "isOpen": true,
            "openTime": doc["openTime"],
            workerId: [timeS, loc]
          };
          await db
              .collection(MyApp.company)
              .doc(MyApp.company)
              .collection(company)
              .doc(company)
              .collection("Office")
              .doc(DateFormat.yMMMMd().format(DateTime.now()))
              .update(data);
        }
      }

    } else {
      data = {
        "isOpen": true,
        "openTime": time,
        workerId: [timeS, loc]
      };
      await db
          .collection(MyApp.company)
          .doc(MyApp.company)
          .collection(company)
          .doc(company)
          .collection("Office")
          .doc(DateFormat.yMMMMd().format(DateTime.now()))
          .set(data);
    }
  }

  Future<void> setMachine(String status) async {
    var company = Company.name;
    await db
        .collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company)
        .doc(company)
        .collection("Office")
        .doc(DateFormat.yMMMMd().format(DateTime.now()))
        .update({"machine": status});
  }
}
