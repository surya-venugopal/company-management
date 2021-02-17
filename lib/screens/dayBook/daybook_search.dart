import 'package:flutter/material.dart';
import 'package:indian/screens/dayBook/dayBookItem.dart';

class DayBookSearch extends StatelessWidget {
  static const routeName = "/daybook-search";

  @override
  Widget build(BuildContext context) {
    var date = ModalRoute.of(context).settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: Text("DayBook"),
      ),
      body: SingleChildScrollView(child: DayBookItem(date)),
    );
  }
}
