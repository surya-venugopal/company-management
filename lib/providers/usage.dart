import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:indian/providers/stock_helper.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import 'company.dart';

class UsageModel {
  final String usageId;
  final String itemName;
  final String usageQuantity;
  final DateTime usageDate;

  UsageModel({
    @required this.usageId,
    @required this.itemName,
    @required this.usageQuantity,
    @required this.usageDate,
  });
}

class Usage with ChangeNotifier {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<UsageModel> _usage = [];

  UsageModel findById(String id) {
    return _usage.firstWhere((pur) => pur.usageId == id);
  }

  Future<void> deleteItem(String id1, id2, UsageModel usage) async {
    var company = Company.name;
    await db
        .collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company)
        .doc(company)
        .collection("DayBook")
        .doc(id1)
        .collection("usage")
        .doc(id2)
        .delete();
    await StockHelper().addStock(StockModel(usage.itemName, [
      usage.usageQuantity.toString(),
      usage.itemName == "cement" ? "Bag" : "Kg"
    ]));
  }

  setUsage(List<QueryDocumentSnapshot> docs) {
    docs.forEach((element) {
      _usage.add(new UsageModel(
          usageId: element.id,
          itemName: element.data()['itemName'],
          usageDate: (element.data()['usageDate'] as Timestamp).toDate(),
          usageQuantity: element.data()['usageQuantity']));
    });
    notifyListeners();
  }

  Future<void> addUsageDetails(UsageModel usage) async {
    var company = Company.name;
    Map<String, dynamic> data = {
      'itemName': usage.itemName,
      'usageDate': usage.usageDate,
      'usageQuantity': usage.usageQuantity,
    };
    await db
        .collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company)
        .doc(company)
        .collection("DayBook")
        .doc(DateFormat.yMMMMd().format(usage.usageDate))
        .set({"date": usage.usageDate});
    await db
        .collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company)
        .doc(company)
        .collection("DayBook")
        .doc(DateFormat.yMMMMd().format(usage.usageDate))
        .collection("usage")
        .add(data);
    await StockHelper().deleteStock(
        StockModel(usage.itemName, [
          usage.usageQuantity.toString(),
          usage.itemName == "cement" ? "Bag" : "Kg"
        ]),
        usage.usageQuantity.toString());
  }

  Future<void> updateUsageDetails(
      String id, UsageModel usage, String oldKey, String oldValue) async {
    var company = Company.name;
    final usageIndex = _usage.indexWhere((pur) => pur.usageId == id);

    Map<String, dynamic> data = {
      'itemName': usage.itemName,
      'usageDate': usage.usageDate,
      'usageQuantity': usage.usageQuantity,
    };

    await db
        .collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company)
        .doc(company)
        .collection("DayBook")
        .doc(DateFormat.yMMMMd().format(usage.usageDate))
        .collection("usage")
        .doc(id)
        .update(data)
        .then((value) {
      _usage[usageIndex] = usage;
      notifyListeners();
    }).catchError((e) {
      print(e);
    });
    await StockHelper().updateStockRev(
        StockModel(usage.itemName, [
          usage.usageQuantity.toString(),
          usage.itemName == "cement" ? "Bag" : "Kg"
        ]),
        oldKey,
        oldValue);
  }
}
