import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indian/constants/colors.dart';
import 'package:indian/providers/company.dart';

import '../main.dart';

class WorkersScreen extends StatelessWidget {
  static const routeName = "/workers";
  var db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Workers"),
      ),
      body: StreamBuilder(
        stream: db
            .collection(MyApp.company)
            .doc(MyApp.company)
            .collection("User")
            .orderBy("name")
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
          var docs = [];
          for (var doc in snapshot.data.docs) {
            if (doc.data()['userType'] != 0) {
              docs.add(doc);
            }
            // docs.add(doc);
          }
          return docs.length == 0
              ? Center(
            child: Text("No workers found"),
          )
              : ListView(
            children: [
              ...docs.map((document) {
                return Column(
                  children: [
                    ListTile(
                      title: Container(
                        height: MediaQuery
                            .of(context)
                            .size
                            .width * 1 / 8,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 1 / 2,
                        alignment: Alignment.center,
                        child: Text(
                          document.data()['name'],
                        ),
                      ),
                      subtitle: Container(
                        alignment: Alignment.center,
                        height:
                        MediaQuery
                            .of(context)
                            .size
                            .width * 1 / 16,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 1 / 2,
                        child: Text(
                          document.data()['phone'],
                        ),
                      ),
                      leading: Container(
                        height: MediaQuery
                            .of(context)
                            .size
                            .width * 1 / 4,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 1 / 4,
                        alignment: Alignment.center,
                        child: document.data()['userCompany'] == null
                            ? Text("Not assigned")
                            : FittedBox(
                          child: Text(
                            document.data()['userCompany'] == 1
                                ? "Company 1"
                                : "Company 2",
                          ),
                        ),
                      ),
                      trailing: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 1 / 4,
                        child: Row(
                          children: [
                            IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (ctx) {
                                        return AlertDialog(
                                          title: Text("Are you sure"),
                                          actions: [
                                            FlatButton(
                                              onPressed: () {
                                                db
                                                    .collection(
                                                    MyApp.company)
                                                    .doc(MyApp.company)
                                                    .collection("User")
                                                    .doc(document.id)
                                                    .delete();
                                                Navigator.of(ctx).pop();
                                              },
                                              child: Text("Delete"),
                                              color: Colors.red,
                                            )
                                          ],
                                        );
                                      });
                                }),
                            IconButton(
                                icon: Icon(Icons.edit,
                                    color: MyColors().colorPrimary),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (ctx) {
                                        String dropdownValue = document
                                            .data()['userType'] ==
                                            1
                                            ? "Supervisor"
                                            : document.data()[
                                        'userType'] ==
                                            3
                                            ? "Office Staff"
                                            : document.data()[
                                        'userType'] ==
                                            4
                                            ? "Marketing Person"
                                            : "Supervisor";
                                        var yesOrNo = document
                                            .data()['daybookAccess']
                                            ? "Yes"
                                            : "No";
                                        var whichCompany = document
                                            .data()['userCompany'];
                                        return SetUser(whichCompany,
                                            document, dropdownValue);
                                      });
                                }),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 2,
                    )
                  ],
                );
              }).toList()
            ],
          );
        },
      ),
    );
  }
}

class SetUser extends StatefulWidget {
  final whichCompany;
  final document;
  var dropdownValue;

  SetUser(this.whichCompany, this.document, this.dropdownValue);

  @override
  _SetUserState createState() => _SetUserState();
}

class _SetUserState extends State<SetUser> {

  @override
  Widget build(BuildContext context) {
    var db = FirebaseFirestore.instance;
    return AlertDialog(
      title: Text("Assign"),
      content: Container(
        height: MediaQuery
            .of(context)
            .size
            .height / 2,
        child: Column(
          children: [
            Text(
              "Company",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            ListTile(
              leading: Radio(
                value: 1,
                groupValue: widget.whichCompany,
                onChanged: (val) {},
              ),
              title: Text("Company 1"),
              onTap: () async {
                db
                    .collection(MyApp.company)
                    .doc(MyApp.company)
                    .collection("User")
                    .doc(widget.document.id)
                    .update({"userCompany": 1, "userType": 3,"daybookAccess" : false});
                Navigator.of(context).pop();
              },
            ),
            Divider(
              thickness: 2,
            ),
            ListTile(
                leading: Radio(
                  value: 2,
                  groupValue: widget.whichCompany,
                  onChanged: (val) {},
                ),
                title: Text("Company 2"),
                onTap: () async {
                  db
                      .collection(MyApp.company)
                      .doc(MyApp.company)
                      .collection("User")
                      .doc(widget.document.id)
                      .update({"userCompany": 2, "userType": 3,"daybookAccess" : false});
                  Navigator.of(context).pop();
                }),
            Divider(
              thickness: 2,
            ),
            SizedBox(height: 10),
            // Text("Daybook Access",
            //     style: TextStyle(
            //         fontWeight:
            //             FontWeight
            //                 .bold,
            //         fontSize: 20)),
            // ListTile(
            //   leading: Container(
            //     width: MediaQuery.of(
            //                 context)
            //             .size
            //             .width /
            //         3,
            //     child: Row(
            //       children: [
            //         Radio(
            //             value: "Yes",
            //             groupValue:
            //                 yesOrNo,
            //             onChanged:
            //                 (value) {
            //               db
            //                   .collection(MyApp
            //                       .company)
            //                   .doc(MyApp
            //                       .company)
            //                   .collection(
            //                       "User")
            //                   .doc(document
            //                       .id)
            //                   .update({
            //                 "daybookAccess": value ==
            //                         "Yes"
            //                     ? true
            //                     : false
            //               });
            //               Navigator.of(
            //                       ctx)
            //                   .pop();
            //             }),
            //         Text("Yes")
            //       ],
            //     ),
            //   ),
            //   trailing: Container(
            //     width: MediaQuery.of(
            //                 context)
            //             .size
            //             .width /
            //         3,
            //     child: Row(
            //       children: [
            //         Radio(
            //             value: "No",
            //             groupValue:
            //                 yesOrNo,
            //             onChanged:
            //                 (value) {
            //               db
            //                   .collection(MyApp
            //                       .company)
            //                   .doc(MyApp
            //                       .company)
            //                   .collection(
            //                       "User")
            //                   .doc(document
            //                       .id)
            //                   .update({
            //                 "daybookAccess": value ==
            //                         "Yes"
            //                     ? true
            //                     : false
            //               });
            //               Navigator.of(
            //                       ctx)
            //                   .pop();
            //             }),
            //         Text("No")
            //       ],
            //     ),
            //   ),
            // )
            DropdownButton(
              value: widget.dropdownValue,
              items: ["Supervisor", "Office Staff", "Marketing Person"]
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) async{
                setState(() {
                  widget.dropdownValue = value;
                });
                await db
                    .collection(MyApp.company)
                    .doc(MyApp.company)
                    .collection("User")
                    .doc(widget.document.id)
                    .update({
                  "userType": widget.dropdownValue == "Supervisor" ? 1 : widget
                      .dropdownValue == "Office Staff" ? 3 : widget
                      .dropdownValue == "Marketing Person" ? 4 : 2,
                  "daybookAccess" : widget.dropdownValue == "Supervisor" ? true : false
                });
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      ),
    );
  }
}
