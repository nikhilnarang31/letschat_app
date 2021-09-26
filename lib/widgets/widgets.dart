import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:letschat_app/helper/enum.dart';
import 'package:letschat_app/services/auth.dart';
import 'package:letschat_app/views/presenceutils.dart';

PreferredSizeWidget? appBarMain(BuildContext context) {
  return AppBar(
    title: Image.asset('assets/images/logo.png', height: 30),
    elevation: 0.0,
    titleSpacing: 0.0,
  );
}

Widget presenceTeller(String uid, BuildContext context) {
  AuthMethods authMethods = new AuthMethods();
  getText(int state) {
    switch (Utils.numToState(state)) {
      case UserState.Offline:
        return 'Offline';
      case UserState.Online:
        return 'Online';
      default:
        return 'Waiting';
    }
  }

  getColor(int state) {
    switch (Utils.numToState(state)) {
      case UserState.Offline:
        return Colors.redAccent[400];
      case UserState.Online:
        return Colors.greenAccent[400];
      default:
        return Colors.yellow;
    }
  }

  return StreamBuilder<DocumentSnapshot>(
    stream: authMethods.getUserStream(
      uid: uid,
    ),
    builder: (context, snapshot) {
      var user;
      if (snapshot.hasData && snapshot.data?.data != null) {
        user = snapshot.data!.data();
      }

      return Row(
        children: [
          CircleAvatar(
            radius: 6,
            backgroundColor:
                user != null ? getColor(user['state']) : Colors.transparent,
            child: Text(''),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            user != null ? getText(user['state']) : '',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
          ),
        ],
      );
    },
  );
}

InputDecoration textFieldInpDecor(String hintTxt, Icon ico) {
  return InputDecoration(
      filled: true,
      fillColor: Color(0xFFE7EDEB),
      hintText: hintTxt,
      prefixIcon: ico,
      hintStyle: TextStyle(color: Colors.black54),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none));
}
