import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../main.dart';
import 'company.dart';

class Daily {
  DateTime date;
  String imageUrl;
  String description;

  Daily(this.date, this.imageUrl, this.description);

  var db = FirebaseFirestore.instance;

  Future setDaily() async{
    var company = Company.name;
    var daily = {
      "date": date,
      "imageUrl": imageUrl,
      "description": description
    };
    await db.collection(MyApp.company)
        .doc(MyApp.company).collection(company).doc(company).collection("Daily").add(daily);
  }
}
