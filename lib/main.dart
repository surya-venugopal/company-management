import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:indian/constants/colors.dart';
import 'package:indian/providers/company.dart';
import 'package:indian/providers/key_words.dart';
import 'package:indian/providers/usage.dart';
import 'package:indian/screens/dayBook/daybook_search.dart';
import 'package:indian/screens/home/attendence.dart';
import 'package:indian/screens/workers_screen.dart';
import 'screens/maps/add_client.dart';
import 'providers/production.dart';
import 'providers/purchase.dart';
import 'providers/sales.dart';
import 'screens/dayBook/daybook_screen.dart';
import 'screens/main_screen.dart';
import 'screens/splash_screen.dart';
import 'package:provider/provider.dart';

import 'providers/app_users.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static const company = "CR";

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _isInit = true;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      await Firebase.initializeApp();
    }

    setState(() {
      _isInit = false;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: _isInit ? null : AppUser(),
        ),
        ChangeNotifierProvider.value(
          value: _isInit ? null : Production(),
        ),
        ChangeNotifierProvider.value(
          value: _isInit ? null : Sales(),
        ),
        ChangeNotifierProvider.value(
          value: _isInit ? null : Purchase(),
        ),
        ChangeNotifierProvider.value(
          value: _isInit ? null : Usage(),
        ),
        ChangeNotifierProvider.value(
          value: _isInit ? null : KeyWords(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primaryColor: MyColors().colorPrimary,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: _isInit ? SplashPage() : SplashScreeen(),
        routes: {
          MainScreen.routeName: (ctx) => MainScreen(),
          AddClient.routeName: (ctx) => AddClient(),
          DayBookSearch.routeName: (ctx) => DayBookSearch(),
          WorkersScreen.routeName: (ctx) => WorkersScreen(),
          AttendanceHistory.routeName: (ctx) => AttendanceHistory()
        },
      ),
    );
  }
}
