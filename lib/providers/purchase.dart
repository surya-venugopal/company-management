import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indian/providers/stock_helper.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import 'company.dart';

class PurchaseModel {
  final String purchaseId;
  final String itemName;
  final String purchaseQuantity;
  final DateTime purchaseDate;

  PurchaseModel(
      {@required this.purchaseId,
      @required this.itemName,
      @required this.purchaseDate,
      @required this.purchaseQuantity});
}

class Purchase with ChangeNotifier {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<PurchaseModel> _purchase = [];

  PurchaseModel findById(String id) {
    return _purchase.firstWhere((pur) => pur.purchaseId == id);
  }

  Future<void> deleteItem(
      String id1, id2, String name, String quantity) async {var company = Company.name;
    print("\n\n\n\n" + id1 + " --- " + id2 + "\n\n\n\n");
    await db.collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company).doc(company).collection("DayBook")
        .doc(id1)
        .collection("purchase")
        .doc(id2)
        .delete();
    await StockHelper().deleteStock(
        StockModel(name, [quantity, name == "cement" ? "Bag" : "Kg"]),
        quantity);
  }

  setPurchase(List<QueryDocumentSnapshot> docs) {
    docs.forEach((element) {
      _purchase.add(new PurchaseModel(
          purchaseId: element.id,
          itemName: element.data()['itemName'],
          purchaseDate: (element.data()['purchaseDate'] as Timestamp).toDate(),
          purchaseQuantity: element.data()['purchaseQuantity']));
    });
    notifyListeners();
  }

  Future<void> addPurchaseDetails(PurchaseModel purchase) async {
    Map<String, dynamic> data = {
      'itemName': purchase.itemName,
      'purchaseDate': purchase.purchaseDate,
      'purchaseQuantity': purchase.purchaseQuantity,
    };var company = Company.name;
    await db.collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company).doc(company).collection("DayBook")
        .doc(DateFormat.yMMMMd().format(purchase.purchaseDate))
        .set({"date": purchase.purchaseDate});
    await db.collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company).doc(company).collection("DayBook")
        .doc(DateFormat.yMMMMd().format(purchase.purchaseDate))
        .collection("purchase")
        .add(data);
    await StockHelper().addStock(StockModel(purchase.itemName, [
      purchase.purchaseQuantity.toString(),
      purchase.itemName == "cement" ? "Bag" : "Kg"
    ]));
  }

  Future<void> updatePurchaseDetails(String id, PurchaseModel purchase,
      String oldKey, String oldValue) async {
    final purchaseIndex = _purchase.indexWhere((pur) => pur.purchaseId == id);

    Map<String, dynamic> data = {
      'itemName': purchase.itemName,
      'purchaseDate': purchase.purchaseDate,
      'purchaseQuantity': purchase.purchaseQuantity,
    };
    var company = Company.name;
    await db.collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company).doc(company).collection("DayBook")
        .doc(DateFormat.yMMMMd().format(purchase.purchaseDate))
        .collection("purchase")
        .doc(id)
        .update(data)
        .then((value) {
      _purchase[purchaseIndex] = purchase;
      notifyListeners();
    }).catchError((e) {
      print(e);
    });
    await StockHelper().updateStock(
        StockModel(purchase.itemName,
            [purchase.purchaseQuantity.toString(), purchase.itemName== "cement"?"Bag":"Kg"]),
        oldKey,
        oldValue);
  }
}
