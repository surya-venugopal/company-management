import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indian/constants/colors.dart';
import 'package:indian/providers/company.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../main.dart';

class Search extends SearchDelegate<void> {
  String get searchFieldLabel => 'Search Client';
  var company = Company.name;

  @override
  TextStyle get searchFieldStyle => TextStyle(
        color: Colors.white,
        fontSize: 18.0,
      );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: Theme.of(context).primaryColor,
      primaryColorBrightness: Brightness.light,
      textTheme: TextTheme(
        // ignore: deprecated_member_use
        title: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return null;
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    CollectionReference productSnapshot = FirebaseFirestore.instance
        .collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company)
        .doc(company)
        .collection("MarketingClient");
    return StreamBuilder(
      stream: productSnapshot.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Something went wrong"),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        var products = query.isEmpty
            ? []
            : snapshot.data.docs.where((element) {
                return element
                        .data()["clientName"]
                        .toString()
                        .toUpperCase()
                        .contains(query.toUpperCase()) ||
                    element
                        .data()["clientPhone"]
                        .toString()
                        .toLowerCase()
                        .contains(query.toUpperCase()) ||
                    element
                        .data()["location"]
                        .toString()
                        .toUpperCase()
                        .contains(query.toUpperCase());
              }).toList();
        return products.length > 0
            ? ListView.builder(
          itemCount: products.length,
                itemBuilder: (_, index) {
                  var document = products[index];
                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            document.data()['siteImage'],
                          ),
                        ),
                        title: Text(document.data()['clientName'],style: TextStyle(color: Colors.black),),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat.yMMMMd()
                                  .format((document.data()['date'] as Timestamp)
                                      .toDate())
                                  .toString(),
                              style: TextStyle(
                                  color: MyColors().colorPrimary, fontSize: 16),
                            ),

                            Text(
                              DateFormat.jm()
                                  .format((document.data()['date'] as Timestamp)
                                      .toDate())
                                  .toString(),
                              style: TextStyle(
                                  color: MyColors().colorPrimary, fontSize: 16),
                            ),
                            // Text(document.data()['date']),
                            Text(document.data()['location'],style: TextStyle(color: Colors.black)),
                          ],
                        ),
                        trailing: Container(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.phone),
                                color: MyColors().colorPrimary,
                                onPressed: () {
                                  _makePhoneCall(
                                      'tel:${document.data()['clientPhone']}');
                                },
                              ),
                              IconButton(
                                icon: document.data()['isStarred']
                                    ? Icon(Icons.star)
                                    : Icon(Icons.star_border),
                                color: MyColors().colorPrimary,
                                onPressed: () async {
                                  var isStarred = !document.data()['isStarred'];
                                  await FirebaseFirestore.instance
                                      .collection(MyApp.company)
                                      .doc(MyApp.company)
                                      .collection(company)
                                      .doc(company)
                                      .collection("MarketingClient")
                                      .doc(document.id)
                                      .update({"isStarred": isStarred});
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider()
                    ],
                  );
                },
              )
            : Center(
                child: Text("No Products Found"),
              );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    CollectionReference productSnapshot = FirebaseFirestore.instance
        .collection(MyApp.company)
        .doc(MyApp.company)
        .collection(company)
        .doc(company)
        .collection("MarketingClient");
    return StreamBuilder(
      stream: productSnapshot.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Something went wrong"),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        var products = query.isEmpty
            ? []
            : snapshot.data.docs.where((element) {
                return element
                        .data()["clientName"]
                        .toString()
                        .toUpperCase()
                        .contains(query.toUpperCase()) ||
                    element
                        .data()["clientPhone"]
                        .toString()
                        .toLowerCase()
                        .contains(query.toUpperCase()) ||
                    element
                        .data()["location"]
                        .toString()
                        .toUpperCase()
                        .contains(query.toUpperCase());
              }).toList();
        // products = snapshot.data.docs;
        return products.length > 0
            ? ListView.builder(
          itemCount: products.length,
                itemBuilder: (_, index) {
                  var document = products[index];
                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            document.data()['siteImage'],
                          ),
                        ),
                        title: Text(document.data()['clientName'],style: TextStyle(color: Colors.black)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat.yMMMMd()
                                  .format((document.data()['date'] as Timestamp)
                                      .toDate())
                                  .toString(),
                              style: TextStyle(
                                  color: MyColors().colorPrimary, fontSize: 16),
                            ),

                            Text(
                              DateFormat.jm()
                                  .format((document.data()['date'] as Timestamp)
                                      .toDate())
                                  .toString(),
                              style: TextStyle(
                                  color: MyColors().colorPrimary, fontSize: 16),
                            ),
                            // Text(document.data()['date']),
                            Text(document.data()['location'],style: TextStyle(color: Colors.black)),
                          ],
                        ),
                        trailing: Container(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.phone),
                                color: MyColors().colorPrimary,
                                onPressed: () {
                                  _makePhoneCall(
                                      'tel:${document.data()['clientPhone']}');
                                },
                              ),
                              IconButton(
                                icon: document.data()['isStarred']
                                    ? Icon(Icons.star)
                                    : Icon(Icons.star_border),
                                color: MyColors().colorPrimary,
                                onPressed: () async {
                                  var isStarred = !document.data()['isStarred'];
                                  await FirebaseFirestore.instance
                                      .collection(MyApp.company)
                                      .doc(MyApp.company)
                                      .collection(company)
                                      .doc(company)
                                      .collection("MarketingClient")
                                      .doc(document.id)
                                      .update({"isStarred": isStarred});
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider()
                    ],
                  );
                },
              )
            : Center(
                child: query.isEmpty
                    ? Text("Search any Product")
                    : Text("No Products Found"),
              );
      },
    );
  }

  void _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(msg: 'Could not call $url');
    }
  }
}
