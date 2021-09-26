import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fzregex/fzregex.dart';
import 'package:fzregex/utils/pattern.dart';
import 'package:flutter/material.dart';
import 'package:letschat_app/helper/constants.dart';
import 'package:letschat_app/helper/enum.dart';
import 'package:letschat_app/helper/helperfunction.dart';
import 'package:letschat_app/services/auth.dart';
import 'package:letschat_app/services/database.dart';
import 'package:letschat_app/widgets/widgets.dart';

import 'allchatscreen.dart';

class SignIn extends StatefulWidget {
  final Function toggle;
  SignIn(this.toggle);
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final formKey = GlobalKey<FormState>();
  final form1Key = GlobalKey<FormState>();
  AuthMethods authMethods = new AuthMethods();
  DataBaseMethods dbMethods = new DataBaseMethods();
  TextEditingController emailText = new TextEditingController();
  TextEditingController passwordText = new TextEditingController();
  String? checkFCMt;

  bool isLoading = false;
  bool isForgot = false;
  bool isForgotLoading = false;
  QuerySnapshot? snapUserInfo;

  signIn() {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      authMethods
          .signInWithEmail(emailText.text, passwordText.text)
          .then((value) {
        dbMethods.getUserbyEmail(emailText.text).then((val) {
          snapUserInfo = val;
          if (snapUserInfo!.docs.isNotEmpty) {
            HelperFunction.saveUserNameSharedPreference(
                snapUserInfo!.docs[0].get('name'));
            checkFCMt = snapUserInfo!.docs[0].get('FCMToken');
            if (checkFCMt != Constants.fcmtok) {
              dbMethods.updateUserToken(
                  snapUserInfo!.docs[0], Constants.fcmtok);
            }
            authMethods.setUserState(
                userId: snapUserInfo!.docs[0].get('name'),
                userState: UserState.Online);
            //print(Constants.fcmtok);
            HelperFunction.saveuserLoggedInSharedPreference(true);
            HelperFunction.saveUserEmailSharedPreference(emailText.text);
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => ChatRoom()));
          } else {
            Fluttertoast.showToast(
              msg: "Sign In Failed !",
              textColor: Colors.white,
              fontSize: 16,
              backgroundColor: Color.fromRGBO(33, 150, 243, 1.0),
            );
            setState(() {
              isLoading = false;
            });
          }
        });
      }).catchError((onError) {
        print(onError.toString());
        Fluttertoast.showToast(
          msg: "Sign In Failed !",
          textColor: Colors.white,
          fontSize: 16,
          backgroundColor: Color.fromRGBO(33, 150, 243, 1.0),
        );
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  checkForgot() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.sendPasswordResetEmail(email: emailText.text).then((value) {
      Fluttertoast.showToast(
        msg: "Password Reset Email has been sent to registered e-mail !",
        textColor: Colors.white,
        fontSize: 16,
        backgroundColor: Color.fromRGBO(33, 150, 243, 1.0),
      );
      setState(() {
        isForgotLoading = false;
      });
    }).catchError((onError) {
      Fluttertoast.showToast(
        msg: "Password Reset Failed !\nInvalid E-mail Supplied",
        textColor: Colors.white,
        fontSize: 16,
        backgroundColor: Color.fromRGBO(33, 150, 243, 1.0),
      );
      setState(() {
        isForgotLoading = false;
      });
    });
  }

  void forgotPass() {
    if (form1Key.currentState!.validate()) {
      setState(() {
        isForgotLoading = true;
      });
      checkForgot();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: (isForgot)
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/images/logo.png',
                                    height: 46,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    '   FORGOT PASSWORD',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ]),
                          )),
                      (isForgotLoading)
                          ? Expanded(
                              flex: 5,
                              child: Container(
                                  alignment: Alignment(0, 0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(30),
                                          topRight: Radius.circular(30))),
                                  padding: EdgeInsets.symmetric(horizontal: 24),
                                  child: LayoutBuilder(
                                      builder: (context, constraints) {
                                    return SingleChildScrollView(
                                        child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                                minHeight:
                                                    constraints.maxHeight),
                                            child: IntrinsicHeight(
                                                child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CircularProgressIndicator(),
                                              ],
                                            ))));
                                  })),
                            )
                          : Expanded(
                              flex: 5,
                              child: Container(
                                alignment: Alignment(0, 1),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        topRight: Radius.circular(30))),
                                padding: EdgeInsets.symmetric(horizontal: 24),
                                child: LayoutBuilder(
                                    builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                          minHeight: constraints.maxHeight),
                                      child: IntrinsicHeight(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Form(
                                              key: form1Key,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'ENTER REGISTERED EMAIL BELOW',
                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                  SizedBox(
                                                    height: 39,
                                                  ),
                                                  TextFormField(
                                                      validator: (val) {
                                                        return EmailValidator
                                                                .validate(val!)
                                                            ? null
                                                            : "Enter Valid Email";
                                                      },
                                                      controller: emailText,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16),
                                                      decoration:
                                                          textFieldInpDecor(
                                                              'E-mail',
                                                              Icon(
                                                                  Icons.email,
                                                                  color: Colors
                                                                          .grey[
                                                                      600]))),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            SizedBox(
                                              height: 31,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                forgotPass();
                                              },
                                              child: Container(
                                                alignment: Alignment.center,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 20),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  color: Color.fromRGBO(
                                                      33, 150, 243, 1.0),
                                                ),
                                                child: Text('Reset Password',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 17)),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            SizedBox(
                                              height: 16,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  isForgot = false;
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 8),
                                                child: Text(
                                                  'Sign In Instead !',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 17,
                                                      decoration: TextDecoration
                                                          .underline),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                    ]))
            : Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/images/logo.png',
                                    height: 46,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    '   SIGN IN TO YOUR ACCOUNT',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ]),
                          )),
                      isLoading
                          ? Expanded(
                              flex: 5,
                              child: Container(
                                  alignment: Alignment(0, 0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(30),
                                          topRight: Radius.circular(30))),
                                  padding: EdgeInsets.symmetric(horizontal: 24),
                                  child: LayoutBuilder(
                                      builder: (context, constraints) {
                                    return SingleChildScrollView(
                                        child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                                minHeight:
                                                    constraints.maxHeight),
                                            child: IntrinsicHeight(
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                  Text('SIGNING IN...',
                                                      style: TextStyle(
                                                          color: Colors.blue,
                                                          fontSize: 30,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                  SizedBox(
                                                    height: 100,
                                                  ),
                                                  CircularProgressIndicator(),
                                                ]))));
                                  })),
                            )
                          : Expanded(
                              flex: 5,
                              child: Container(
                                alignment: Alignment(0, 1),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        topRight: Radius.circular(30))),
                                padding: EdgeInsets.symmetric(horizontal: 24),
                                child: LayoutBuilder(
                                    builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                          minHeight: constraints.maxHeight),
                                      child: IntrinsicHeight(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Form(
                                              key: formKey,
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  TextFormField(
                                                      validator: (val) {
                                                        return EmailValidator
                                                                .validate(val!)
                                                            ? null
                                                            : "Enter Valid Email";
                                                      },
                                                      controller: emailText,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16),
                                                      decoration:
                                                          textFieldInpDecor(
                                                              'E-mail',
                                                              Icon(
                                                                  Icons.email,
                                                                  color: Colors
                                                                          .grey[
                                                                      600]))),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  TextFormField(
                                                      validator: (val) {
                                                        return Fzregex.hasMatch(
                                                                val!,
                                                                FzPattern
                                                                    .passwordNormal1)
                                                            ? null
                                                            : "Must have at least: 1 letter & 1 digit & length >= 8";
                                                      },
                                                      controller: passwordText,
                                                      obscureText: true,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16),
                                                      decoration:
                                                          textFieldInpDecor(
                                                              'Password',
                                                              Icon(
                                                                Icons.lock,
                                                                color: Colors
                                                                    .grey[600],
                                                              ))),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  isForgot = true;
                                                });
                                              },
                                              child: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                            vertical: 8),
                                                    child: Text(
                                                        'Forgot Password ?',
                                                        style: TextStyle(
                                                            color: Colors.blue,
                                                            fontSize: 16,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline))),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 50,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                signIn();
                                              },
                                              child: Container(
                                                alignment: Alignment.center,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 20),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  color: Color.fromRGBO(
                                                      33, 150, 243, 1.0),
                                                ),
                                                child: Text('Sign In',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 17)),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            SizedBox(
                                              height: 16,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Don\'t have Account ? ',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 17),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    widget.toggle();
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 8),
                                                    child: Text(
                                                      'Register Now !',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 17,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                    ])));
  }
}
