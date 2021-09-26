import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:letschat_app/helper/authenticate.dart';
import 'package:letschat_app/helper/constants.dart';
import 'package:letschat_app/helper/enum.dart';
import 'package:letschat_app/helper/helperfunction.dart';
import 'package:letschat_app/services/auth.dart';
import 'package:letschat_app/services/database.dart';
import 'package:letschat_app/views/conversationscreen.dart';
import 'package:letschat_app/views/search.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> with WidgetsBindingObserver {
  AuthMethods authMethods = new AuthMethods();
  DataBaseMethods dbMethods = new DataBaseMethods();
  QuerySnapshot? snapUserInfo;
  Stream? chatRoomsStream;

  @override
  void initState() {
    getUserInfo();
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        (Constants.myName != null)
            ? authMethods.setUserState(
                userId: Constants.myName, userState: UserState.Online)
            : print('resumed state');
        break;
      case AppLifecycleState.inactive:
        (Constants.myName != null)
            ? authMethods.setUserState(
                userId: Constants.myName, userState: UserState.Offline)
            : print('inactive state');
        break;
      case AppLifecycleState.paused:
        (Constants.myName != null)
            ? authMethods.setUserState(
                userId: Constants.myName, userState: UserState.Waiting)
            : print('paused state');
        break;
      case AppLifecycleState.detached:
        (Constants.myName != null)
            ? authMethods.setUserState(
                userId: Constants.myName, userState: UserState.Offline)
            : print('detached state');
        break;
    }
  }

  getUserInfo() async {
    Constants.myName = await HelperFunction.getuserNameSharedPreference();
    dbMethods.getChatRooms(Constants.myName!).then((val) {
      setState(() {
        chatRoomsStream = val;
      });
    });
    setState(() {
      updateStats(Constants.myName!);
    });
  }

  updateStats(String myName) {
    authMethods.setUserState(userId: myName, userState: UserState.Online);
  }

  Widget chatRoomList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        return snapshot.hasData
            ? (snapshot.data.docs.length < 1)
                ? Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group_add,
                            color: Color.fromRGBO(33, 150, 243, 1.0),
                            size: 100,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'NO CHATS YET',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Search other users and lets chat...',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      String chatId =
                          snapshot.data.docs[index]['chatId'].toString();
                      String usern = snapshot.data.docs[index]['chatWith'];
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ConversationScreen(chatId, usern)));
                          },
                          child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('ChatRoom')
                                      .doc(chatId)
                                      .collection(chatId)
                                      .orderBy('time', descending: true)
                                      .snapshots(),
                                  builder: (context, msgSnapshot) {
                                    var unReadMSG;
                                    if (msgSnapshot.hasData) {
                                      unReadMSG = 0;
                                      for (var j = 0;
                                          j < msgSnapshot.data!.docs.length;
                                          j++) {
                                        if (msgSnapshot.data!.docs[j]
                                                    .get('sendBy') ==
                                                usern &&
                                            msgSnapshot.data!.docs[j]
                                                    .get('isRead') ==
                                                false) {
                                          unReadMSG += 1;
                                        }
                                      }
                                    }
                                    return ListTile(
                                        leading: CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.blue,
                                          child: Text(
                                              '${usern.substring(0, 1).toUpperCase()}',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 25)),
                                        ),
                                        title: Text(
                                          usern.toUpperCase(),
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        subtitle:
                                            (msgSnapshot.hasData && msgSnapshot.data!.docs.length > 0)
                                                ? reqwidget(
                                                    msgSnapshot.data!.docs[0]
                                                        .get('sendBy'),
                                                    msgSnapshot.data!.docs[0]
                                                        .get('message'),
                                                    msgSnapshot.data!.docs[0]
                                                        .get('isRead'),
                                                    usern,
                                                    unReadMSG)
                                                : Text(''),
                                        trailing: (msgSnapshot.hasData &&
                                                msgSnapshot.data!.docs.length >
                                                    0)
                                            ? (msgSnapshot.data!.docs[0].get('sendBy') ==
                                                        usern &&
                                                    msgSnapshot.data!.docs[0]
                                                            .get('isRead') ==
                                                        false)
                                                ? CircleAvatar(
                                                    backgroundColor: Colors.red,
                                                    radius: 10,
                                                    child: Text((unReadMSG != null) ? ((unReadMSG < 100) ? '$unReadMSG' : '99+') : '',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.bold)))
                                                : Text(
                                                    timeFormatter(msgSnapshot
                                                        .data!.docs[0]
                                                        .get('time')),
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  )
                                            : Text(''));
                                  })));
                    },
                  )
            : Container();
      },
    );
  }

  Widget reqwidget(
      String sendBy, String message, bool isRead, String usern, var unReadMSG) {
    Widget x;
    if (sendBy == usern && isRead == false) {
      x = Text(
          (unReadMSG == 1)
              ? '$unReadMSG New Message'
              : '$unReadMSG New Messages',
          style: TextStyle(fontWeight: FontWeight.bold));
    } else {
      if (sendBy == Constants.myName) {
        if (isRead == false) {
          x = Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 15,
                color: Colors.blue,
              ),
              SizedBox(
                width: 5,
              ),
              Text((message.length > 25)
                  ? '${(message).substring(0, 25)}...'
                  : '$message')
            ],
          );
        } else {
          x = Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 15,
                color: Colors.blue,
              ),
              SizedBox(
                width: 5,
              ),
              Text((message.length > 25)
                  ? '${(message).substring(0, 25)}...'
                  : '$message')
            ],
          );
        }
      } else {
        x = Text((message.length > 25)
            ? '${(message).substring(0, 25)}...'
            : '$message');
      }
    }
    return x;
  }

  String timeFormatter(var epochstmp) {
    var x = DateTime.fromMicrosecondsSinceEpoch(epochstmp);
    var y = DateTime.fromMicrosecondsSinceEpoch(
        DateTime.now().microsecondsSinceEpoch);
    var z = y.difference(x);
    var a = '';
    if (z.inDays == 0) {
      a = DateFormat.jm().format(x);
    } else if (z.inDays == 1) {
      a = 'Yesterday';
    } else if (z.inDays >= 2) {
      a = DateFormat('dd/MM/yyyy').format(x);
    }
    return a;
  }

  getUserMailandUpdToken() async {
    String? email = await HelperFunction.getuserEmailSharedPreference();
    dbMethods.getUserbyEmail(email!).then((val) {
      snapUserInfo = val;
      dbMethods.updateUserToken(snapUserInfo!.docs[0], '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo.png', height: 30),
        elevation: 0.0,
        actions: [
          GestureDetector(
            onTap: () {
              authMethods.signOut();
              authMethods.setUserState(
                  userId: Constants.myName, userState: UserState.Offline);
              getUserMailandUpdToken();
              HelperFunction.saveuserLoggedInSharedPreference(false);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => Authenticate()));
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.logout)),
          )
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 24),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Text('MY PROFILE',
                      style: TextStyle(
                          color: Colors.lightBlue[50],
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ),
                ListTile(
                  leading: CircleAvatar(
                    child: Text(
                        (Constants.myName != null)
                            ? '${Constants.myName!.substring(0, 1).toUpperCase()}'
                            : '',
                        style: TextStyle(color: Colors.blue, fontSize: 25)),
                    radius: 25,
                    backgroundColor: Colors.white,
                  ),
                  title: Text(
                      (Constants.myName != null)
                          ? Constants.myName!.toUpperCase()
                          : 'LOADING USER...',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      (Constants.myName != null) ? 'A Let\'s Chat User' : '',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 24),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Text('MY CHATS',
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                  ),
                  chatRoomList(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SearchScreen()));
        },
      ),
    );
  }
}
