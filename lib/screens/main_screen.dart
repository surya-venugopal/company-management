import 'dart:io';

import 'package:flutter/material.dart';
import 'package:indian/constants/colors.dart';
import 'package:indian/main.dart';
import 'package:indian/providers/app_users.dart';
import 'package:indian/providers/company.dart';
import 'package:indian/providers/ratio.dart';
import 'package:indian/screens/daily_updates/daily_updates.dart';

import 'package:indian/screens/dayBook/daybook_search.dart';
import 'package:indian/screens/home/home_fragment.dart';
import 'package:indian/screens/workers_screen.dart';
import 'package:intl/intl.dart';
import 'dayBook/daybook_screen.dart';
import 'package:provider/provider.dart';

import 'maps/maps_mover.dart';
import 'maps/search.dart';

class MainScreen extends StatefulWidget {
  static const routeName = "/home";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isInit = true;
  bool _isLoading = true;
  int _selectedIndex = 0;
  bool _isNew = true;
  int _userType = 2;
  String company1 = "Company 1";
  String company2 = "Company 2";

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool isConnected = false;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          isConnected = true;
          await Provider.of<AppUser>(context, listen: false).getinfoFromDb;
          await Ratios.getRatio();
          _userType =
              Provider.of<AppUser>(context, listen: false).getUser.userType;
          if (_userType == 0) {
            Company.name = company1;
          } else if (Provider.of<AppUser>(context, listen: false)
                  .getUser
                  .userCompany ==
              1) {
            Company.name = company1;
          } else if (Provider.of<AppUser>(context, listen: false)
                  .getUser
                  .userCompany ==
              2) {
            Company.name = company2;
          }
          if (_userType == 2) {
            _isNew = true;
          } else {
            _isNew = false;
          }
        }
      } on SocketException catch (_) {
        isConnected = false;
      }
      setState(() {
        _isLoading = false;
        _isInit = false;
      });
    }

    super.didChangeDependencies();
  }

  var selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Company.name == null ? MyApp.company : Company.name),
        actions: [
          if (_selectedIndex == 1)
            IconButton(
                icon: Icon(Icons.date_range_rounded),
                onPressed: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1965),
                    lastDate: DateTime.now(),
                  ).then((value) {
                    if (value == null) return;
                    setState(() {
                      selectedDate = value;
                      Navigator.of(context).pushNamed(DayBookSearch.routeName,
                          arguments: DateFormat.yMMMMd().format(value));
                    });
                  });
                }),
          if (_selectedIndex != 1 && _userType == 0)
            IconButton(
                icon: Icon(Icons.person),
                onPressed: () {
                  Navigator.of(context).pushNamed(WorkersScreen.routeName);
                }),
          if (_selectedIndex == 3 && (_userType == 0 || _userType == 1))
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(context: context, delegate: Search());
                }),
        ],
      ),
      drawer: _userType != 0
          ? null
          : Drawer(
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      MyApp.company,
                      style: TextStyle(
                          fontSize: 20,
                          color: MyColors().colorPrimary,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      height: 50,
                      child: FlatButton(
                        onPressed: () {
                          setState(() {
                            Company.name = company1;
                            _selectedIndex = 0;
                            Navigator.of(context).pop();
                          });
                        },
                        child: Text(
                          company1,
                          style: TextStyle(fontSize: 24),
                        ),
                        color: MyColors().colorPrimary,
                        textColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 50,
                      child: FlatButton(
                        onPressed: () {
                          setState(() {
                            Company.name = company2;
                            _selectedIndex = 0;
                            Navigator.of(context).pop();
                          });
                        },
                        child: Text(
                          company2,
                          style: TextStyle(fontSize: 24),
                        ),
                        color: MyColors().colorPrimary,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : isConnected
                ? _isNew
                    ? Center(
                        child: Text("Please contact admin to gain access."),
                      )
                    : _selectedIndex == 0
                        ? HomeFragment()
                        : _selectedIndex == 1
                            ? _userType == 4
                                ? DailyUpdates()
                                : DayBookScreen()
                            : _selectedIndex == 2
                                ? _userType == 4
                                    ? MapsMover()
                                    : DailyUpdates()
                                : MapsMover()
                : Center(
                    child:
                        Text("Please connect to internet and restart the app."),
                  ),
      ),
      bottomNavigationBar: isConnected
          ? _isNew
              ? null
              : _userType == 3
                  ? null
                  : BottomNavigationBar(
                      fixedColor: MyColors().colorPrimary,
                      unselectedItemColor: Colors.black54,
                      type: BottomNavigationBarType.shifting,
                      currentIndex: _selectedIndex,
                      items: [
                        BottomNavigationBarItem(
                          label: "Home",
                          icon: Icon(Icons.home),
                        ),
                        if (_userType == 0 || _userType == 1)
                          BottomNavigationBarItem(
                            label: "DayBook",
                            icon: Icon(Icons.book),
                          ),
                        BottomNavigationBarItem(
                          label: "Updates",
                          icon: Icon(Icons.photo),
                        ),
                        BottomNavigationBarItem(
                          label: "Marketing",
                          icon: Icon(Icons.map_rounded),
                        ),
                      ],
                      onTap: _onItemTapped,
                    )
          : null,
    );
  }
}
