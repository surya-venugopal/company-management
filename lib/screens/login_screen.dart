import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:indian/providers/app_users.dart';
import 'package:indian/screens/main_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Login",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 36,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[400])),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[300])),
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: "Name"),
                controller: _nameController,
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[400])),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[300])),
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: "Mobile Number"),
                controller: _phoneController,
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                width: double.infinity,
                child: FlatButton(
                  child: Text("LOGIN"),
                  textColor: Colors.white,
                  padding: EdgeInsets.all(16),
                  onPressed: () {
                    final phone = "+91" + _phoneController.text.trim();
                    final name = _nameController.text.trim();
                    AuthProvider().loginWithPhone(name, phone, context);
                  },
                  color: Theme.of(context).primaryColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AuthProvider {
  // Future<void> logOut() async {
  //   try {
  //     await _auth.signOut();
  //   } catch (e) {
  //     print("error logging out");
  //   }
  // }
  //
  // Future<bool> loginWithGoogle() async {
  //   try {
  //     GoogleSignIn googleSignIn = GoogleSignIn();
  //     GoogleSignInAccount account = await googleSignIn.signIn();
  //     if (account == null) return false;
  //     UserCredential res =
  //         await _auth.signInWithCredential(GoogleAuthProvider.credential(
  //       idToken: (await account.authentication).idToken,
  //       accessToken: (await account.authentication).accessToken,
  //     ));
  //     if (res.user == null) return false;
  //     return true;
  //   } catch (e) {
  //     print(e.message);
  //     print("Error logging with google");
  //     return false;
  //   }
  // }

  Future<void> loginWithPhone(
      String name, String phone, BuildContext context) async {
    final _codeController = TextEditingController();
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          Navigator.of(context).pop();

          UserCredential result = await _auth.signInWithCredential(credential);

          User user = result.user;

          if (user != null) {
            Provider.of<AppUser>(context, listen: false).setId(user.uid);
            await Provider.of<AppUser>(context, listen: false)
                .setUser(name, phone,1)
                .then((value) => Navigator.pushReplacementNamed(
                    context, MainScreen.routeName));
          } else {
            print("Error");
          }
        },
        verificationFailed: (FirebaseAuthException exception) {
          print(exception);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Text("Enter OTP"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: _codeController,
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Confirm"),
                      textColor: Colors.white,
                      color: Colors.blue,
                      onPressed: () async {
                        final code = _codeController.text.trim();
                        AuthCredential credential =
                            PhoneAuthProvider.credential(
                                verificationId: verificationId, smsCode: code);

                        UserCredential result =
                            await _auth.signInWithCredential(credential);

                        User user = result.user;

                        if (user != null) {
                          Provider.of<AppUser>(context, listen: false)
                              .setId(user.uid);
                          await Provider.of<AppUser>(context, listen: false)
                              .setUser(name, phone,1)
                              .then((value) => Navigator.pushReplacementNamed(
                                  context, MainScreen.routeName));
                        } else {
                          print("Error");
                        }
                      },
                    )
                  ],
                );
              });
        },
        codeAutoRetrievalTimeout: (id) => {});
  }
}
