import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';

import 'package:indian/constants/colors.dart';
import 'package:indian/main.dart';
import 'package:indian/providers/app_users.dart';
import 'package:indian/providers/company.dart';
import 'package:indian/providers/key_words.dart';
import 'package:indian/providers/office_status.dart';
import 'package:indian/screens/home/attendence.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class HomeFragment extends StatelessWidget {
  var db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    var company = Company.name;

    return ListView(
      // itemExtent: MediaQuery.of(context).size.height * 2 / 3,
      children: [
        Card(
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: EdgeInsets.all(10),
          color: MyColors().colorPrimary,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Office Status",
                      style: TextStyle(
                          color: MyColors().colorSecondary, fontSize: 24),
                    ),
                    if (Provider.of<AppUser>(context, listen: false)
                            .getUser
                            .userType ==
                        0)
                      IconButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(AttendanceHistory.routeName);
                        },
                        icon: Icon(
                          Icons.history,
                          color: Colors.white,
                        ),
                      )
                  ],
                ),
                SizedBox(height: 10),
                StreamBuilder(
                  stream: db
                      .collection(MyApp.company)
                      .doc(MyApp.company)
                      .collection(company)
                      .doc(company)
                      .collection("Office")
                      .orderBy("openTime", descending: true)
                      .limit(1)
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

                    List<String> workerList = [];
                    var doc;
                    var office = Office(false, null);
                    if (snapshot.data.docs.length > 0) {
                      doc = snapshot.data.docs[0].data();
                      for (var data in doc.keys.toList()) {
                        if (data != "isOpen" &&
                            data != "openTime" &&
                            data != "machine") {
                          workerList.add(data);
                        }
                      }
                      if (doc['isOpen']) {
                        office = Office(
                          doc['isOpen'],
                          (doc['openTime'] as Timestamp).toDate(),
                        );
                      }
                    }

                    return snapshot.data.docs.length == 0
                        ? Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text: "Date : ",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    TextSpan(
                                        text: DateFormat.yMMMMd()
                                            .format(DateTime.now()),
                                        style: TextStyle(
                                            color: MyColors().colorSecondary,
                                            fontSize: 18)),
                                  ]),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Office not opened yet.",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                                SizedBox(height: 5),
                                RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text: "Machine Status : ",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    TextSpan(
                                      text: "Off",
                                      style: TextStyle(
                                          color: MyColors().colorSecondary,
                                          fontSize: 18),
                                    ),
                                  ]),
                                  // "$worker : Present",
                                  // style: TextStyle(
                                  //     color: Colors.green,
                                  //     fontSize: 16),
                                ),
                                // if (Provider
                                //     .of<AppUser>(context, listen: false)
                                //     .getUser
                                //     .userType ==
                                //     1)
                                Container(
                                  alignment: Alignment.bottomRight,
                                  child: FlatButton.icon(
                                    onPressed: () async {
                                      var loc = await Location().getLocation();
                                      final coordinates = new Coordinates(
                                          loc.latitude, loc.longitude);
                                      var addresses = await Geocoder.local
                                          .findAddressesFromCoordinates(
                                              coordinates);
                                      var location =
                                          addresses.first.subLocality;
                                      String barcode = await scanner.scan();
                                      if (barcode == "I'm present at CR") {
                                        await office.setOffice(
                                            DateTime.now(),
                                            DateFormat.jms()
                                                .format(DateTime.now()),
                                            Provider.of<AppUser>(context,
                                                    listen: false)
                                                .getUser
                                                .name,
                                            location);
                                      } else if (barcode == "Machine On") {
                                        await office.setMachine("On");
                                      } else if (barcode == "Machine Off") {
                                        await office.setMachine("Off");
                                      } else if (barcode == "Machine Repair") {
                                        await office.setMachine("Repair");
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: "Wrong code",
                                            toastLength: Toast.LENGTH_SHORT);
                                      }
                                    },
                                    icon: Icon(Icons.qr_code_scanner),
                                    label: Text("Scan"),
                                    color: Colors.white,
                                    textColor: MyColors().colorPrimary,
                                  ),
                                )
                              ],
                            ))
                        : (snapshot.data.docs[0].id !=
                                DateFormat.yMMMMd().format(DateTime.now()))
                            ? Container(
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
                                                .format(DateTime.now()),
                                            style: TextStyle(
                                                color:
                                                    MyColors().colorSecondary,
                                                fontSize: 18)),
                                      ]),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Office not opened yet.",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    SizedBox(height: 5),
                                    RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text: "Machine Status : ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        TextSpan(
                                          text: "Off",
                                          style: TextStyle(
                                              color: MyColors().colorSecondary,
                                              fontSize: 18),
                                        ),
                                      ]),
                                      // "$worker : Present",
                                      // style: TextStyle(
                                      //     color: Colors.green,
                                      //     fontSize: 16),
                                    ),
                                    // if (Provider
                                    //     .of<AppUser>(context, listen: false)
                                    //     .getUser
                                    //     .userType ==
                                    //     1)
                                    Container(
                                      alignment: Alignment.bottomRight,
                                      child: FlatButton.icon(
                                        onPressed: () async {
                                          var loc =
                                              await Location().getLocation();
                                          final coordinates = new Coordinates(
                                              loc.latitude, loc.longitude);
                                          var addresses = await Geocoder.local
                                              .findAddressesFromCoordinates(
                                                  coordinates);
                                          var location =
                                              addresses.first.subLocality;
                                          String barcode = await scanner.scan();
                                          if (barcode == "I'm present at CR") {
                                            await office.setOffice(
                                                DateTime.now(),
                                                DateFormat.jms()
                                                    .format(DateTime.now()),
                                                Provider.of<AppUser>(context,
                                                        listen: false)
                                                    .getUser
                                                    .name,
                                                location);
                                          } else if (barcode == "Machine On") {
                                            await office.setMachine("On");
                                          } else if (barcode == "Machine Off") {
                                            await office.setMachine("Off");
                                          } else if (barcode ==
                                              "Machine Repair") {
                                            await office.setMachine("Repair");
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: "Wrong code",
                                                toastLength:
                                                    Toast.LENGTH_SHORT);
                                          }
                                        },
                                        icon: Icon(Icons.qr_code_scanner),
                                        label: Text("Scan"),
                                        color: Colors.white,
                                        textColor: MyColors().colorPrimary,
                                      ),
                                    )
                                  ],
                                ))
                            : Container(
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
                                                .format(DateTime.now()),
                                            style: TextStyle(
                                                color:
                                                    MyColors().colorSecondary,
                                                fontSize: 18)),
                                      ]),
                                    ),
                                    if (!office.isOpen) SizedBox(height: 10),
                                    if (!office.isOpen)
                                      Text(
                                        "Office not opened yet.",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    if (office.isOpen) SizedBox(height: 20),
                                    if (office.isOpen)
                                      Text(
                                        "Office opened at ${parseTimestamp(0, office.openTime)}",
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
                                    if (office.isOpen) SizedBox(height: 20),
                                    if (office.isOpen)
                                      ...workerList
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
                                                        text: doc[worker][1],
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
                                                        text: doc[worker][0],
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
                                    // if (Provider
                                    //     .of<AppUser>(context, listen: false)
                                    //     .getUser
                                    //     .userType ==
                                    //     1)
                                    Container(
                                      alignment: Alignment.bottomRight,
                                      child: FlatButton.icon(
                                        onPressed: () async {
                                          var loc =
                                              await Location().getLocation();
                                          final coordinates = new Coordinates(
                                              loc.latitude, loc.longitude);
                                          var addresses = await Geocoder.local
                                              .findAddressesFromCoordinates(
                                                  coordinates);
                                          var location =
                                              addresses.first.subLocality;
                                          String barcode = await scanner.scan();
                                          if (barcode == "I'm present at CR") {
                                            await office.setOffice(
                                                DateTime.now(),
                                                DateFormat.jms()
                                                    .format(DateTime.now()),
                                                Provider.of<AppUser>(context,
                                                        listen: false)
                                                    .getUser
                                                    .name,
                                                location);
                                          } else if (barcode == "Machine On") {
                                            await office.setMachine("On");
                                          } else if (barcode == "Machine Off") {
                                            await office.setMachine("Off");
                                          } else if (barcode ==
                                              "Machine Repair") {
                                            await office.setMachine("Repair");
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: "Wrong code",
                                                toastLength:
                                                    Toast.LENGTH_SHORT);
                                          }
                                        },
                                        icon: Icon(Icons.qr_code_scanner),
                                        label: Text("Scan"),
                                        color: Colors.white,
                                        textColor: MyColors().colorPrimary,
                                      ),
                                    )
                                  ],
                                ));
                  },
                )
              ],
            ),
          ),
        ),
        if (Provider.of<AppUser>(context, listen: false).getUser.userType ==
                1 ||
            Provider.of<AppUser>(context, listen: false).getUser.userType == 0)
          Card(
            elevation: 10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            margin: EdgeInsets.all(10),
            color: MyColors().colorPrimary,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Current Stock",
                        style: TextStyle(
                            color: MyColors().colorSecondary, fontSize: 24),
                      ),
                      if (Company.name == "Company 2")
                        IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    title: Text("Stock item"),
                                    content: StockItem(),
                                  );
                                });
                          },
                          icon: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        )
                    ],
                  ),
                  SizedBox(height: 10),
                  StreamBuilder(
                    stream: db
                        .collection(MyApp.company)
                        .doc(MyApp.company)
                        .collection(company)
                        .doc(company)
                        .collection("Stock")
                        .doc("currentStock")
                        .snapshots(),
                    builder: (_, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      var stock = snapshot.data.data();
                      List consumerMaterial = [];
                      List rawMaterial = [];
                      List<Map<String, String>> keys = [];
                      if (stock != null) {
                        for (var stockKey in stock.keys) {
                          if (stockKey != "date") {
                            keys.add(
                                {"key": stockKey, "unit": stock[stockKey][1]});
                            if (stock[stockKey][1] == "num") {
                              consumerMaterial.add(stockKey);
                            } else {
                              rawMaterial.add(stockKey);
                            }
                          }
                        }
                      }
                      Provider.of<KeyWords>(context, listen: false)
                          .setKeys(keys);
                      var itemController = TextEditingController();
                      return stock == null
                          ? Container()
                          : Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // RichText(
                                  //   text: TextSpan(children: [
                                  //     TextSpan(
                                  //       text: "Last updated : ",
                                  //       style: TextStyle(
                                  //           color: Colors.white, fontSize: 20),
                                  //     ),
                                  //     TextSpan(
                                  //         text: DateFormat.yMMMMd().format(
                                  //             (stock['date'] as Timestamp)
                                  //                 .toDate()),
                                  //         style: TextStyle(
                                  //             color: MyColors().colorSecondary,
                                  //             fontSize: 18)),
                                  //   ]),
                                  //   overflow: TextOverflow.ellipsis,
                                  // ),
                                  // SizedBox(height: 5),
                                  Divider(color: Colors.white24),
                                  if (consumerMaterial.length > 0)
                                    ...consumerMaterial
                                        .map((stockItem) => Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 5),
                                                GestureDetector(
                                                  onTap: () {
                                                    if (Provider.of<AppUser>(
                                                                context,
                                                                listen: false)
                                                            .getUser
                                                            .daybookAccess &&
                                                        Provider.of<AppUser>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .getUser
                                                                .userType ==
                                                            0)
                                                      showDialog(
                                                          context: context,
                                                          builder: (ctx) {
                                                            itemController
                                                                    .text =
                                                                stock[stockItem]
                                                                    [0];
                                                            return AlertDialog(
                                                              title: Text(
                                                                  stockItem),
                                                              content:
                                                                  TextFormField(
                                                                controller:
                                                                    itemController,
                                                                autovalidateMode:
                                                                    AutovalidateMode
                                                                        .always,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                validator:
                                                                    (val) {
                                                                  if (val
                                                                      .isEmpty) {
                                                                    return "Enter some value";
                                                                  }
                                                                  return null;
                                                                },
                                                              ),
                                                              actions: [
                                                                FlatButton(
                                                                    onPressed:
                                                                        () async {
                                                                      if (itemController
                                                                              .text
                                                                              .trim()
                                                                              .length >
                                                                          0) {
                                                                        await db
                                                                            .collection(MyApp.company)
                                                                            .doc(MyApp.company)
                                                                            .collection(company)
                                                                            .doc(company)
                                                                            .collection("Stock")
                                                                            .doc("currentStock")
                                                                            .update({
                                                                          stockItem:
                                                                              [
                                                                            itemController.text,
                                                                            "num"
                                                                          ]
                                                                        });
                                                                        Navigator.of(ctx)
                                                                            .pop();
                                                                      }
                                                                    },
                                                                    child: Text(
                                                                        "Ok")),
                                                              ],
                                                            );
                                                          });
                                                  },
                                                  child: RichText(
                                                    text: TextSpan(children: [
                                                      TextSpan(
                                                        text: "$stockItem : ",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20),
                                                      ),
                                                      TextSpan(
                                                        text: stock[stockItem]
                                                                    [1] ==
                                                                "num"
                                                            ? stock[stockItem]
                                                                [0]
                                                            : stock[stockItem]
                                                                    [0] +
                                                                " " +
                                                                stock[stockItem]
                                                                    [1],
                                                        style: TextStyle(
                                                            color: MyColors()
                                                                .colorSecondary,
                                                            fontSize: 18),
                                                      ),
                                                    ]),
                                                  ),
                                                ),
                                              ],
                                            ))
                                        .toList(),
                                  Divider(color: Colors.white24),
                                  if (rawMaterial.length > 0)
                                    ...rawMaterial
                                        .map((stockItem) => Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 5),
                                                GestureDetector(
                                                  onTap: () {
                                                    if (Provider.of<AppUser>(
                                                                context,
                                                                listen: false)
                                                            .getUser
                                                            .daybookAccess &&
                                                        Provider.of<AppUser>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .getUser
                                                                .userType ==
                                                            0)
                                                      showDialog(
                                                          context: context,
                                                          builder: (ctx) {
                                                            itemController
                                                                    .text =
                                                                stock[stockItem]
                                                                    [0];
                                                            return AlertDialog(
                                                              title: Text(
                                                                  stockItem),
                                                              content:
                                                                  TextField(
                                                                controller:
                                                                    itemController,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                              ),
                                                              actions: [
                                                                FlatButton(
                                                                    onPressed:
                                                                        () async {
                                                                      await db
                                                                          .collection(MyApp
                                                                              .company)
                                                                          .doc(MyApp
                                                                              .company)
                                                                          .collection(
                                                                              company)
                                                                          .doc(
                                                                              company)
                                                                          .collection(
                                                                              "Stock")
                                                                          .doc(
                                                                              "currentStock")
                                                                          .update({
                                                                        stockItem:
                                                                            [
                                                                          itemController
                                                                              .text,
                                                                          stock[stockItem]
                                                                              [
                                                                              1]
                                                                        ]
                                                                      });
                                                                      Navigator.of(
                                                                              ctx)
                                                                          .pop();
                                                                    },
                                                                    child: Text(
                                                                        "Ok")),
                                                              ],
                                                            );
                                                          });
                                                  },
                                                  child: RichText(
                                                    text: TextSpan(children: [
                                                      TextSpan(
                                                        text: "$stockItem : ",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20),
                                                      ),
                                                      TextSpan(
                                                        text: stock[stockItem]
                                                                    [1] ==
                                                                "num"
                                                            ? stock[stockItem]
                                                                [0]
                                                            : stock[stockItem]
                                                                    [0] +
                                                                " " +
                                                                stock[stockItem]
                                                                    [1],
                                                        style: TextStyle(
                                                            color: MyColors()
                                                                .colorSecondary,
                                                            fontSize: 18),
                                                      ),
                                                    ]),
                                                  ),
                                                ),
                                              ],
                                            ))
                                        .toList(),
                                ],
                              ));
                    },
                  )
                ],
              ),
            ),
          ),
      ],
    );
  }

  String parseTimestamp(int type, dynamic timestamp) {
    return DateFormat.jms().format(timestamp);
  }
}

class StockItem extends StatefulWidget {
  @override
  _StockItemState createState() => _StockItemState();
}

class _StockItemState extends State<StockItem> {
  var itemController = TextEditingController();
  var quantityController = TextEditingController();
  String dropdownValue = 'No unit';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: "Item name"),
            controller: itemController,
            autovalidateMode: AutovalidateMode.always,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: "Quantity"),
            controller: quantityController,
            keyboardType: TextInputType.number,
            autovalidateMode: AutovalidateMode.always,
          ),
          SizedBox(height: 20),
          DropdownButton<String>(
            items: <String>["No unit", "Bag", "Kg"]
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                dropdownValue = value;
              });
            },
            value: dropdownValue,
          ),
          SizedBox(
            height: 30,
          ),
          FloatingActionButton(
            onPressed: () async {
              var data = {
                itemController.text: [
                  quantityController.text,
                  dropdownValue == "No unit" ? "num" : dropdownValue
                ]
              };
              try {
                await FirebaseFirestore.instance
                    .collection(MyApp.company)
                    .doc(MyApp.company)
                    .collection(Company.name)
                    .doc(Company.name)
                    .collection("Stock")
                    .doc("currentStock")
                    .update(data);
                Navigator.of(context).pop();
              } catch (e) {
                await FirebaseFirestore.instance
                    .collection(MyApp.company)
                    .doc(MyApp.company)
                    .collection(Company.name)
                    .doc(Company.name)
                    .collection("Stock")
                    .doc("currentStock")
                    .set(data);
                Navigator.of(context).pop();
              }
            },
            child: Icon(Icons.save),
          )
          // Container(
          //   alignment: Alignment.centerRight,
          //   child: FlatButton(
          //     onPressed: () {},
          //     child: Text(
          //       "Save",
          //       style: TextStyle(color: Theme
          //           .of(context)
          //           .primaryColor),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
