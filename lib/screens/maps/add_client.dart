import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indian/constants/colors.dart';
import 'package:indian/providers/client.dart';
import 'package:indian/providers/company.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class AddClient extends StatefulWidget {
  static const routeName = "/add-client";

  @override
  _AddClientState createState() => _AddClientState();
}

class _AddClientState extends State<AddClient> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  PickedFile file;

  File _image;

  bool isLoading = false;
  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add client details"),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Card(
                child: Container(
                  height: 400,
                  width: MediaQuery.of(context).size.width * 3 / 4,
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  child: Form(
                    key: _form,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: nameController,
                            cursorColor: MyColors().colorPrimary,
                            validator: (value) {
                              if (value.length == 0) {
                                return "Fill client name";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                labelText: "Client name",
                                icon: Icon(Icons.person)),
                          ),
                          TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            cursorColor: MyColors().colorPrimary,
                            validator: (value) {
                              if (value.length == 0) {
                                return "Fill client phone number";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                labelText: "Client phone number",
                                icon: Icon(Icons.phone)),
                          ),
                          SizedBox(height: 50),
                          GestureDetector(
                            onTap: () async {
                              file = await ImagePicker().getImage(
                                  source: ImageSource.camera,
                                  maxWidth: 300,
                                  maxHeight: 200);
                              setState(() {
                                _image = File(file.path);
                              });
                            },
                            child: ClipRRect(
                              child: Container(
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height * 1 / 5,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: MyColors().colorPrimary, width: 2),
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
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButtonLocation:
          isLoading ? null : FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isLoading
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () async {
                if (_form.currentState.validate()) {
                  var loc = await Location().getLocation();
                  final coordinates =
                      new Coordinates(loc.latitude, loc.longitude);
                  var addresses = await Geocoder.local
                      .findAddressesFromCoordinates(coordinates);
                  var first = addresses.first;
                  if (_image != null) {
                    setState(() {
                      isLoading = true;
                    });
                    FirebaseStorage storage = FirebaseStorage.instance;
                    var imageName = DateTime.now().toString();
                    var company = Company.name;
                    await storage
                        .ref()
                        .child(company)
                        .child("marketing")
                        .child("images")
                        .child(imageName)
                        .putData(_image.readAsBytesSync());
                    String imageurl = await storage
                        .ref()
                        .child(company)
                        .child("marketing")
                        .child("images")
                        .child(imageName)
                        .getDownloadURL();
                    await ClientModel().addToDb(ClientModel(
                        clientName: nameController.text,
                        clientPhone: phoneController.text,
                        date: DateTime.now(),
                        isStarred: false,
                        siteImage: imageurl,
                        location: first.addressLine));
                    Navigator.of(context).pop();
                  } else {
                    Fluttertoast.showToast(msg: "Please pick an image");
                  }
                }
              },
              child: Icon(Icons.check),
            ),
    );
  }
}
