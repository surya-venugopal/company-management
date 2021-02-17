import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indian/providers/stock_helper.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import 'company.dart';

class ProductionModel {
  final String productionId;
  final String stoneName;
  final DateTime productionDate;
  final String productionQuantity;

  ProductionModel({
    @required this.productionId,
    @required this.stoneName,
    @required this.productionDate,
    @required this.productionQuantity,
  });
}

class Production with ChangeNotifier {
  FirebaseFirestore db = FirebaseFirestore.instance;

  List<ProductionModel> _production = [];

  List<ProductionModel> get production {
    return [..._production];
  }

  ProductionModel findById(String id) {
    return _production.firstWhere((prod) => prod.productionId == id);
  }

  Future<void> deleteItem(String id1, id2, String name, String quantity) async {
    var company = Company.name;
    await db
        .collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company)
        .doc(company)
        .collection("DayBook")
        .doc(id1)
        .collection("production")
        .doc(id2)
        .delete();
    print(name);
    await StockHelper()
        .deleteStock(StockModel(name, [quantity, "num"]), quantity);
  }

  setProduction(List<QueryDocumentSnapshot> docs) {
    docs.forEach((element) {
      _production.add(new ProductionModel(
          productionId: element.id,
          stoneName: element.data()['stoneName'],
          productionDate:
              (element.data()['productionDate'] as Timestamp).toDate(),
          productionQuantity: element.data()['productionQuantity']));
    });
    notifyListeners();
  }

  Future<void> addProductionDetails(ProductionModel production) async {
    Map<String, dynamic> data = {
      'stoneName': production.stoneName,
      'productionDate': production.productionDate,
      'productionQuantity': production.productionQuantity,
    };
    var company = Company.name;
    await db
        .collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company)
        .doc(company)
        .collection("DayBook")
        .doc(DateFormat.yMMMMd().format(production.productionDate))
        .set({"date": production.productionDate});
    await db
        .collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company)
        .doc(company)
        .collection("DayBook")
        .doc(DateFormat.yMMMMd().format(production.productionDate))
        .collection("production")
        .add(data);
    await StockHelper().addStock(StockModel(production.stoneName,
        [production.productionQuantity.toString(), "num"]));
  }

  Future<void> updateProductionDetails(String id, ProductionModel production,
      String oldKey, String oldValue) async {
    final productionIndex =
        _production.indexWhere((prod) => prod.productionId == id);

    Map<String, Object> data = {
      'stoneName': production.stoneName,
      'productionDate': production.productionDate,
      'productionQuantity': production.productionQuantity,
    };
    var company = Company.name;
    await db
        .collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company)
        .doc(company)
        .collection("DayBook")
        .doc(DateFormat.yMMMMd().format(production.productionDate))
        .collection("production")
        .doc(id)
        .update(data)
        .then((value) {
      _production[productionIndex] = production;
      notifyListeners();
    }).catchError((e) {
      print(e);
    });
    await StockHelper().updateStock(
        StockModel(production.stoneName,
            [production.productionQuantity.toString(), "num"]),
        oldKey,
        oldValue);
  }
}
