import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:letschat_app/helper/constants.dart';

class DataBaseMethods {
  getUser(String username) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('namesearch', arrayContains: username)
        .get();
  }

  getChatId(String username) async {
    return await FirebaseFirestore.instance
        .collection('ChatRoom')
        .where('users', arrayContains: username)
        .get();
  }

  getUserbyEmail(String useremail) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: useremail)
        .get();
  }

  uploadUserInfo(uName, userMap) {
    //after users we can also use .document().setData() if we don't autogenerate ids for documents and name them by ourselves
    FirebaseFirestore.instance.collection("users").doc(uName).set(userMap);
  }

  createChatRoom(
      String chatRoomId, chatRoomMap, userFrom, userTo, String otheruser) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(Constants.myName)
        .collection('chatlist')
        .doc(chatRoomId)
        .set(userFrom)
        .catchError((e) {
      print(e.toString());
    });
    FirebaseFirestore.instance
        .collection('users')
        .doc(otheruser)
        .collection('chatlist')
        .doc(chatRoomId)
        .set(userTo)
        .catchError((e) {
      print(e.toString());
    });
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .set(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  addConvMsgs(String chatRoomId, msgMap, String tstmp) {
    FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .collection(chatRoomId)
        .doc(tstmp)
        .set(msgMap)
        .catchError((e) => print(e.toString()));
  }

  getConvMsgs(String chatRoomId) async {
    return await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .collection(chatRoomId)
        .orderBy('time', descending: false)
        .snapshots();
  }

  getChatRooms(String userName) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userName)
        .collection('chatlist')
        .snapshots();
  }

  updateUserToken(userID, token) async {
    FirebaseFirestore.instance.runTransaction((transaction) async {
      await transaction.update(userID.reference, {'FCMToken': token});
    });
  }

  readByUser(sp) async {
    FirebaseFirestore.instance
        .runTransaction((Transaction myTransaction) async {
      await myTransaction.update(sp.reference, {'isRead': true});
    });
  }

  getUnReadChatRoom(String userName) async {
    return await FirebaseFirestore.instance
        .collection('ChatRoom')
        .where('user', isEqualTo: userName)
        .snapshots();
  }
}
