// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:letschat_app/helper/constants.dart';
import 'package:letschat_app/services/database.dart';
import 'package:letschat_app/widgets/widgets.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:intl/intl.dart';

class ConversationScreen extends StatefulWidget {
  final String chatRoomId;
  final String chatUser;
  ConversationScreen(this.chatRoomId, this.chatUser);
  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  TextEditingController msgController = new TextEditingController();
  DataBaseMethods dbMethods = new DataBaseMethods();
  GroupedItemScrollController scroller = new GroupedItemScrollController();
  FocusNode msgFocus = new FocusNode();
  Stream? chatMsgsStream;
  int? last;
  Widget chatMessagesList() {
    return StreamBuilder(
      stream: chatMsgsStream,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        return snapshot.hasData
            ? (snapshot.data.docs.length < 1)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mark_chat_unread_outlined,
                          color: Color.fromRGBO(33, 150, 243, 1.0),
                          size: 100,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'NO MESSAGES YET',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Start typing something and lets chat with',
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${widget.chatUser.toUpperCase()}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  )
                : StickyGroupedListView(
                    elements: snapshot.data.docs,
                    order: (snapshot.data.docs.length > 8)
                        ? StickyGroupedListOrder.DESC
                        : StickyGroupedListOrder.ASC,
                    reverse: (snapshot.data.docs.length > 8) ? true : false,
                    // itemScrollController: scroller,
                    floatingHeader: true,
                    stickyHeaderBackgroundColor: Colors.transparent,
                    groupBy: (dynamic element) => DateFormat('yMd').format(
                        DateTime.fromMicrosecondsSinceEpoch(element['time'])),
                    groupSeparatorBuilder: (dynamic element) => Container(
                      height: 30,
                      alignment: Alignment.center,
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(190, 226, 255, 1.0),
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            '${timeFormatter(element['time']).toUpperCase()}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    itemBuilder: (_, dynamic element) {
                      last = snapshot.data.docs.length;
                      if (element["sendBy"] != Constants.myName &&
                          element["isRead"] == false) {
                        dbMethods.readByUser(element);
                      }
                      return MsgTile(
                          element["message"],
                          element["sendBy"] == Constants.myName,
                          element["isRead"],
                          element['time']);
                    },
                  )
            // : ListView.builder(
            //     reverse: true,
            //     itemCount: snapshot.data.documents.length,
            //     itemBuilder: (context, index) {
            //       if (snapshot.data.documents[index].data["sendBy"] !=
            //               Constants.myName &&
            //           snapshot.data.documents[index].data["isRead"] ==
            //               false) {
            //         dbMethods.readByUser(snapshot.data.documents[index]);
            //       }
            //       return MsgTile(
            //           snapshot.data.documents[index].data["message"],
            //           snapshot.data.documents[index].data["sendBy"] ==
            //               Constants.myName,
            //           snapshot.data.documents[index].data["isRead"]);
            //     },
            //   )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mark_chat_unread_outlined,
                      color: Color.fromRGBO(33, 150, 243, 1.0),
                      size: 100,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'NO MESSAGES YET',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Start typing something and lets chat with',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${widget.chatUser.toUpperCase()}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              );
      },
    );
  }

  sendMsg() {
    if (msgController.text.isNotEmpty) {
      var tmstmp = DateTime.now().microsecondsSinceEpoch;
      Map<String, dynamic> msgMap = {
        'message': msgController.text,
        'sendBy': Constants.myName,
        'isRead': false,
        'time': tmstmp
      };
      dbMethods.addConvMsgs(widget.chatRoomId, msgMap, tmstmp.toString());
      msgController.text = '';
    }
  }

  @override
  void initState() {
    //msgFocus.addListener(onChange);
    dbMethods.getConvMsgs(widget.chatRoomId).then((val) {
      setState(() {
        chatMsgsStream = val;
      });
    });
    super.initState();
  }

  void onChange() {
    scroller.jumpTo(index: last!);
  }

  String timeFormatter(var epochstmp) {
    var b = DateTime.fromMicrosecondsSinceEpoch(epochstmp);
    var x = DateTime(
        int.parse(DateFormat('y').format(b)),
        int.parse(DateFormat('M').format(b)),
        int.parse(DateFormat('d').format(b)));
    var c = DateTime.fromMicrosecondsSinceEpoch(
        DateTime.now().microsecondsSinceEpoch);
    var y = DateTime(
        int.parse(DateFormat('y').format(c)),
        int.parse(DateFormat('M').format(c)),
        int.parse(DateFormat('d').format(c)));
    var z = y.difference(x);
    var a = '';
    if (z.inDays == 0) {
      a = 'Today';
    } else if (z.inDays == 1) {
      a = 'Yesterday';
    } else if (z.inDays >= 2) {
      a = DateFormat('d MMM y').format(b);
    }
    return a;
  }

  @override
  Widget build(BuildContext context) {
    var sz = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                color: Color.fromRGBO(33, 150, 243, 1.0),
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: ListTile(
                    leading: IconButton(
                        color: Colors.white,
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    title: Text(
                      widget.chatUser.toUpperCase(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                    subtitle: presenceTeller(widget.chatUser, context),
                    trailing: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Text(
                          '${widget.chatUser.substring(0, 1).toUpperCase()}',
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 25)),
                    ),
                  ),
                )),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Column(
                  children: [
                    Flexible(child: chatMessagesList()),
                    Container(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        color: Colors.lightBlue[70],
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 5),
                              constraints:
                                  BoxConstraints(maxWidth: (3 * sz.width) / 4),
                              decoration: BoxDecoration(
                                // border: Border.all(color: Colors.black87, width: 2.0),
                                borderRadius: BorderRadius.circular(30.0),
                                color: Color.fromRGBO(158, 158, 158, 0.35),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 5),
                                child: TextField(
                                  textInputAction: TextInputAction.send,
                                  onEditingComplete: () {
                                    if (msgController.text.isEmpty) return;
                                    sendMsg();
                                  },
                                  controller: msgController,
                                  focusNode: msgFocus,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                      hintText: "Message...",
                                      hintStyle:
                                          TextStyle(color: Colors.black45),
                                      border: InputBorder.none),
                                ),
                              ),
                            ),
                            // GestureDetector(
                            //   onTap: () {
                            //     sendMsg();
                            //   },
                            //   child: Container(
                            //       height: 40,
                            //       width: 40,
                            //       decoration: BoxDecoration(
                            //           borderRadius: BorderRadius.circular(40),
                            //           gradient: LinearGradient(colors: [
                            //             Colors.lightBlueAccent,
                            //             Color.fromRGBO(33, 150, 243, 1.0),
                            //           ])),
                            //       padding: EdgeInsets.all(12),
                            //       child: Image.asset('assets/images/send.png')),
                            // )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: () {
          sendMsg();
        },
      ),
    );
  }
}

class MsgTile extends StatelessWidget {
  final String message;
  final bool isSendByMe;
  final bool isRed;
  final time;
  MsgTile(this.message, this.isSendByMe, this.isRed, this.time);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(children: [
            Container(
              constraints: BoxConstraints(maxWidth: size.width * 0.8),
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                  borderRadius: isSendByMe
                      ? BorderRadius.only(
                          topLeft: Radius.circular(23),
                          topRight: Radius.circular(23),
                          bottomLeft: Radius.circular(23))
                      : BorderRadius.only(
                          topLeft: Radius.circular(23),
                          topRight: Radius.circular(23),
                          bottomRight: Radius.circular(23)),
                  color: isSendByMe
                      ? Color.fromRGBO(33, 150, 243, 1.0)
                      : Color.fromRGBO(190, 226, 255, 1.0)),
              child: Text(message,
                  // textAlign: TextAlign.center,
                  style: TextStyle(
                      color: isSendByMe ? Colors.white : Colors.black,
                      fontSize: 16)),
            ),
            Positioned(
              right: (isSendByMe) ? 12 : 22,
              // left: (isSendByMe) ? 0 : 12,
              bottom: 8,
              child: Text(
                  '${DateFormat.jm().format(DateTime.fromMicrosecondsSinceEpoch(time))}',
                  textAlign: isSendByMe ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    color: isSendByMe ? Colors.white70 : Colors.black54,
                    fontSize: 8,
                  )),
            )
          ]),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: isSendByMe
                ? isRed
                    ? Icon(
                        Icons.check_circle,
                        size: 15,
                        color: Colors.blue,
                      )
                    : Icon(Icons.check_circle_outline,
                        size: 15, color: Colors.blue)
                : Container(),
          )
        ],
      ),
    );
  }
}
