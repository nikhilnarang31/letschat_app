import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:letschat_app/helper/authenticate.dart';
import 'package:letschat_app/helper/constants.dart';
import 'package:letschat_app/helper/helperfunction.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:letschat_app/views/allchatscreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:letschat_app/views/conversationscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

GlobalKey<NavigatorState> navigatorkey = new GlobalKey();

final FlutterLocalNotificationsPlugin localnotif =
    new FlutterLocalNotificationsPlugin();

Future<void> backgroundmsg(RemoteMessage message) async {
  String pyld = "${message.data['chatRoomId']} ${message.data['chatWith']}";
  showNotification(message.data['title'], message.data['body'], pyld);
}

void showNotification(String title, String body, String pyload) async {
  await _demoNotification(title, body, pyload);
}

Future<void> _demoNotification(
    String title, String body, String payload) async {
  String initials = body.substring(2, 3);
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'LETS_CHAT_MESSAGES', 'MESSAGES', 'Message Notifications',
      icon: 'lets_chat',
      largeIcon: DrawableResourceAndroidBitmap(initials),
      color: Color.fromRGBO(33, 150, 243, 1.0),
      importance: Importance.max,
      playSound: true,
      priority: Priority.max);

  var iOSChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iOSChannelSpecifics);
  await localnotif.show(0, title, body, platformChannelSpecifics,
      payload: payload);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _msg = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin localnotif =
      new FlutterLocalNotificationsPlugin();
  bool? userIsLoggedIn;
  @override
  void initState() {
    _firebaseMsgListener();
    _msg.getToken().then((value) => Constants.fcmtok = value!);
    AndroidInitializationSettings initSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    IOSInitializationSettings initSettingsIOS = new IOSInitializationSettings();
    InitializationSettings initializationSettings = new InitializationSettings(
        android: initSettingsAndroid, iOS: initSettingsIOS);
    localnotif.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    getLoggedInState();
    super.initState();
  }

  void _firebaseMsgListener() {
    FirebaseMessaging.onBackgroundMessage(backgroundmsg);
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      String pyld = "${msg.data['chatRoomId']} ${msg.data['chatWith']}";
      showNotification(msg.data['title'], msg.data['body'], pyld);
      print("onMessage: $msg");
      print(msg.data['chatRoomId']);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
      print("onResume: $msg");
      print(msg.data['chatRoomId']);
      navigatorkey.currentState!.push(MaterialPageRoute(
          builder: (context) => ConversationScreen(
              msg.data['chatRoomId'], msg.data['chatWith'])));
      print(msg.data['chatWith']);
    });
    // _msg.initializeApp(
    //   onBackgroundMessage: backgroundmsg,
    //   onResume: (Map<String, dynamic> message) async {
    //     print("onResume: $message");
    //     print(message['data']['chatRoomId']);
    //     navigatorkey.currentState.push(MaterialPageRoute(
    //         builder: (context) => ConversationScreen(
    //             message['data']['chatRoomId'], message['data']['chatWith'])));
    //     print(message['data']['chatWith']);
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("onLaunch: $message");
    //     print(message['data']['chatRoomId']);
    //     // navigatorkey.currentState.push(MaterialPageRoute(
    //     //     builder: (context) => ConversationScreen(
    //     //         message['data']['chatRoomId'], message['data']['chatWith'])));
    //     print(message['data']['chatRoomId']);
    //   },
    //   onMessage: (Map<String, dynamic> message) async {
    //     String pyld =
    //         "${message['data']['chatRoomId']} ${message['data']['chatWith']}";
    //     showNotification(
    //         message['data']['title'], message['data']['body'], pyld);
    //     print("onMessage: $message");
    //     print(message['data']['chatRoomId']);
    //   },
    // );
  }

  Future onSelectNotification(String? payload) async {
    var dict = payload!.split(" ");
    if (navigatorkey.currentState!.canPop()) {
      navigatorkey.currentState!.pop();
    }
    navigatorkey.currentState!.push(MaterialPageRoute(
        builder: (context) => ConversationScreen(dict[0], dict[1])));
    print(dict[0]);
  }

  getLoggedInState() async {
    await HelperFunction.getuserLoggedInSharedPreference().then((value) {
      setState(() {
        userIsLoggedIn = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorkey,
        title: "Let's Chat",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Color.fromRGBO(33, 150, 243, 1.0),
          scaffoldBackgroundColor: Color.fromRGBO(33, 150, 243, 1.0),
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: userIsLoggedIn != null
            ? userIsLoggedIn!
                ? ChatRoom()
                : Authenticate()
            : Container(
                child: Center(
                  child: Authenticate(),
                ),
              ));
  }
}
