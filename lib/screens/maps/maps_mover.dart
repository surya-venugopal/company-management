import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indian/constants/colors.dart';
import 'package:indian/providers/app_users.dart';
import 'package:indian/providers/company.dart';
import '../../main.dart';
import 'file:///C:/Users/surya/Desktop/Projects/indian/lib/screens/maps/add_client.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MapsMover extends StatefulWidget {
  @override
  _MapsMoverState createState() => _MapsMoverState();
}

class _MapsMoverState extends State<MapsMover> {
  Location location = new Location();

  var viewType = 0;
  var searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var company = Company.name;
    return Stack(
      children: [
        StreamBuilder(
          stream: viewType == 0
              ? FirebaseFirestore.instance
                  .collection(MyApp.company)
                  .doc(MyApp.company)
                  .collection(company)
                  .doc(company)
                  .collection("MarketingClient")
                  .orderBy("date", descending: true)
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection(MyApp.company)
                  .doc(MyApp.company)
                  .collection(company)
                  .doc(company)
                  .collection("MarketingClient")
                  .where("isStarred", isEqualTo: true)
                  .orderBy("date", descending: true)
                  .snapshots(),
          builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return snapshot.data.docs.length == 0
                ? viewType == 0
                    ? Center(child: Text("No clients visited."))
                    : Center(child: Text("No clients starred."))
                : ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (ctx, index) {
                      var document = snapshot.data.docs[index];
                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                document.data()['siteImage'],
                              ),
                            ),
                            title: Text(document.data()['clientName']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat.yMMMMd()
                                      .format(
                                          (document.data()['date'] as Timestamp)
                                              .toDate())
                                      .toString(),
                                  style: TextStyle(
                                      color: MyColors().colorPrimary,
                                      fontSize: 16),
                                ),

                                Text(
                                  DateFormat.jm()
                                      .format(
                                          (document.data()['date'] as Timestamp)
                                              .toDate())
                                      .toString(),
                                  style: TextStyle(
                                      color: MyColors().colorPrimary,
                                      fontSize: 16),
                                ),
                                // Text(document.data()['date']),
                                Text(document.data()['location']),
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
                                      var isStarred =
                                          !document.data()['isStarred'];
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
                  );
          },
        ),
        Positioned(
          bottom: 5,
          width: MediaQuery.of(context).size.width,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FlatButton(
                  child: viewType == 0 ? Text("All") : Text("Starred"),
                  textColor: MyColors().colorSecondary,
                  color: MyColors().colorPrimary,
                  onPressed: () {
                    setState(() {
                      if (viewType == 1)
                        viewType = 0;
                      else
                        viewType += 1;
                    });
                  },
                ),
                FlatButton.icon(
                  textColor: MyColors().colorSecondary,
                  color: MyColors().colorPrimary,
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).pushNamed(AddClient.routeName);
                  },
                  label: Text("Add client"),
                ),
              ],
            ),
          ),
        ),
      ],
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
