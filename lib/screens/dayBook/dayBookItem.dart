import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indian/constants/colors.dart';
import 'package:indian/providers/app_users.dart';
import 'package:indian/providers/company.dart';
import 'package:indian/providers/production.dart';
import 'package:indian/providers/purchase.dart';
import 'package:indian/providers/sales.dart';
import 'package:indian/providers/usage.dart';
import 'package:indian/screens/dayBook/add_usage_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import 'add_production_screen.dart';
import 'add_purchase_screen.dart';
import 'add_sales_screen.dart';

class DayBookItem extends StatelessWidget {
  FirebaseFirestore db = FirebaseFirestore.instance;

  final date;

  DayBookItem(this.date);

  @override
  Widget build(BuildContext context) {
    var company = Company.name;
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: MyColors().colorPrimary,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              child: Text(
                date,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.pink, fontSize: 18),
              ),
            ),
            SizedBox(height: 15),
            Text(
              "Production",
              style: TextStyle(color: MyColors().colorSecondary, fontSize: 22),
            ),
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: StreamBuilder(
                stream: db.collection(MyApp.company)
                    .doc(MyApp.company)
                    .collection(company)
                    .doc(company)
                    .collection("DayBook")
                    .doc(date)
                    .collection("production")
                    .snapshots(),
                builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return snapshot.data.docs.length == 0
                      ? Container(
                          child: Text(
                            "No Production",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...snapshot.data.docs
                                  .map(
                                    (doc) => GestureDetector(
                                      onTap: () {
                                        if (Provider.of<AppUser>(context,
                                                listen: false)
                                            .getUser
                                            .daybookAccess) {
                                          var docs = snapshot.data.docs;
                                          Provider.of<Production>(context,
                                                  listen: false)
                                              .setProduction(docs);
                                          _showProductionForm(context, doc.id);
                                        }
                                      },
                                      child: Column(
                                        children: [
                                          RichText(
                                            text: TextSpan(children: [
                                              TextSpan(
                                                text:
                                                    "${doc.data()["stoneName"]} : ",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20),
                                              ),
                                              TextSpan(
                                                text: doc.data()[
                                                    "productionQuantity"],
                                                style: TextStyle(
                                                    color: MyColors()
                                                        .colorSecondary,
                                                    fontSize: 18),
                                              ),
                                            ]),
                                          ),
                                          SizedBox(height: 5),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ],
                          ),
                        );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Usage",
              style: TextStyle(color: MyColors().colorSecondary, fontSize: 22),
            ),
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: StreamBuilder(
                stream: db.collection(MyApp.company)
                    .doc(MyApp.company)
                    .collection(company)
                    .doc(company)
                    .collection("DayBook")
                    .doc(date)
                    .collection("usage")
                    .snapshots(),
                builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return snapshot.data.docs.length == 0
                      ? Container(
                          child: Text(
                            "No Usage",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...snapshot.data.docs
                                  .map(
                                    (doc) => GestureDetector(
                                      onTap: () {
                                        if (Provider.of<AppUser>(context,
                                                listen: false)
                                            .getUser
                                            .daybookAccess) {
                                          var docs = snapshot.data.docs;
                                          Provider.of<Usage>(context,
                                                  listen: false)
                                              .setUsage(docs);
                                          _showUsageForm(context, doc.id);
                                        }
                                      },
                                      child: Column(
                                        children: [
                                          RichText(
                                            text: TextSpan(children: [
                                              TextSpan(
                                                text:
                                                    "${doc.data()["itemName"]} : ",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20),
                                              ),
                                              TextSpan(
                                                text:
                                                    doc.data()["usageQuantity"],
                                                style: TextStyle(
                                                    color: MyColors()
                                                        .colorSecondary,
                                                    fontSize: 18),
                                              ),
                                            ]),
                                          ),
                                          SizedBox(height: 5),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ],
                          ),
                        );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Purchase",
              style: TextStyle(color: MyColors().colorSecondary, fontSize: 22),
            ),
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: StreamBuilder(
                stream: db.collection(MyApp.company)
                    .doc(MyApp.company)
                    .collection(company)
                    .doc(company)
                    .collection("DayBook")
                    .doc(date)
                    .collection("purchase")
                    .snapshots(),
                builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return snapshot.data.docs.length == 0
                      ? Container(
                          child: Text(
                            "No Purchase",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...snapshot.data.docs
                                  .map(
                                    (doc) => GestureDetector(
                                      onTap: () {
                                        if (Provider.of<AppUser>(context,
                                                listen: false)
                                            .getUser
                                            .daybookAccess) {
                                          var docs = snapshot.data.docs;
                                          Provider.of<Purchase>(context,
                                                  listen: false)
                                              .setPurchase(docs);
                                          _showPurchaseForm(context, doc.id);
                                        }
                                      },
                                      child: Column(
                                        children: [
                                          RichText(
                                            text: TextSpan(children: [
                                              TextSpan(
                                                text:
                                                    "${doc.data()["itemName"]} : ",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20),
                                              ),
                                              TextSpan(
                                                  text: doc.data()[
                                                      "purchaseQuantity"],
                                                  style: TextStyle(
                                                      color: MyColors()
                                                          .colorSecondary,
                                                      fontSize: 18)),
                                            ]),
                                          ),
                                          SizedBox(height: 5),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ],
                          ),
                        );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Sales",
              style: TextStyle(color: MyColors().colorSecondary, fontSize: 22),
            ),
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: StreamBuilder(
                stream: db.collection(MyApp.company)
                    .doc(MyApp.company)
                    .collection(company)
                    .doc(company)
                    .collection("DayBook")
                    .doc(date)
                    .collection("sales")
                    .snapshots(),
                builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return snapshot.data.docs.length == 0
                      ? Container(
                          child: Text(
                            "No Sales",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                            color: Colors.black26,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...snapshot.data.docs
                                  .map(
                                    (doc) => Container(
                                      width: MediaQuery.of(context).size.width *
                                          67 /
                                          70,
                                      alignment: Alignment.center,
                                      child: ListTile(
                                          onTap: () {
                                            if (Provider.of<AppUser>(context,
                                                    listen: false)
                                                .getUser
                                                .daybookAccess) {
                                              var docs = snapshot.data.docs;
                                              Provider.of<Sales>(context,
                                                      listen: false)
                                                  .setSales(docs);
                                              _showSalesForm(context, doc.id);
                                            }
                                          },
                                          leading: Container(
                                            alignment: Alignment.centerLeft,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                3 /
                                                8,
                                            child: FittedBox(
                                              child: Text(
                                                doc.data()["customerName"],
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 22),
                                              ),
                                            ),
                                          ),
                                          title: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                3 /
                                                7,
                                            height: 30,
                                            child: FittedBox(
                                              child: Text(
                                                doc.data()["typeOfStone"],
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                    color: MyColors()
                                                        .colorSecondary,
                                                    fontSize: 18),
                                              ),
                                            ),
                                          ),
                                          subtitle: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                3 /
                                                7,
                                            height: 30,
                                            child: FittedBox(
                                              child: Text(
                                                doc.data()["salesQuantity"],
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                    color: MyColors()
                                                        .colorSecondary,
                                                    fontSize: 18),
                                              ),
                                            ),
                                          ),
                                          trailing: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  10,
                                              child: (doc.data()[
                                                              "customerPhone"] !=
                                                          null &&
                                                      doc.data()[
                                                              "customerPhone"] !=
                                                          "")
                                                  ? IconButton(
                                                      icon: Icon(
                                                        Icons.call,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed: () {
                                                        _makePhoneCall(
                                                            'tel:${doc.data()["customerPhone"]}');
                                                      },
                                                    )
                                                  : null)),
                                    ),
                                  )
                                  .toList(),
                            ],
                          ),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductionForm(BuildContext context, String id) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text("Production Form"),
        content: AddProductionScreen(id),
      ),
    );
  }

  void _showUsageForm(BuildContext context, String id) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text("Usage Form"),
        content: AddUsageScreen(id),
      ),
    );
  }

  void _showSalesForm(BuildContext context, String id) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              title: Text("Sales Form"),
              content: AddSalesDetails(id),
            ));
  }

  void _showPurchaseForm(BuildContext context, String id) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text("Purchase Form"),
        content: AddPurchaseScreen(id),
      ),
    );
  }

  void _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }
}
