import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indian/providers/company.dart';

import '../main.dart';


class ClientModel {
  final String clientName;
  final String clientPhone;
  final String siteImage;
  final DateTime date;
  final String location;
  bool isStarred;

  ClientModel(
      {this.clientName,
      this.clientPhone,
      this.siteImage,
      this.date,
      this.isStarred,
      this.location});

  FirebaseFirestore db = FirebaseFirestore.instance;

  Map<String, dynamic> getMap(ClientModel client) {
    return {
      "clientName": client.clientName,
      "clientPhone": client.clientPhone,
      "siteImage": client.siteImage,
      "isStarred": client.isStarred,
      "location": client.location,
      "date": client.date
    };
  }


  Future addToDb(ClientModel client) async {
    var company = Company.name;
    await db.collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company)
        .doc(company)
        .collection("MarketingClient")
        .add(getMap(client));
  }
}
