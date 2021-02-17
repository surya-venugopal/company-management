import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indian/constants/colors.dart';
import 'package:indian/providers/company.dart';
import 'package:indian/providers/daily.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class DailyUpdates extends StatefulWidget {
  @override
  _DailyUpdatesState createState() => _DailyUpdatesState();
}

class _DailyUpdatesState extends State<DailyUpdates> {
  var db = FirebaseFirestore.instance;
  PickedFile file;
  File _image;
  TextEditingController descriptionController = TextEditingController();
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    var company = Company.name;
    return Stack(
      children: [
        StreamBuilder(
            stream: db.collection(MyApp.company)
                .doc(MyApp.company)
                .collection(company)
                .doc(company)
                .collection("Daily")
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

              var docs = snapshot.data.docs;

              return docs.length == 0
                  ? Center(
                      child: Text("Nothing to show."),
                    )
                  : ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (ctx, index) {
                        return Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          color: MyColors().colorPrimary,
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              1 /
                                              3,
                                      child: Image.network(
                                        docs[index].data()['imageUrl'],
                                        fit: BoxFit.fill,
                                      ),
                                    )),
                                SizedBox(height: 10),
                                Text(
                                  DateFormat.yMMMMd()
                                      .format((docs[index].data()['date']
                                              as Timestamp)
                                          .toDate())
                                      .toString(),
                                  style: TextStyle(
                                      color: Colors.pink, fontSize: 18),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  DateFormat.jm()
                                      .format((docs[index].data()['date']
                                              as Timestamp)
                                          .toDate())
                                      .toString(),
                                  style: TextStyle(
                                      color: Colors.pink, fontSize: 18),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  docs[index].data()['description'],
                                  style: TextStyle(
                                      color: MyColors().colorSecondary,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
            }),
        Positioned(
          bottom: 5,
          right: 20,
          child: FlatButton.icon(
            textColor: MyColors().colorPrimary,
            color: MyColors().colorSecondary,
            icon: Icon(Icons.add),
            onPressed: () async {
              file = await ImagePicker().getImage(
                  source: ImageSource.camera, maxWidth: 500, maxHeight: 500);
              setState(() {
                _image = File(file.path);
              });
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) {
                    return AlertDialog(
                      title: Text("Action"),
                      content: isLoading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width,
                              height:
                                  MediaQuery.of(context).size.height * 1 / 2,
                              child: Column(
                                children: [
                                  ClipRRect(
                                    child: Container(
                                      width: double.infinity,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              1 /
                                              5,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: MyColors().colorPrimary,
                                            width: 2),
                                      ),
                                      child: _image != null
                                          ? Image.file(
                                              _image,
                                              fit: BoxFit.cover,
                                            )
                                          : Icon(
                                              Icons.camera_alt,
                                              size: 35,
                                            ),
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  TextField(
                                    controller: descriptionController,
                                    decoration: InputDecoration(
                                        labelText: "Description"),
                                  ),
                                ],
                              ),
                            ),
                      actions: [
                        FlatButton(
                          onPressed: () async {
                            if (descriptionController.text.trim().length > 0) {
                              if (!isLoading) {
                                Fluttertoast.showToast(
                                    msg: "Please Wait.",
                                    toastLength: Toast.LENGTH_LONG);
                                isLoading = true;
                                FirebaseStorage storage =
                                    FirebaseStorage.instance;
                                var imageName = DateTime.now().toString();
                                await storage
                                    .ref()
                                    .child(company)
                                    .child("daily")
                                    .child("images")
                                    .child(imageName)
                                    .putData(_image.readAsBytesSync());
                                String imageurl = await storage
                                    .ref()
                                    .child(company)
                                    .child("daily")
                                    .child("images")
                                    .child(imageName)
                                    .getDownloadURL();
                                var daily = Daily(DateTime.now(), imageurl,
                                    descriptionController.text);
                                await daily.setDaily();
                                Navigator.of(ctx).pop();
                              }
                            } else {
                              Fluttertoast.showToast(msg: "Enter Description.");
                            }
                          },
                          child: Text("Confirm"),
                          color: MyColors().colorPrimary,
                          textColor: MyColors().colorSecondary,
                        )
                      ],
                    );
                  });
            },
            label: Text("Add"),
          ),
        ),
      ],
    );
  }
}

class DailyForm extends StatefulWidget {
  @override
  _DailyFormState createState() => _DailyFormState();
}

class _DailyFormState extends State<DailyForm> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
