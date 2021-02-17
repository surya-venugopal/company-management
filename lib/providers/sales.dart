import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indian/providers/production.dart';
import 'package:indian/providers/stock_helper.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import 'company.dart';

class SalesModel {
  final String saleId;
  final String customerName;
  final String customerPhone;
  final String typeOfStone;
  final String salesQuantity;
  final DateTime salesDate;

  SalesModel({
    @required this.saleId,
    @required this.customerName,
    @required this.customerPhone,
    @required this.typeOfStone,
    @required this.salesQuantity,
    @required this.salesDate,
  });
}

class Sales with ChangeNotifier {
  FirebaseFirestore db = FirebaseFirestore.instance;

  List<SalesModel> _sales = [];

  List<SalesModel> get sales {
    return [..._sales];
  }



  SalesModel findById(String id) {
    return _sales.firstWhere((sale) => sale.saleId == id);
  }

  Future<void> deleteItem(String id1,String id2,SalesModel sales) async{
    var company = Company.name;
    await db.collection(MyApp.company)
        .doc(MyApp.company).collection(company).doc(company).collection("DayBook").doc(id1).collection("sales").doc(id2).delete();
    await StockHelper().addStock(StockModel(
        sales.typeOfStone, [sales.salesQuantity.toString(), "num"]));
  }

  setSales(List<QueryDocumentSnapshot> docs) {
    docs.forEach((element) {
      _sales.add(new SalesModel(
          saleId: element.id,
          customerName: element.data()['customerName'],
          customerPhone: element.data()['customerPhone'],
          typeOfStone: element.data()['typeOfStone'],
          salesQuantity: element.data()['salesQuantity'],
          salesDate: (element.data()['salesDate'] as Timestamp).toDate()));
    });
    notifyListeners();
  }

  Future<void> addSalesDetails(SalesModel sale) async {
    Map<String, dynamic> data = {
      'customerName': sale.customerName,
      'customerPhone': sale.customerPhone,
      'typeOfStone': sale.typeOfStone,
      'salesQuantity': sale.salesQuantity,
      'salesDate': sale.salesDate,
    };
    var company = Company.name;
    await db.collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company).doc(company).collection("DayBook")
        .doc(DateFormat.yMMMMd().format(sale.salesDate))
        .set({"date": sale.salesDate});
    await db.collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company).doc(company).collection("DayBook")
        .doc(DateFormat.yMMMMd().format(sale.salesDate))
        .collection("sales")
        .add(data);

    await StockHelper()
        .deleteStock(StockModel(sale.typeOfStone, [sale.salesQuantity.toString(), "num"]), sale.salesQuantity.toString());
  }

  Future<void> updateSalesDetails(String id, SalesModel sale,String oldKey,String oldValue) async {
    final saleIndex = _sales.indexWhere((sale) => sale.saleId == id);

    Map<String, dynamic> data = {
      'customerName': sale.customerName,
      'customerPhone': sale.customerPhone,
      'typeOfStone': sale.typeOfStone,
      'salesQuantity': sale.salesQuantity,
      'salesDate': sale.salesDate,
    };
    var company = Company.name;

    await db.collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company).doc(company).collection("DayBook")
        .doc(DateFormat.yMMMMd().format(sale.salesDate))
        .collection("sales")
        .doc(id)
        .update(data)
        .then((value) {
      _sales[saleIndex] = sale;
      notifyListeners();
    }).catchError((e) {
      print(e);
    });

    await StockHelper().updateStockRev(
        StockModel(
            sale.typeOfStone, [sale.salesQuantity.toString(), "num"]),
        oldKey,
        oldValue);
  }
}
