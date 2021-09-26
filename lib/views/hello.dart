import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:letschat_app/helper/constants.dart';

AsyncSnapshot<QuerySnapshot>? msgSnapshot;
String usern = '';
var unReadMSG;

void main(List<String> msg) {
  if (msgSnapshot!.data!.docs[0].get('sendBy') == usern &&
      msgSnapshot!.data!.docs[0].get('isRead') == false) {
    Text(
        (unReadMSG == 1) ? '$unReadMSG New Message' : '$unReadMSG New Messages',
        style: TextStyle(fontWeight: FontWeight.bold));
  } else {
    if (msgSnapshot!.data!.docs[0].get('sendBy') == Constants.myName) {
      if (msgSnapshot!.data!.docs[0].get('isRead') == false) {
        Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 15,
              color: Colors.blue,
            ),
            Text((msgSnapshot!.data!.docs[0].get('message').length > 25)
                ? '${(msgSnapshot!.data!.docs[0].get('message')).substring(0, 25)}...'
                : '${(msgSnapshot!.data!.docs[0].get('message')).substring(0, 25)}...')
          ],
        );
      } else {
        Row(
          children: [
            Icon(
              Icons.check_circle,
              size: 15,
              color: Colors.blue,
            ),
            Text((msgSnapshot!.data!.docs[0].get('message').length > 25)
                ? '${(msgSnapshot!.data!.docs[0].get('message')).substring(0, 25)}...'
                : '${(msgSnapshot!.data!.docs[0].get('message')).substring(0, 25)}...')
          ],
        );
      }
    } else {
      Text((msgSnapshot!.data!.docs[0].get('message').length > 25)
          ? '${(msgSnapshot!.data!.docs[0].get('message')).substring(0, 25)}...'
          : '${(msgSnapshot!.data!.docs[0].get('message')).substring(0, 25)}...');
    }
  }
}
