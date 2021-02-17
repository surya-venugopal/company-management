import 'package:flutter/material.dart';
import 'package:indian/providers/key_words.dart';
import 'package:intl/intl.dart';
import '../../providers/sales.dart';
import 'package:provider/provider.dart';

class AddSalesDetails extends StatefulWidget {
  final saleId;

  const AddSalesDetails(this.saleId);

  @override
  _AddSalesDetailsState createState() => _AddSalesDetailsState();
}

class _AddSalesDetailsState extends State<AddSalesDetails> {
  DateTime selectedDate;
  final _salesDateController = TextEditingController();
  final _salesNameController = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool flag = true;
  var _editedSalesDetails = SalesModel(
      saleId: null,
      customerName: '',
      customerPhone: '',
      typeOfStone: '',
      salesQuantity: "",
      salesDate: null);

  var _initValues = {
    'customerName': '',
    'customerPhone': '',
    'typeOfStone': '',
    'salesAmount': '',
    'salesQuantity': '',
    'salesDate': ''
  };

  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (widget.saleId != "") {
        _editedSalesDetails =
            Provider.of<Sales>(context, listen: false).findById(widget.saleId);
        _salesNameController.text = _editedSalesDetails.typeOfStone;
        _initValues = {
          'customerName': _editedSalesDetails.customerName,
          'customerPhone': _editedSalesDetails.customerPhone,
          'typeOfStone': _editedSalesDetails.typeOfStone,
          'salesQuantity': _editedSalesDetails.salesQuantity.toString(),
          'salesDate': '',
        };
        _salesDateController.text =
            DateFormat('yyyy-MM-dd').format(_editedSalesDetails.salesDate);
      } else {
        _salesDateController.text =
            DateFormat('yyyy-MM-dd').format(DateTime.now());
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _salesDateController.dispose();
    _salesNameController.dispose();
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
      if (_editedSalesDetails.saleId != null) {
        await Provider.of<Sales>(context, listen: false).updateSalesDetails(
            _editedSalesDetails.saleId,
            _editedSalesDetails,
            _initValues['typeOfStone'],
            _initValues['salesQuantity']);
      } else {
        await Provider.of<Sales>(context, listen: false)
            .addSalesDetails(_editedSalesDetails);
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
            height: MediaQuery.of(context).size.height /2,
            width: 500,
            // padding: const EdgeInsets.all(20),
            child: Form(
              key: _form,
              child: ListView(
                children: [
                  TextFormField(
                    autovalidate: true,
                    initialValue: _initValues['customerName'],
                    decoration: InputDecoration(labelText: 'Customer Name'),
                    validator: (value) {
                      if (value.trim().isEmpty) {
                        return 'Please provide a value.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _editedSalesDetails = SalesModel(
                          saleId: _editedSalesDetails.saleId,
                          customerName: value.trim(),
                          customerPhone: _editedSalesDetails.customerPhone,
                          typeOfStone: _editedSalesDetails.typeOfStone,
                          salesQuantity: _editedSalesDetails.salesQuantity,
                          salesDate: _editedSalesDetails.salesDate);
                    },
                  ),

                  // TextFormField(
                  //   autovalidate: true,
                  //   initialValue: _initValues['customerPhone'],
                  //   decoration: InputDecoration(labelText: 'Customer Phone'),
                  //   keyboardType: TextInputType.number,
                  //   validator: (value) {
                  //     // if (value.isEmpty) {
                  //     //   return 'Please provide a value.';
                  //     // }
                  //     return null;
                  //   },
                  //   onSaved: (value) {
                  //     _editedSalesDetails = SalesModel(
                  //         saleId: _editedSalesDetails.saleId,
                  //         customerName: _editedSalesDetails.customerName,
                  //         customerPhone: value.trim(),
                  //         typeOfStone: _editedSalesDetails.typeOfStone,
                  //         salesQuantity: _editedSalesDetails.salesQuantity,
                  //         salesDate: _editedSalesDetails.salesDate);
                  //   },
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    autovalidate: true,
                    onTap: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text("Keys"),
                          content: Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: ListView(
                              children:
                                  (Provider.of<KeyWords>(context, listen: false)
                                      .getStone()
                                      .map((key) => Column(
                                            children: [
                                              ListTile(
                                                onTap: () {
                                                  _salesNameController.text =
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
                    decoration: InputDecoration(labelText: 'Stone Name'),
                    controller: _salesNameController,
                    readOnly: true,
                    validator: (value) {
                      if (value.trim().isEmpty) {
                        return 'Please provide a value.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _editedSalesDetails = SalesModel(
                          saleId: _editedSalesDetails.saleId,
                          customerName: _editedSalesDetails.customerName,
                          customerPhone: _editedSalesDetails.customerPhone,
                          typeOfStone: value.trim(),
                          salesQuantity: _editedSalesDetails.salesQuantity,
                          salesDate: _editedSalesDetails.salesDate);
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // TextFormField(
                  //   initialValue: _initValues['salesAmount'],
                  //   focusNode: _salesAmountFocusNode,
                  //   decoration: InputDecoration(labelText: 'Sales Amount'),
                  //   keyboardType: TextInputType.number,
                  //   textInputAction: TextInputAction.next,
                  //   onFieldSubmitted: (_) {
                  //     FocusScope.of(context)
                  //         .requestFocus(_salesQuantityFocusNode);
                  //   },
                  //   validator: (value) {
                  //     if (value.isEmpty) {
                  //       return 'Please provide a value.';
                  //     }
                  //     return null;
                  //   },
                  //   onSaved: (value) {
                  //     _editedSalesDetails = SalesModel(
                  //         saleId: _editedSalesDetails.saleId,
                  //         customerName: _editedSalesDetails.customerName,
                  //         customerPhone: _editedSalesDetails.customerPhone,
                  //         typeOfStone: _editedSalesDetails.typeOfStone,
                  //         salesQuantity: _editedSalesDetails.salesQuantity,
                  //         salesDate: _editedSalesDetails.salesDate);
                  //   },
                  // ),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  TextFormField(
                    autovalidate: true,
                    initialValue: _initValues['salesQuantity'],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Sales Quantity'),
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
                      _editedSalesDetails = SalesModel(
                          saleId: _editedSalesDetails.saleId,
                          customerName: _editedSalesDetails.customerName,
                          customerPhone: _editedSalesDetails.customerPhone,
                          typeOfStone: _editedSalesDetails.typeOfStone,
                          salesQuantity: value,
                          salesDate: _editedSalesDetails.salesDate);
                    },
                  ),
                  if (widget.saleId == "") SizedBox(
                    height: 10,
                  ),
                  if (widget.saleId == "")TextFormField(
                    autovalidate: true,
                    controller: _salesDateController,
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
                          _salesDateController.text =
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
                      labelText: 'Sales Date',
                    ),
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).unfocus();
                    },
                    textInputAction: TextInputAction.done,
                    onSaved: (value) {
                      _editedSalesDetails = SalesModel(
                          saleId: _editedSalesDetails.saleId,
                          customerName: _editedSalesDetails.customerName,
                          customerPhone: _editedSalesDetails.customerPhone,
                          typeOfStone: _editedSalesDetails.typeOfStone,
                          salesQuantity: _editedSalesDetails.salesQuantity,
                          salesDate: DateTime.parse(DateFormat('yyyy-MM-dd')
                              .format(DateTime.parse(value))));
                    },
                  ),

                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (widget.saleId != "")
                        FloatingActionButton(
                          backgroundColor: Colors.red,
                          child: Icon(Icons.delete),
                          onPressed: () async {
                            if (flag) {
                              flag = false;
                              setState(() {
                                _isLoading = true;
                              });
                              await Provider.of<Sales>(context, listen: false)
                                  .deleteItem(
                                      DateFormat.yMMMMd().format(
                                          Provider.of<Sales>(context,
                                                  listen: false)
                                              .findById(widget.saleId)
                                              .salesDate),
                                      widget.saleId,
                                      _editedSalesDetails);
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
