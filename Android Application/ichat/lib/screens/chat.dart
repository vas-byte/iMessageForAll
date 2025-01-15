import 'package:ichat/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ichat/screens/messages.dart';
import 'loading.dart';
import 'package:flutter/cupertino.dart';
import 'dart:core';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'newconversation.dart';

class chatSc extends StatefulWidget {
  @override
  _chat createState() => _chat();
}

class _chat extends State<chatSc> {
  // Or do other work.

  @override
  void initState() {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.subscribeToTopic("msg");

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification!;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => mesgview(message.data["contact"],
                message.data["guid"], message.data["contact"])));
      }
    });

    super.initState();
  }

  String? disptext;
  List<String> dispName = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Converstations"),
          titleTextStyle: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
          backgroundColor: Colors.blue,
        ),
        body: StreamBuilder(
            stream: getChats(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done ||
                  snapshot.connectionState == ConnectionState.active) {
                return Scrollbar(
                    child: SingleChildScrollView(
                        physics: const ScrollPhysics(),
                        child: ListView.separated(

                            //fix scrolling issues
                            separatorBuilder: (context, index) {
                              return const Divider(
                                color: Colors.grey,
                              );
                            },
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (BuildContext context3, int index) {
                              if (encrypter!.decrypt64(
                                      snapshot.data.docs[index]["LastMSG"],
                                      iv: iv) ==
                                  "￼") {
                                disptext = "Sent a Photo";
                              } else {
                                disptext = encrypter!.decrypt64(
                                    snapshot.data.docs[index]["LastMSG"],
                                    iv: iv);
                              }

                              if (snapshot
                                      .data.docs[index]["FullName"].length ==
                                  1) {
                                if (snapshot.data.docs[index]["FullName"][0] !=
                                    "") {
                                  dispName.add(
                                      snapshot.data.docs[index]["FullName"][0]);
                                } else {
                                  dispName.add(snapshot
                                      .data.docs[index]["users"]
                                      .join(', '));
                                }
                              } else {
                                dispName.add(snapshot.data.docs[index]["users"]
                                    .join(', '));
                              }

                              return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: TextButton(
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('User')
                                            .doc('Chats')
                                            .collection("prevdata")
                                            .doc(snapshot.data.docs[index]
                                                ["guid"])
                                            .update({"isRead": true});
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => mesgview(
                                                    snapshot.data
                                                        .docs[index]["users"]
                                                        .join(', '),
                                                    snapshot.data.docs[index]
                                                        ["guid"],
                                                    snapshot.data.docs[index]
                                                                    ["FullName"]
                                                                [0] ==
                                                            ""
                                                        ? snapshot
                                                            .data
                                                            .docs[index]
                                                                ["users"]
                                                            .join(', ')
                                                        : snapshot
                                                            .data
                                                            .docs[index]
                                                                ["FullName"]
                                                            .join(', '))));
                                      },
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: snapshot
                                                  .data.docs[index]["isRead"]
                                              ? Colors.grey
                                              : Colors.blue,
                                          radius: 30.0,
                                          child: const Icon(
                                              CupertinoIcons.person_fill,
                                              color: Colors.white),
                                        ),
                                        title: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            snapshot.data.docs[index]
                                                        ["FullName"][0] ==
                                                    ""
                                                ? snapshot
                                                    .data.docs[index]["users"]
                                                    .join(', ')
                                                : snapshot.data
                                                    .docs[index]["FullName"]
                                                    .join(', '),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        subtitle: Text(
                                          disptext!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        trailing: SizedBox(
                                            width: 70,
                                            child: Text(snapshot
                                                .data.docs[index]["Date"])),
                                      )));
                            })));
              } else {
                return const Loading();
              }
            }),
        floatingActionButton: RawMaterialButton(
          onPressed: () async {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => NewCon()));
          },
          elevation: 2.0,
          fillColor: Colors.blue,
          constraints: BoxConstraints(minWidth: 0.0),
          padding: EdgeInsets.all(15.0),
          shape: CircleBorder(),
          child: Icon(
            Icons.add,
            size: 35.0,
            color: Colors.white,
          ),
        ));
  }

  Stream getChats() {
    var chats = FirebaseFirestore.instance
        .collection('User')
        .doc('Chats')
        .collection('prevdata')
        .orderBy('Date24', descending: true)
        .snapshots();

    return chats;
  }
}
