import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:indian/providers/production.dart';

import '../main.dart';
import 'company.dart';

class StockModel {
  final String itemName;
  final List<String> itemValue;

  StockModel(this.itemName, this.itemValue);
}

class StockHelper {
  var db = FirebaseFirestore.instance;

  Future<void> addStock(StockModel item) async {
    var company = Company.name;
    var doc = await db.collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company)
        .doc(company)
        .collection("Stock")
        .doc("currentStock")
        .get();
    if (doc.data().keys.contains(item.itemName)) {
      print("\n\n\n\n\n I have");
      var currentData = doc.data()[item.itemName];
      var newData =
          (int.parse(currentData[0]) + int.parse(item.itemValue[0])).toString();

      await db.collection(MyApp.company)
          .doc(MyApp.company)
          .collection(company)
          .doc(company)
          .collection("Stock")
          .doc("currentStock")
          .update({
        item.itemName: [newData, item.itemValue[1]]
      });
    } else {
      await db.collection(MyApp.company)
          .doc(MyApp.company)
          .collection(company)
          .doc(company)
          .collection("Stock")
          .doc("currentStock")
          .update({
        item.itemName: [item.itemValue[0], item.itemValue[1]]
      });
    }
  }

  Future<void> updateStock(
      StockModel item, String oldKey, String oldValue) async {
    var company = Company.name;
    var doc = await db.collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company)
        .doc(company)
        .collection("Stock")
        .doc("currentStock")
        .get();
    var currentData = doc.data()[item.itemName];
    if (item.itemName == oldKey) {
      var newData = (int.parse(currentData[0]) +
              int.parse(item.itemValue[0]) -
              int.parse(oldValue))
          .toString();

      await db.collection(MyApp.company)
          .doc(MyApp.company)
          .collection(company)
          .doc(company)
          .collection("Stock")
          .doc("currentStock")
          .update({
        item.itemName: [newData, item.itemValue[1]]
      });
    } else {
      currentData = doc.data()[oldKey];
      var newData =
          (int.parse(currentData[0]) - int.parse(oldValue)).toString();
      await db.collection(MyApp.company)
          .doc(MyApp.company)
          .collection(company)
          .doc(company)
          .collection("Stock")
          .doc("currentStock")
          .update({
        oldKey: [newData, item.itemValue[1]]
      });
      currentData = doc.data()[item.itemName];
      newData =
          (int.parse(currentData[0]) + int.parse(item.itemValue[0])).toString();
      await db.collection(MyApp.company)
          .doc(MyApp.company)
          .collection(company)
          .doc(company)
          .collection("Stock")
          .doc("currentStock")
          .update({
        item.itemName: [newData, item.itemValue[1]]
      });
    }
  }

  Future<void> updateStockRev(
      StockModel item, String oldKey, String oldValue) async {
    var company = Company.name;
    var doc = await db.collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company)
        .doc(company)
        .collection("Stock")
        .doc("currentStock")
        .get();
    var currentData = doc.data()[item.itemName];
    if (item.itemName == oldKey) {
      var newData = (int.parse(currentData[0]) -
              int.parse(item.itemValue[0]) +
              int.parse(oldValue))
          .toString();

      await db.collection(MyApp.company)
          .doc(MyApp.company)
          .collection(company)
          .doc(company)
          .collection("Stock")
          .doc("currentStock")
          .update({
        item.itemName: [newData, item.itemValue[1]]
      });
    } else {
      currentData = doc.data()[oldKey];
      var newData =
          (int.parse(currentData[0]) + int.parse(oldValue)).toString();
      await db.collection(MyApp.company)
          .doc(MyApp.company)
          .collection(company)
          .doc(company)
          .collection("Stock")
          .doc("currentStock")
          .update({
        oldKey: [newData, item.itemValue[1]]
      });
      currentData = doc.data()[item.itemName];
      newData =
          (int.parse(currentData[0]) - int.parse(item.itemValue[0])).toString();

      await db.collection(MyApp.company)
          .doc(MyApp.company)
          .collection(company)
          .doc(company)
          .collection("Stock")
          .doc("currentStock")
          .update({
        item.itemName: [newData, item.itemValue[1]]
      });
    }
  }

  Future<void> deleteStock(StockModel item, String oldValue) async {
    var company = Company.name;

    var doc = await db.collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company)
        .doc(company)
        .collection("Stock")
        .doc("currentStock")
        .get();
    var currentData = doc.data()[item.itemName];
    print(item.itemName);
    var newData = (int.parse(currentData[0]) - int.parse(oldValue)).toString();

    await db.collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company)
        .doc(company)
        .collection("Stock")
        .doc("currentStock")
        .update({
      item.itemName: [newData, item.itemValue[1]]
    });
  }
}
