import 'dart:async';
import 'package:ichat/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:core';
import 'chat.dart';

class NewCon extends StatefulWidget {
  @override
  _NewConState createState() => _NewConState();
}

// Widget to start new conversation
class _NewConState extends State<NewCon> {
  bool buttonPress = false;
  TextEditingController to = TextEditingController();
  TextEditingController message = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Start a New Conversation"),
        titleTextStyle: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.delta.direction <= 0) {
            Navigator.of(context)
                .pop(MaterialPageRoute(builder: (context) => chatSc()));
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // "To:" Label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "To",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.blueAccent),
                  ),
                ),
                const SizedBox(height: 8),
                // "To" Text Field
                TextFormField(
                  controller: to,
                  style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter email or phone number",
                    hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white),
                    prefixIcon: const Icon(Icons.person, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                    filled: true,
                    fillColor: Colors.blue[50],
                  ),
                ),
                const SizedBox(height: 20),
                // "Message" Label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Message",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.blueAccent),
                  ),
                ),
                const SizedBox(height: 8),
                // Message Text Field
                TextFormField(
                  controller: message,
                  style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: "Write your message...",
                    hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white),
                    prefixIcon: const Icon(Icons.message, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blueAccent),
                    ),
                    filled: true,
                    fillColor: Colors.blue[50],
                  ),
                ),
                const SizedBox(height: 30),
                // Start Conversation Button
                Visibility(
                  visible: !buttonPress,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        buttonPress = true;
                      });

                      // Send message to firebase
                      await FirebaseFirestore.instance
                          .collection('User')
                          .doc('sentChats')
                          .update({
                        "NMsg": true,
                        "Msg": encrypter!.encrypt(message.text).base64,
                        "newC": to.text,
                        "newR": true,
                        "guid": "",
                        "hasImg": false,
                        "imgURL": ""
                      });

                      // Wait untill message sent, push to message interface
                      Timer.periodic(const Duration(milliseconds: 500),
                          (Timer timer) async {
                        var docs = await FirebaseFirestore.instance
                            .collection('User')
                            .doc('Chats')
                            .collection('prevdata')
                            .where('users', arrayContains: to.text)
                            .get();
                        docs.docs.forEach((element) {
                          if (element["users"].length == 1) {
                            timer.cancel();
                            Navigator.of(context).pop(MaterialPageRoute(
                                builder: (context) => chatSc()));
                          }
                        });
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: const Text(
                      "Start Conversation",
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),

                // Loading Indicator
                Visibility(
                  visible: buttonPress,
                  child: const Padding(
                    padding: EdgeInsets.only(top: 35),
                    child: CircularProgressIndicator(
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
