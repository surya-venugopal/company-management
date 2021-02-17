import 'package:flutter/material.dart';
import 'package:indian/providers/key_words.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/usage.dart';

class AddUsageScreen extends StatefulWidget {
  final usageId;

  const AddUsageScreen(this.usageId);

  @override
  _AddUsageScreenState createState() => _AddUsageScreenState();
}

class _AddUsageScreenState extends State<AddUsageScreen> {
  DateTime selectedDate;
  final _usageDateController = TextEditingController();
  final _usageNameController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedUsageDetails = UsageModel(
    usageId: null,
    itemName: "",
    usageQuantity: "",
    usageDate: null,
  );

  bool flag = true;

  var _initValues = {
    'itemName': '',
    'amount': '',
    'usageQuantity': "",
    'usageDate': '',
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (widget.usageId != "") {
        _editedUsageDetails =
            Provider.of<Usage>(context, listen: false).findById(widget.usageId);
        _usageNameController.text = _editedUsageDetails.itemName;
        _initValues = {
          'itemName': _editedUsageDetails.itemName,
          'usageQuantity': _editedUsageDetails.usageQuantity,
          'usageDate': '',
        };
        _usageDateController.text =
            DateFormat('yyyy-MM-dd').format(_editedUsageDetails.usageDate);
      } else {
        _usageDateController.text =
            DateFormat('yyyy-MM-dd').format(DateTime.now());
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _usageNameController.dispose();
    _usageDateController.dispose();
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
      if (_editedUsageDetails.usageId != null) {
        await Provider.of<Usage>(context, listen: false).updateUsageDetails(
          _editedUsageDetails.usageId,
          _editedUsageDetails,
          _initValues['itemName'],
          _initValues['usageQuantity'],
        );
      } else {
        await Provider.of<Usage>(context, listen: false)
            .addUsageDetails(_editedUsageDetails);
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
                    controller: _usageNameController,
                    decoration: InputDecoration(labelText: 'Item Name'),
                    keyboardType: TextInputType.name,
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
                                                  _usageNameController.text =
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
                      _editedUsageDetails = UsageModel(
                        usageId: _editedUsageDetails.usageId,
                        itemName: value.trim(),
                        usageQuantity: _editedUsageDetails.usageQuantity,
                        usageDate: _editedUsageDetails.usageDate,
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
                  //     _editedusageDetails = usageModel(
                  //       usageId: _editedusageDetails.usageId,
                  //       itemName: _editedusageDetails.itemName,
                  //       usageQuantity:
                  //           _editedusageDetails.usageQuantity,
                  //       usageDate: _editedusageDetails.usageDate,
                  //     );
                  //   },
                  // ),
                  // SizedBox(height: 10,),
                  TextFormField(
                    autovalidate: true,
                    initialValue: _initValues['usageQuantity'],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'usage Quantity'),
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
                      _editedUsageDetails = UsageModel(
                        usageId: _editedUsageDetails.usageId,
                        itemName: _editedUsageDetails.itemName,
                        usageQuantity: value,
                        usageDate: _editedUsageDetails.usageDate,
                      );
                    },
                  ),
                  if (widget.usageId == "")
                    SizedBox(
                      height: 10,
                    ),
                  if (widget.usageId == "")
                    TextFormField(
                      autovalidate: true,
                      controller: _usageDateController,
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
                            _usageDateController.text =
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
                        labelText: 'Usage Date *',
                      ),
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).unfocus();
                      },
                      textInputAction: TextInputAction.done,
                      onSaved: (value) {
                        _editedUsageDetails = UsageModel(
                          usageId: _editedUsageDetails.usageId,
                          itemName: _editedUsageDetails.itemName,
                          usageQuantity: _editedUsageDetails.usageQuantity,
                          usageDate: DateTime.parse(DateFormat('yyyy-MM-dd')
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
                      if (widget.usageId != "")
                        FloatingActionButton(
                          child: Icon(Icons.delete),
                          onPressed: () async {
                            if (flag) {
                              flag = false;
                              setState(() {
                                _isLoading = true;
                              });
                              await Provider.of<Usage>(context, listen: false)
                                  .deleteItem(
                                      DateFormat.yMMMMd().format(
                                          Provider.of<Usage>(context,
                                                  listen: false)
                                              .findById(widget.usageId)
                                              .usageDate),
                                      widget.usageId,
                                      _editedUsageDetails);
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
