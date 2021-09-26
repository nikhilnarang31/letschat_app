import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:letschat_app/helper/enum.dart';
import 'package:letschat_app/models/user.dart';
import 'package:letschat_app/views/presenceutils.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final CollectionReference _usersCollection =
      firestore.collection('users');

  Users? _userfromFirebaseUser(User user) {
    return Users(userId: user.uid);
  }

  Future signInWithEmail(String email, String password) async {
    UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    User firebaseUser = result.user!;
    return _userfromFirebaseUser(firebaseUser);
  }

  Future signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User firebaseUser = result.user!;
      return _userfromFirebaseUser(firebaseUser);
    } catch (e) {
      print(e.toString());
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  void setUserState(
      {@required String? userId, @required UserState? userState}) {
    var stateNum = Utils.stateToNum(userState!);
    _usersCollection.doc(userId).update({'state': stateNum});
  }

  Stream<DocumentSnapshot> getUserStream({@required String? uid}) =>
      _usersCollection.doc(uid).snapshots();
}
