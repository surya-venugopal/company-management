import 'package:flutter/material.dart';
import 'package:indian/providers/key_words.dart';
import 'package:intl/intl.dart';
import '../../providers/purchase.dart';
import '../../providers/sales.dart';
import 'package:provider/provider.dart';

class AddPurchaseScreen extends StatefulWidget {
  final purchaseId;

  const AddPurchaseScreen(this.purchaseId);

  @override
  _AddPurchaseScreenState createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  DateTime selectedDate;
  final _purchaseDateController = TextEditingController();
  final _purchaseNameController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedPurchaseDetails = PurchaseModel(
    purchaseId: null,
    itemName: "",
    purchaseQuantity: "",
    purchaseDate: null,
  );

  bool flag = true;

  var _initValues = {
    'itemName': '',
    'amount': '',
    'purchaseQuantity': "",
    'purchaseDate': '',
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (widget.purchaseId != "") {
        _editedPurchaseDetails = Provider.of<Purchase>(context, listen: false)
            .findById(widget.purchaseId);
        _purchaseNameController.text = _editedPurchaseDetails.itemName;
        _initValues = {
          'itemName': _editedPurchaseDetails.itemName,
          'purchaseQuantity': _editedPurchaseDetails.purchaseQuantity,
          'purchaseDate': '',
        };
        _purchaseDateController.text = DateFormat('yyyy-MM-dd')
            .format(_editedPurchaseDetails.purchaseDate);
      } else {
        _purchaseDateController.text =
            DateFormat('yyyy-MM-dd').format(DateTime.now());
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _purchaseNameController.dispose();
    _purchaseDateController.dispose();
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
      if (_editedPurchaseDetails.purchaseId != null) {
        await Provider.of<Purchase>(context, listen: false)
            .updatePurchaseDetails(
          _editedPurchaseDetails.purchaseId,
          _editedPurchaseDetails,
          _initValues['itemName'],
          _initValues['purchaseQuantity'],
        );
      } else
        try {
          await Provider.of<Purchase>(context, listen: false)
              .addPurchaseDetails(_editedPurchaseDetails);
        } catch (error) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('An error occurred!'),
              content: Text(error.toString()),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            ),
          );
        }
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
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
                    controller: _purchaseNameController,
                    decoration: InputDecoration(labelText: 'Item Name'),
                    readOnly: true,
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
                                      .getRaw()
                                      .map((key) => Column(
                                            children: [
                                              ListTile(
                                                onTap: () {
                                                  _purchaseNameController.text =
                                                      key;
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
                    validator: (value) {
                      if (value.trim().isEmpty) {
                        return 'Please provide a value.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _editedPurchaseDetails = PurchaseModel(
                        purchaseId: _editedPurchaseDetails.purchaseId,
                        itemName: value.trim(),
                        purchaseQuantity:
                            _editedPurchaseDetails.purchaseQuantity,
                        purchaseDate: _editedPurchaseDetails.purchaseDate,
                      );
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // TextFormField(
                  //   initialValue: _initValues['amount'],
                  //   focusNode: _amountFocusNode,
                  //   decoration: InputDecoration(labelText: 'Amount'),
                  //   keyboardType: TextInputType.number,
                  //   textInputAction: TextInputAction.next,
                  //   onFieldSubmitted: (_) {
                  //     FocusScope.of(context).requestFocus(_quantityFocusNode);
                  //   },
                  //   validator: (value) {
                  //     if (value.isEmpty) {
                  //       return 'Please provide a value.';
                  //     }
                  //     return null;
                  //   },
                  //   onSaved: (value) {
                  //     _editedPurchaseDetails = PurchaseModel(
                  //       purchaseId: _editedPurchaseDetails.purchaseId,
                  //       itemName: _editedPurchaseDetails.itemName,
                  //       purchaseQuantity:
                  //           _editedPurchaseDetails.purchaseQuantity,
                  //       purchaseDate: _editedPurchaseDetails.purchaseDate,
                  //     );
                  //   },
                  // ),
                  // SizedBox(height: 10,),
                  TextFormField(
                    autovalidate: true,
                    initialValue: _initValues['purchaseQuantity'],
                    decoration: InputDecoration(labelText: 'Purchase Quantity'),
                    keyboardType: TextInputType.number,
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
                      _editedPurchaseDetails = PurchaseModel(
                        purchaseId: _editedPurchaseDetails.purchaseId,
                        itemName: _editedPurchaseDetails.itemName,
                        purchaseQuantity: value,
                        purchaseDate: _editedPurchaseDetails.purchaseDate,
                      );
                    },
                  ),
                  if (widget.purchaseId == "")SizedBox(
                    height: 10,
                  ),
                  if (widget.purchaseId == "")TextFormField(
                    autovalidate: true,
                    controller: _purchaseDateController,
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
                          _purchaseDateController.text =
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
                      labelText: 'Purchase Date *',
                    ),
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).unfocus();
                    },
                    textInputAction: TextInputAction.done,
                    onSaved: (value) {
                      _editedPurchaseDetails = PurchaseModel(
                        purchaseId: _editedPurchaseDetails.purchaseId,
                        itemName: _editedPurchaseDetails.itemName,
                        purchaseQuantity:
                            _editedPurchaseDetails.purchaseQuantity,
                        purchaseDate: DateTime.parse(DateFormat('yyyy-MM-dd')
                            .format(DateTime.parse(value))),
                      );
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (widget.purchaseId != "")
                        FloatingActionButton(
                          child: Icon(Icons.delete),
                          onPressed: () async {
                            if (flag) {
                              setState(() {
                                _isLoading = true;
                              });
                              flag = false;
                              await Provider.of<Purchase>(context,
                                      listen: false)
                                  .deleteItem(
                                      DateFormat.yMMMMd().format(
                                          Provider.of<Purchase>(context,
                                                  listen: false)
                                              .findById(widget.purchaseId)
                                              .purchaseDate),
                                      widget.purchaseId,
                                      _initValues['itemName'],
                                      _initValues['purchaseQuantity']);
                              Navigator.of(context).pop();
                            }
                          },
                          backgroundColor: Colors.red,
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
