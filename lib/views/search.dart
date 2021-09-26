import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:letschat_app/helper/constants.dart';
import 'package:letschat_app/services/database.dart';
import 'package:letschat_app/views/conversationscreen.dart';
import 'package:letschat_app/widgets/widgets.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchText = new TextEditingController();
  DataBaseMethods dbMethods = new DataBaseMethods();
  QuerySnapshot? searchSnap;
  QuerySnapshot? chatSnap;
  bool isSearching = false;

  initiateSearch() {
    dbMethods.getUser(searchText.text).then((val) {
      setState(() {
        searchSnap = val;
        isSearching = false;
      });
    });
    dbMethods.getChatId(Constants.myName!).then((val) {
      setState(() {
        chatSnap = val;
      });
    });
  }

  getChatRoomId(String a, String b) {
    String? x;
    for (var k = 0; k < chatSnap!.docs.length; k++) {
      if (chatSnap!.docs[k].get('chatroomid').toString().contains(a)) {
        x = chatSnap!.docs[k].get('chatroomid');
      }
    }
    print(x);
    print("$a\_$b");
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else if (x == "$a\_$b" || x == "$b\_$a") {
      return x;
    } else {
      return "$a\_$b";
    }
  }

  /// create chatroom, send user to conversation screen, pushreplacement
  createChatRoomandStartConv({String? userName}) {
    if (userName != Constants.myName) {
      String chatRoomId = getChatRoomId(userName!, Constants.myName!);
      List<String> users = [userName, Constants.myName!];
      Map<String, dynamic> userChatListInfoFrom = {
        "chatId": chatRoomId,
        "chatWith": userName,
        "timeStamp": DateTime.now().microsecondsSinceEpoch,
      };
      Map<String, dynamic> userChatListInfoTo = {
        "chatId": chatRoomId,
        "chatWith": Constants.myName,
        "timeStamp": DateTime.now().microsecondsSinceEpoch,
      };
      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatroomid": chatRoomId
      };
      dbMethods.createChatRoom(chatRoomId, chatRoomMap, userChatListInfoFrom,
          userChatListInfoTo, userName);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationScreen(chatRoomId, userName)));
    } else {
      Fluttertoast.showToast(
        msg: "Can't message yourself",
        textColor: Colors.white,
        fontSize: 16,
        backgroundColor: Color.fromRGBO(33, 150, 243, 1.0),
      );
      print("Can't message yourself");
    }
  }

  Widget searchTile({String? userName, String? userEmail}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName!.toUpperCase(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              SizedBox(
                height: 8,
              ),
              Text(userEmail!, style: TextStyle(fontSize: 11)),
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              createChatRoomandStartConv(userName: userName);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text('Message',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  Widget searchList() {
    return searchSnap != null
        ? (isSearching)
            ? Center(child: CircularProgressIndicator())
            : (searchSnap!.docs.length >= 1)
                ? ListView.builder(
                    itemCount: searchSnap!.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return searchTile(
                          userName: searchSnap!.docs[index].get('name'),
                          userEmail: searchSnap!.docs[index].get('email'));
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          color: Color.fromRGBO(33, 150, 243, 1.0),
                          size: 100,
                        ),
                        SizedBox(height: 10),
                        Text(
                          (searchText.text != '')
                              ? 'NO USERS FOUND'
                              : 'SEARCH USERS',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Container(
                            width: 3 * MediaQuery.of(context).size.width / 4,
                            child: Text(
                              (searchText.text != '')
                                  ? 'Try searching some other names and lets chat with them'
                                  : 'Search other users and lets chat with them',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
        : Center(
            child: (isSearching)
                ? CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        color: Color.fromRGBO(33, 150, 243, 1.0),
                        size: 100,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'SEARCH USERS',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Search other users and lets chat with them',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          );
  }

  @override
  Widget build(BuildContext context) {
    var sz = MediaQuery.of(context).size;
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Column(
          children: [
            Container(
              color: Colors.lightBlue[70],
              padding: EdgeInsets.symmetric(vertical: 15),
              child: ListTile(
                  leading: Container(
                    constraints: BoxConstraints(maxWidth: (7 * sz.width) / 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 5),
                      child: TextField(
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          setState(() {
                            isSearching = true;
                          });
                          initiateSearch();
                        },
                        controller: searchText,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                            hintText: "Search username...",
                            hintStyle: TextStyle(color: Colors.black45),
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                  trailing: GestureDetector(
                    onTap: () {
                      setState(() {
                        isSearching = true;
                      });
                      initiateSearch();
                    },
                    child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(40),
                            gradient: LinearGradient(colors: [
                              Colors.lightBlueAccent,
                              Color.fromRGBO(33, 150, 243, 1.0),
                            ])),
                        padding: EdgeInsets.all(14),
                        child: Image.asset(
                          'assets/images/search_white.png',
                        )),
                  )),
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
                  child: searchList()),
            ),
          ],
        ),
      ),
    );
  }
}
