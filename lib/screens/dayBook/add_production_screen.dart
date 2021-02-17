import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:indian/providers/company.dart';
import 'package:indian/providers/key_words.dart';
import 'package:indian/providers/ratio.dart';
import 'package:indian/providers/usage.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../providers/production.dart';
import 'package:provider/provider.dart';

class AddProductionScreen extends StatefulWidget {
  final productionId;

  const AddProductionScreen(this.productionId);

  @override
  _AddProductionScreenState createState() => _AddProductionScreenState();
}

class _AddProductionScreenState extends State<AddProductionScreen> {
  DateTime selectedDate;

  var db = FirebaseFirestore.instance;

  var _productionDateController = TextEditingController();
  var _productionNameController = TextEditingController();
  var _productionQuantityController = TextEditingController();

  final _form = GlobalKey<FormState>();
  var _editedDayBookDetails = ProductionModel(
    productionId: null,
    stoneName: "",
    productionDate: null,
    productionQuantity: "",
  );

  bool flag = true;

  var _initValues = {
    'stoneName': "",
    'productionDate': '',
    'productionQuantity': '',
  };

  var _isInit = true;
  var _isLoading = false;

  String dropdownValue;
  List<String> dropdownList;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      if (widget.productionId != "") {
        _editedDayBookDetails = Provider.of<Production>(context, listen: false)
            .findById(widget.productionId);
        _productionNameController.text = _editedDayBookDetails.stoneName;
        _productionQuantityController.text =
            _editedDayBookDetails.productionQuantity;

        QuerySnapshot snap = await db
            .collection(MyApp.company)
            .doc(MyApp.company)
            .collection(Company.name)
            .doc(Company.name)
            .collection("DayBook")
            .doc(DateFormat.yMMMMd()
                .format(_editedDayBookDetails.productionDate))
            .collection("usage")
            .get();

        _initValues = {
          'stoneName': _editedDayBookDetails.stoneName,
          'productionDate': '',
          'productionQuantity':
              _editedDayBookDetails.productionQuantity.toString(),
          'ash': (Company.name != "Company 1")?null:snap.docs
              .firstWhere((element) =>
                  element.data()['itemName'].toString().contains("ash"))
              .data()['itemName']
        };

        if (Company.name == "Company 1")
          setState(() {
            dropdownValue = _initValues['ash'];
          });
        _productionDateController.text = DateFormat('yyyy-MM-dd')
            .format(_editedDayBookDetails.productionDate);
      } else {
        _productionDateController.text =
            DateFormat('yyyy-MM-dd').format(DateTime.now());
        if (Company.name == "Company 1") dropdownList = Provider.of<KeyWords>(context, listen: false)
            .getRaw()
            .where((element) => element.toLowerCase().contains("ash"))
            .toList();
        if (Company.name == "Company 1") dropdownValue = dropdownList[0];
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _productionNameController.dispose();
    _productionDateController.dispose();
    _productionQuantityController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    if (flag) {
      flag = false;
      _form.currentState.save();
      setState(() {
        _isLoading = true;
      });
      var stoneRatio = Ratios.stoneKeys[_editedDayBookDetails.stoneName];
      if (_editedDayBookDetails.productionId != null) {
        await Provider.of<Production>(context, listen: false)
            .updateProductionDetails(
                _editedDayBookDetails.productionId.toString(),
                _editedDayBookDetails,
                _initValues['stoneName'],
                _initValues['productionQuantity']);

        ////////////////////////////
        if (Company.name == "Company 1") {
          await db
              .collection(MyApp.company)
              .doc(MyApp.company)
              .collection(Company.name)
              .doc(Company.name)
              .collection("DayBook")
              .doc(DateFormat.yMMMMd()
                  .format(_editedDayBookDetails.productionDate))
              .collection("usage")
              .get()
              .then((snapshot) async {
            if (snapshot.docs.length > 0) {
              var doc = snapshot.docs.firstWhere(
                  (element) => element.data()['itemName'] == "cement");
              if (doc != null) {
                await Provider.of<Usage>(context, listen: false)
                    .updateUsageDetails(
                  doc.id,
                  UsageModel(
                    usageId: doc.id,
                    itemName: "cement",
                    usageQuantity: (double.parse(
                                _editedDayBookDetails.productionQuantity) *
                            stoneRatio['kg'] *
                            stoneRatio['cement'] /
                            50)
                        .ceil()
                        .toString(),
                    usageDate: _editedDayBookDetails.productionDate,
                  ),
                  "cement",
                  doc.data()['usageQuantity'],
                );
              }
              doc = snapshot.docs.firstWhere((element) =>
                  element.data()['itemName'] == _initValues['ash']);
              if (doc != null) {
                await Provider.of<Usage>(context, listen: false)
                    .updateUsageDetails(
                  doc.id,
                  UsageModel(
                    usageId: doc.id,
                    itemName: dropdownValue,
                    usageQuantity: (double.parse(
                                _editedDayBookDetails.productionQuantity) *
                            stoneRatio['kg'] *
                            stoneRatio['ash'])
                        .ceil()
                        .toString(),
                    usageDate: _editedDayBookDetails.productionDate,
                  ),
                  doc.data()['itemName'],
                  doc.data()['usageQuantity'],
                );
              }
              doc = snapshot.docs.firstWhere(
                  (element) => element.data()['itemName'] == "limestone");
              if (doc != null) {
                await Provider.of<Usage>(context, listen: false)
                    .updateUsageDetails(
                  doc.id,
                  UsageModel(
                    usageId: doc.id,
                    itemName: "limestone",
                    usageQuantity: (double.parse(
                                _editedDayBookDetails.productionQuantity) *
                            stoneRatio['kg'] *
                            stoneRatio['limestone'])
                        .ceil()
                        .toString(),
                    usageDate: _editedDayBookDetails.productionDate,
                  ),
                  "limestone",
                  doc.data()['usageQuantity'],
                );
              }
              doc = snapshot.docs.firstWhere(
                  (element) => element.data()['itemName'] == "dust");
              if (doc != null) {
                await Provider.of<Usage>(context, listen: false)
                    .updateUsageDetails(
                  doc.id,
                  UsageModel(
                    usageId: doc.id,
                    itemName: "dust",
                    usageQuantity: (double.parse(
                                _editedDayBookDetails.productionQuantity) *
                            stoneRatio['kg'] *
                            stoneRatio['dust'])
                        .ceil()
                        .toString(),
                    usageDate: _editedDayBookDetails.productionDate,
                  ),
                  "dust",
                  doc.data()['usageQuantity'],
                );
              }
            }
          });
        }
      } else {
        await Provider.of<Production>(context, listen: false)
            .addProductionDetails(_editedDayBookDetails);
////////////////////////////////////////
        if (Company.name == "Company 1") {
          await Provider.of<Usage>(context, listen: false)
              .addUsageDetails(UsageModel(
            usageId: null,
            itemName: "cement",
            usageQuantity:
                (double.parse(_editedDayBookDetails.productionQuantity) *
                        stoneRatio['kg'] *
                        stoneRatio['cement'] /
                        50)
                    .ceil()
                    .toString(),
            usageDate: _editedDayBookDetails.productionDate,
          ));
          await Provider.of<Usage>(context, listen: false)
              .addUsageDetails(UsageModel(
            usageId: null,
            itemName: dropdownValue,
            usageQuantity:
                (double.parse(_editedDayBookDetails.productionQuantity) *
                        stoneRatio['kg'] *
                        stoneRatio['ash'])
                    .ceil()
                    .toString(),
            usageDate: _editedDayBookDetails.productionDate,
          ));
          await Provider.of<Usage>(context, listen: false)
              .addUsageDetails(UsageModel(
            usageId: null,
            itemName: "limestone",
            usageQuantity:
                (double.parse(_editedDayBookDetails.productionQuantity) *
                        stoneRatio['kg'] *
                        stoneRatio['limestone'])
                    .ceil()
                    .toString(),
            usageDate: _editedDayBookDetails.productionDate,
          ));
          await Provider.of<Usage>(context, listen: false)
              .addUsageDetails(UsageModel(
            usageId: null,
            itemName: "dust",
            usageQuantity:
                (double.parse(_editedDayBookDetails.productionQuantity) *
                        stoneRatio['kg'] *
                        stoneRatio['dust'])
                    .ceil()
                    .toString(),
            usageDate: _editedDayBookDetails.productionDate,
          ));
        }
      }
      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Company.name == "Company 1") dropdownList = Provider.of<KeyWords>(context, listen: false)
        .getRaw()
        .where((element) => element.toLowerCase().contains("ash"))
        .toList();
    return _isLoading
        ? Container(
            width: 200,
            height: 200,
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Please wait")
                ],
              ),
            ),
          )
        : Container(
            height: MediaQuery.of(context).size.height / 2,
            width: 500,
            // padding: const EdgeInsets.all(20),
            child: Form(
              key: _form,
              child: ListView(
                children: [
                  TextFormField(
                    autovalidate: true,
                    onTap: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text("Keys"),
                          content: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: ListView(
                              children:
                                  (Provider.of<KeyWords>(context, listen: false)
                                      .getStone()
                                      .map((key) => Column(
                                            children: [
                                              ListTile(
                                                onTap: () {
                                                  _productionNameController
                                                      .text = key;
                                                  Navigator.of(ctx).pop();
                                                },
                                                title: Text(key),
                                              ),
                                              Divider(
                                                color: Colors.black54,
                                              ),
                                            ],
                                          ))
                                      .toList()),
                            ),
                          ),
                        ),
                      );
                    },
                    controller: _productionNameController,
                    decoration: InputDecoration(labelText: 'Stone Name'),
                    readOnly: true,
                    validator: (value) {
                      if (value.trim().isEmpty) {
                        return 'Please provide a value.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _editedDayBookDetails = ProductionModel(
                        productionId: _editedDayBookDetails.productionId,
                        stoneName: value.trim(),
                        productionDate: _editedDayBookDetails.productionDate,
                        productionQuantity:
                            _editedDayBookDetails.productionQuantity,
                      );
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _productionQuantityController,
                    autovalidate: true,
                    // initialValue: _initValues['productionQuantity'],
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(labelText: 'Production Quantity'),
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value.trim().isEmpty) {
                        return 'Please provide a value.';
                      }
                      if (value.trim().contains(".") ||
                          value.trim().contains(",") ||
                          value.trim().contains("-") ||
                          value.trim().contains(" ")) {
                        return 'Invalid Input';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _editedDayBookDetails = ProductionModel(
                        productionId: _editedDayBookDetails.productionId,
                        stoneName: _editedDayBookDetails.stoneName,
                        productionDate: _editedDayBookDetails.productionDate,
                        productionQuantity: value,
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Ash used :",
                    style: TextStyle(fontSize: 14),
                  ),
                  if (Company.name == "Company 1")
                    DropdownButton<String>(
                      items: dropdownList
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
                  if (widget.productionId == "")
                    SizedBox(
                      height: 10,
                    ),
                  if (widget.productionId == "")
                    TextFormField(
                      autovalidate: true,
                      controller: _productionDateController,
                      onTap: () {
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1965),
                          lastDate: DateTime.now(),
                        ).then((value) {
                          if (value == null) return;
                          setState(() {
                            selectedDate = value;
                            _productionDateController.text =
                                selectedDate.toString().substring(0, 10);
                          });
                        });
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.date_range),
                        labelText: 'Production Date',
                      ),
                      onSaved: (value) {
                        _editedDayBookDetails = ProductionModel(
                          productionId: _editedDayBookDetails.productionId,
                          stoneName: _editedDayBookDetails.stoneName,
                          productionDate: DateTime.parse(
                              DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(value))),
                          productionQuantity:
                              _editedDayBookDetails.productionQuantity,
                        );
                      },
                    ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (widget.productionId != "")
                        FloatingActionButton(
                          child: Icon(Icons.delete),
                          backgroundColor: Colors.red,
                          onPressed: () async {
                            if (flag) {
                              setState(() {
                                _isLoading = true;
                              });
                              flag = false;
                              await Provider.of<Production>(context,
                                      listen: false)
                                  .deleteItem(
                                      DateFormat.yMMMMd().format(
                                          Provider.of<Production>(context,
                                                  listen: false)
                                              .findById(widget.productionId)
                                              .productionDate),
                                      widget.productionId,
                                      _initValues['stoneName'],
                                      _initValues['productionQuantity']);
                              if (Company.name == "Company 1") {
                                await db
                                    .collection(MyApp.company)
                                    .doc(MyApp.company)
                                    .collection(Company.name)
                                    .doc(Company.name)
                                    .collection("DayBook")
                                    .doc(DateFormat.yMMMMd().format(
                                        _editedDayBookDetails.productionDate))
                                    .collection("usage")
                                    .get()
                                    .then((snapshot) {
                                  snapshot.docs.forEach((doc) async {
                                    await Provider.of<Usage>(context,
                                            listen: false)
                                        .deleteItem(
                                            DateFormat.yMMMMd().format(Provider
                                                    .of<Production>(context,
                                                        listen: false)
                                                .findById(widget.productionId)
                                                .productionDate),
                                            doc.id,
                                            UsageModel(
                                                usageId: doc.id,
                                                itemName:
                                                    doc.data()['itemName'],
                                                usageQuantity:
                                                    doc.data()['usageQuantity'],
                                                usageDate: Provider.of<
                                                            Production>(context,
                                                        listen: false)
                                                    .findById(
                                                        widget.productionId)
                                                    .productionDate));
                                  });
                                });
                              }

                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      FloatingActionButton(
                        child: Icon(Icons.save),
                        onPressed: () {
                          _saveForm();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}
