import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indian/providers/app_users.dart';
import 'package:indian/providers/company.dart';
import 'package:indian/screens/dayBook/add_usage_screen.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../main.dart';
import '../../screens/dayBook/add_production_screen.dart';
import '../../screens/dayBook/add_purchase_screen.dart';
import '../../screens/dayBook/add_sales_screen.dart';
import 'dayBookItem.dart';

class DayBookScreen extends StatelessWidget {
  static const routeName = '/dayBookScreen';
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    var company = Company.name;
    return Scaffold(
      body: Column(
        children: [
          Provider.of<AppUser>(context).getUser.daybookAccess
              ? Container(
                  margin: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 5,
                        child: Column(
                          children: [
                            InkWell(
                              splashColor: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(200),
                              onTap: () => _showProductionForm(context),
                              child: Container(
                                padding: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(200)),
                                  border: Border.all(
                                      color: MyColors().colorPrimary,
                                      style: BorderStyle.solid,
                                      width: 5),
                                  gradient: LinearGradient(
                                      colors: [Colors.black54, Colors.cyan],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 30,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            FittedBox(
                              child: Text(
                                'Production',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (Company.name == "Company 2")Container(
                        width: MediaQuery.of(context).size.width / 5,
                        child: Column(
                          children: [
                            InkWell(
                              splashColor: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(200),
                              onTap: () => _showUsageForm(context),
                              child: Container(
                                padding: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(200)),
                                  border: Border.all(
                                      color: MyColors().colorPrimary,
                                      style: BorderStyle.solid,
                                      width: 5),
                                  gradient: LinearGradient(
                                      colors: [Colors.black54, Colors.cyan],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 30,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            FittedBox(
                              child: Text(
                                'Usage',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 5,
                        child: Column(
                          children: [
                            InkWell(
                              splashColor: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(200),
                              onTap: () => _showPurchaseForm(context),
                              child: Container(
                                padding: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(200)),
                                  border: Border.all(
                                      color: MyColors().colorPrimary,
                                      style: BorderStyle.solid,
                                      width: 5),
                                  gradient: LinearGradient(
                                      colors: [Colors.black54, Colors.cyan],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 30,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            FittedBox(
                              child: Text(
                                'Purchase',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 5,
                        child: Column(
                          children: [
                            InkWell(
                              splashColor: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(200),
                              onTap: () => _showSalesForm(context),
                              child: Container(
                                padding: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(200)),
                                  border: Border.all(
                                      color: MyColors().colorPrimary,
                                      style: BorderStyle.solid,
                                      width: 5),
                                  gradient: LinearGradient(
                                      colors: [Colors.black54, Colors.cyan],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 30,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            FittedBox(
                              child: Text(
                                'Sales',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: Colors.black12,
              ),
              child: StreamBuilder(
                stream: db.collection(MyApp.company)
                    .doc(MyApp.company)
                    .collection(company)
                    .doc(company)
                    .collection("DayBook")
                    .orderBy("date", descending: true)
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

                  var length = snapshot.data.docs.length;
                  return length == 0
                      ? Center(
                          child: Text("Nothing is added"),
                        )
                      : ListView.builder(
                          // itemExtent: MediaQuery.of(context).size.height*3/4,
                          itemBuilder: (_, index) {
                            var doc = snapshot.data.docs[index];
                            return DayBookItem(doc.id);
                          },
                          itemCount: length,
                        );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProductionForm(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text("Production Form"),
        content: AddProductionScreen(""),
      ),
    );
  }

  void _showUsageForm(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text("Usage Form"),
        content: AddUsageScreen(""),
      ),
    );
  }

  void _showSalesForm(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              title: Text("Sales Form"),
              content: AddSalesDetails(""),
            ));
  }

  void _showPurchaseForm(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text("Purchase Form"),
        content: AddPurchaseScreen(""),
      ),
    );
  }
}
