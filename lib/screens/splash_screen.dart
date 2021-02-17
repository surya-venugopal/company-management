import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:indian/providers/app_users.dart';
import 'package:indian/screens/main_screen.dart';
import 'package:indian/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:indian/main.dart';

class SplashScreeen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, AsyncSnapshot<User> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashPage();
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return LoginScreen();
        } else if (snapshot.data.phoneNumber != null) {
          var _userProvider = Provider.of<AppUser>(context, listen: false);
          _userProvider.setId(snapshot.data.uid);
        }
        return MainScreen();
      },
    );
  }
}

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          MyApp.company,
          style: TextStyle(fontSize: 25),
        ),
      ),
    );
  }
}
