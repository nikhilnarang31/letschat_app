import 'package:flutter/material.dart';
import 'package:letschat_app/helper/constants.dart';
import 'package:letschat_app/helper/enum.dart';
import 'package:letschat_app/helper/helperfunction.dart';
import 'package:letschat_app/services/auth.dart';
import 'package:letschat_app/services/database.dart';
import 'package:letschat_app/views/allchatscreen.dart';
import 'package:letschat_app/widgets/widgets.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fzregex/fzregex.dart';
import 'package:fzregex/utils/pattern.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUp extends StatefulWidget {
  final Function toggle;
  SignUp(this.toggle);
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isLoading = false;
  AuthMethods authMethods = new AuthMethods();
  DataBaseMethods dbMethods = new DataBaseMethods();
  final formKey = GlobalKey<FormState>();
  TextEditingController usernameText = new TextEditingController();
  TextEditingController emailText = new TextEditingController();
  TextEditingController passwordText = new TextEditingController();

  setSearchParam(String username) {
    List<String> userSearchList = [];
    String temp = "";
    for (int i = 0; i < username.length; i++) {
      temp = temp + username[i];
      userSearchList.add(temp);
    }
    return userSearchList;
  }

  signMeUP() {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      authMethods
          .signUpWithEmail(emailText.text, passwordText.text)
          .then((value) {
        print('${value.userId}');
        Map<String, dynamic> userInfoMap = {
          "name": usernameText.text,
          "email": emailText.text,
          "createdAt": DateTime.now().microsecondsSinceEpoch.toString(),
          "FCMToken": Constants.fcmtok,
          "namesearch": setSearchParam(usernameText.text),
          "state": 0
        };
        HelperFunction.saveUserNameSharedPreference(usernameText.text);
        HelperFunction.saveUserEmailSharedPreference(emailText.text);

        dbMethods.uploadUserInfo(usernameText.text, userInfoMap);
        authMethods.setUserState(
            userId: userInfoMap['name'], userState: UserState.Online);
        HelperFunction.saveuserLoggedInSharedPreference(true);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ChatRoom()));
      }).catchError((onError) {
        Fluttertoast.showToast(
          msg: "Sign Up Failed !",
          fontSize: 16,
          textColor: Colors.white,
          backgroundColor: Color.fromRGBO(33, 150, 243, 1.0),
        );
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
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
                                '   SIGN UP FOR NEW ACCOUNT',
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
                                            minHeight: constraints.maxHeight),
                                        child: IntrinsicHeight(
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                              Text('SIGNING UP...',
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
                            child:
                                LayoutBuilder(builder: (context, constraints) {
                              return SingleChildScrollView(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight),
                                  child: IntrinsicHeight(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                                  return val!.isEmpty ||
                                                          val.length < 4
                                                      ? 'Username Not Provided or less than 4 Characters'
                                                      : null;
                                                },
                                                controller: usernameText,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16),
                                                decoration: textFieldInpDecor(
                                                    'Username',
                                                    Icon(Icons.account_box,
                                                        color:
                                                            Colors.grey[600]))),
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
                                                decoration: textFieldInpDecor(
                                                    'E-mail',
                                                    Icon(Icons.email,
                                                        color:
                                                            Colors.grey[600]))),
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
                                                decoration: textFieldInpDecor(
                                                    'Password',
                                                    Icon(Icons.lock,
                                                        color:
                                                            Colors.grey[600]))),
                                          ],
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
                                          signMeUP();
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: Color.fromRGBO(
                                                33, 150, 243, 1.0),
                                          ),
                                          child: Text('Sign Up',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17)),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Already have an Account ? ',
                                            style: TextStyle(fontSize: 17),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              widget.toggle();
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8),
                                              child: Text(
                                                'Sign In Now !',
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    decoration: TextDecoration
                                                        .underline),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  )),
                                ),
                              );
                            }),
                          ),
                        ),
                ])));
  }
}
