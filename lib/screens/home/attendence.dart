import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:indian/constants/colors.dart';
import 'package:indian/providers/company.dart';
import 'package:indian/providers/office_status.dart';
import 'package:intl/intl.dart';

import '../../main.dart';

class AttendanceHistory extends StatelessWidget {
  static const routeName = "/attendance";
  var db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    var company = Company.name;
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance"),
      ),
      body: StreamBuilder(
        stream: db
            .collection(MyApp.company)
            .doc(MyApp.company)
            .collection(company)
            .doc(company)
            .collection("Office")
            .orderBy("openTime", descending: true)
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

          List<List<String>> workerList = [];
          var doc;
          List<Office> office = [];
          if (snapshot.data.docs.length > 0) {
            for (var docu in snapshot.data.docs) {
              doc = docu.data();
              List<String> workList = [];
              for (var data in doc.keys.toList()) {
                if (data != "isOpen" &&
                    data != "openTime" &&
                    data != "machine") {
                  workList.add(data);
                }
              }
              workerList.add(workList);
              if (doc['isOpen']) {
                office.add(Office(
                  doc['isOpen'],
                  (doc['openTime'] as Timestamp).toDate(),
                ));
              }
            }
            // doc = snapshot.data.docs[0].data();
            // for (var data in doc.keys.toList()) {
            //   if (data != "isOpen" &&
            //       data != "openTime" &&
            //       data != "machine") {
            //     workerList.add(data);
            //   }
            // }
            // if (doc['isOpen']) {
            //   office = Office(
            //     doc['isOpen'],
            //     (doc['openTime'] as Timestamp).toDate(),
            //   );
            // }
          }
          print(workerList);

          return snapshot.data.docs.length == 0
              ? Center(
            child: Text("No entries found"),
          )
              : ListView.builder(
              itemExtent: MediaQuery.of(context).size.width,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (_, index) {
                return Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  margin: EdgeInsets.all(10),
                  color: MyColors().colorPrimary,
                  child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: "Date : ",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20),
                              ),
                              TextSpan(
                                  text: DateFormat.yMMMMd()
                                      .format(office[index].openTime),
                                  style: TextStyle(
                                      color:
                                      MyColors().colorSecondary,
                                      fontSize: 18)),
                            ]),
                          ),
                          if (!office[index].isOpen)
                            SizedBox(height: 10),
                          if (!office[index].isOpen)
                            Text(
                              "Office not opened yet.",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          if (office[index].isOpen)
                            SizedBox(height: 20),
                          if (office[index].isOpen)
                            Text(
                              "Office opened at ${parseTimestamp(0, office[index].openTime)}",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          SizedBox(height: 5),
                          if (snapshot.data.docs[0]
                              .data()['machine'] !=
                              null &&
                              snapshot.data.docs[0]
                                  .data()['machine'] !=
                                  "")
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: "Machine Status : ",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20),
                                ),
                                TextSpan(
                                  text: snapshot.data.docs[0]
                                      .data()['machine'],
                                  style: TextStyle(
                                      color:
                                      MyColors().colorSecondary,
                                      fontSize: 18),
                                ),
                              ]),
                              // "$worker : Present",
                              // style: TextStyle(
                              //     color: Colors.green,
                              //     fontSize: 16),
                            ),
                          if (office[index].isOpen)
                            SizedBox(height: 20),
                          if (office[index].isOpen)
                            ...workerList[index]
                                .map((worker) => Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text: "$worker : ",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20),
                                    ),
                                    TextSpan(
                                      text: snapshot.data.docs[index][worker][1],
                                      style: TextStyle(
                                          color: MyColors()
                                              .colorSecondary,
                                          fontSize: 18),
                                    ),
                                  ]),
                                  // "$worker : Present",
                                  // style: TextStyle(
                                  //     color: Colors.green,
                                  //     fontSize: 16),
                                ),
                                RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text: "Entry at : ",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20),
                                    ),
                                    TextSpan(
                                      text: snapshot.data.docs[index][worker][0],
                                      style: TextStyle(
                                          color: MyColors()
                                              .colorSecondary,
                                          fontSize: 18),
                                    ),
                                  ]),
                                  // "$worker : Present",
                                  // style: TextStyle(
                                  //     color: Colors.green,
                                  //     fontSize: 16),
                                ),
                                SizedBox(height: 20),
                              ],
                            ))
                                .toList(),
                        ],
                      )),
                );
              });
        },
      )
    );
  }

  String parseTimestamp(int type, dynamic timestamp) {
    return DateFormat.jms().format(timestamp);
  }
}
