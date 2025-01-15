import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:ichat/screens/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:ichat/main.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'loading.dart';

// Decrypt and cache photos
File getImage(List params) {
  final dirPath = '${params[0]}/${params[1]}';
  Directory(dirPath).createSync();
  final file = File('${params[0]}/${params[1]}/${params[2]}.jpg');
  file.createSync();
  var decrypted = encrypter2.decrypt16(params[3], iv: iv2);
  var bytes = base64Decode(decrypted);
  file.writeAsBytesSync(bytes);
  return file;
}

// AES KEY
final symmkey = enc.Key.fromBase16('YOUR KEY GOES HERE');

// YOUR IV HERE
final iv2 = enc.IV.fromBase16("YOUR IV HERE");

String? image;

final encrypter2 = enc.Encrypter(
  enc.AES(symmkey, mode: enc.AESMode.cbc),
);

class mesgview extends StatefulWidget {
  final String contact;
  final String guid;
  final String Dispname;

  mesgview(this.contact, this.guid, this.Dispname);
  @override
  _mesgview createState() => _mesgview();
}

// Interface to show messages with individual person
class _mesgview extends State<mesgview> {
  final ValueNotifier<bool> _notifier = ValueNotifier(false);
  TextEditingController messageController = TextEditingController();
  final ScrollController _controller = ScrollController();

  List<String> bnames = ["camera", "gallery"];
  List<IconData> inames = [Icons.camera, Icons.photo_album];
  String? disptext;
  bool isLoading = false;
  int prevIndex = 0;
  int ImNum = 0;
  int prevImNum = 0;

  @override
  void dispose() {
    _notifier.dispose();
    _controller.dispose();

    FirebaseFirestore.instance
        .collection('User')
        .doc('Chats')
        .collection("prevdata")
        .doc(widget.guid)
        .update({"isRead": true});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: getMessages(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done ||
              snapshot.connectionState == ConnectionState.active) {
            return Scaffold(
              // Builds bottom messaging UI (photo, textfield and send button)
              bottomSheet: Container(
                color: Colors.blue,
                child: Row(children: <Widget>[
                  // Photo Button
                  Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: PopupMenuButton(
                        child: CircleAvatar(
                          backgroundColor: Colors.blue[900],
                          child: const Icon(Icons.camera, color: Colors.white),
                        ),
                        itemBuilder: (context) {
                          return List.generate(2, (index) {
                            return PopupMenuItem(
                                child: TextButton(
                                    onPressed: () async {
                                      final ImagePicker _picker = ImagePicker();

                                      if (index == 0) {
                                        Navigator.pop(context);

                                        final XFile? photo =
                                            await _picker.pickImage(
                                          source: ImageSource.camera,
                                        );
                                        if (photo != null) {
                                          _notifier.value = true;
                                          final path = photo.path;
                                          final bytes =
                                              await File(path).readAsBytes();

                                          final encrypted = encrypter2.encrypt(
                                              base64Encode(bytes),
                                              iv: iv2);

                                          String fn = getRandom(4);
                                          await firebase_storage
                                              .FirebaseStorage.instance
                                              .ref('${widget.guid}/$fn.text')
                                              .putString(encrypted.base64,
                                                  format: firebase_storage
                                                      .PutStringFormat.raw);

                                          String downloadURL =
                                              await firebase_storage
                                                  .FirebaseStorage.instance
                                                  .ref(
                                                      '${widget.guid}/$fn.text')
                                                  .getDownloadURL();

                                          await FirebaseFirestore.instance
                                              .collection('User')
                                              .doc('sentChats')
                                              .update({
                                            "NMsg": true,
                                            "Msg": "",
                                            "guid": widget.guid,
                                            "newR": false,
                                            "newC": "",
                                            "hasImg": true,
                                            "imgURL": downloadURL
                                          });
                                          Timer.periodic(
                                              const Duration(
                                                  milliseconds: 1000),
                                              (Timer timer) async {
                                            var msgs = await FirebaseFirestore
                                                .instance
                                                .collection('User')
                                                .doc('ChatData')
                                                .collection(widget.guid)
                                                .orderBy('messageID',
                                                    descending: true)
                                                //.where("sentByMe", isEqualTo: 1)
                                                .get();
                                            msgs.docs.sort((a, b) {
                                              if (b['sentByMe'] >
                                                  a['sentByMe']) {
                                                return 1;
                                              }
                                              return -1;
                                            });
                                            var msgl = msgs.docs.first;
                                            if (msgl["sentByMe"] == 1 ||
                                                msgl["hasImg"] == 1 ||
                                                msgl['messageID'] >
                                                    snapshot.data.docs
                                                        .last['messageID']) {
                                              timer.cancel();
                                              _notifier.value = false;
                                            }
                                          });
                                        }
                                      } else {
                                        // Pick an image
                                        Navigator.pop(context);

                                        final XFile? image =
                                            await _picker.pickImage(
                                                source: ImageSource.gallery);
                                        if (image != null) {
                                          _notifier.value = true;
                                          final path = image.path;
                                          final bytes =
                                              await File(path).readAsBytes();
                                          //print(base64Encode(bytes));
                                          final encrypted = encrypter2.encrypt(
                                              base64Encode(bytes),
                                              iv: iv2);
                                          //print(encrypted);
                                          String fn = getRandom(4);
                                          await firebase_storage
                                              .FirebaseStorage.instance
                                              .ref('${widget.guid}/$fn.text')
                                              .putString(encrypted.base64,
                                                  format: firebase_storage
                                                      .PutStringFormat.raw);

                                          String downloadURL =
                                              await firebase_storage
                                                  .FirebaseStorage.instance
                                                  .ref(
                                                      '${widget.guid}/$fn.text')
                                                  .getDownloadURL();

                                          await FirebaseFirestore.instance
                                              .collection('User')
                                              .doc('sentChats')
                                              .update({
                                            "NMsg": true,
                                            "Msg": "",
                                            "guid": widget.guid,
                                            "newR": false,
                                            "newC": "",
                                            "hasImg": true,
                                            "imgURL": downloadURL
                                          });
                                          Timer.periodic(
                                              const Duration(
                                                  milliseconds: 1000),
                                              (Timer timer) async {
                                            var msgs = await FirebaseFirestore
                                                .instance
                                                .collection('User')
                                                .doc('ChatData')
                                                .collection(widget.guid)
                                                .orderBy('messageID',
                                                    descending: true)
                                                .get();
                                            msgs.docs.sort((a, b) {
                                              if (b['sentByMe'] >
                                                  a['sentByMe']) {
                                                return 1;
                                              }
                                              return -1;
                                            });
                                            var msgl = msgs.docs.first;
                                            if (msgl["sentByMe"] == 1 ||
                                                msgl["hasImg"] == 1 ||
                                                msgl['messageID'] >
                                                    snapshot.data.docs
                                                        .last['messageID']) {
                                              timer.cancel();
                                              _notifier.value = false;
                                            }
                                          });
                                        }
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          inames[index],
                                          color: Colors.white,
                                        ),
                                        const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 2)),
                                        Text(
                                          bnames[index],
                                          style: const TextStyle(
                                              color: Colors.white),
                                        )
                                      ],
                                    )));
                          });
                        },
                      )),

                  // Text field
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 10, bottom: 10, top: 10, right: 10),
                      child: TextField(
                          style: const TextStyle(color: Colors.blue),
                          controller: messageController,
                          maxLines: null,
                          keyboardType: TextInputType.text,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.fromLTRB(
                                15.0, 10.0, 15.0, 10.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: const BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Write message...",
                            hintStyle: const TextStyle(color: Colors.blue),
                          )),
                    ),
                  ),

                  // Send message button
                  Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: CircleAvatar(
                          backgroundColor: Colors.blue[900],
                          child: FloatingActionButton(
                            shape: const CircleBorder(),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('User')
                                  .doc('sentChats')
                                  .update({
                                "NMsg": true,
                                "Msg": encrypter!
                                    .encrypt(messageController.text)
                                    .base64,
                                "guid": widget.guid,
                                "newR": false,
                                "newC": "",
                                "hasImg": false,
                                "imgURL": ""
                              });
                              String msg = messageController.text;
                              messageController.text = "";
                              loader(msg);
                            },
                            backgroundColor: Colors.blue[900],
                            elevation: 1,
                            child: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 18,
                            ),
                          ))),
                ]),
                //)
              ),
              body: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx >= 0 && details.delta.dy == 0) {
                    Navigator.of(context).pop(
                      MaterialPageRoute(builder: (context) => chatSc()),
                    );
                  }
                },
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(
                        top: 50,
                        bottom: 10,
                      ),
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          // Back Button on the Left
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => chatSc()),
                              );
                            },
                            child: const Icon(
                              Icons.arrow_left,
                              size: 35.0,
                              color: Colors.blueAccent,
                            ),
                          ),
                          // Spacer to push content to the center
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const CircleAvatar(
                                  radius: 25.0,
                                  backgroundColor: Colors.grey,
                                  child: Icon(CupertinoIcons.person_fill,
                                      color: Colors.white),
                                ),
                                Text(
                                  widget.Dispname,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          // Spacer on the right to balance the layout
                          const SizedBox(
                              width:
                                  60), // Equal to the width of the back button
                        ],
                      ),
                    ),
                    Expanded(
                      // Ensures ListView.builder gets proper constraints
                      child: ListView.builder(
                        reverse: true,
                        controller: _controller,
                        padding: const EdgeInsets.only(top: 10, bottom: 80),
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          // Decrypt the text message
                          String? disptext;
                          if (encrypter!.decrypt64(
                                  snapshot.data.docs[index]["text"],
                                  iv: iv) ==
                              "￼") {
                            disptext = "";
                          } else {
                            disptext = encrypter!.decrypt64(
                                snapshot.data.docs[index]["text"],
                                iv: iv);
                          }

                          // Determine if the message has an image
                          bool hasImage =
                              snapshot.data.docs[index]["hasImg"] == 1;

                          // Decrypt and display the image if it exists
                          Widget imageWidget = Visibility(
                            visible: hasImage,
                            child: FutureBuilder(
                              future: photoSave2(
                                snapshot.data.docs[index]["assetURL"],
                                snapshot.data.docs[index]["messageID"],
                                snapshot.data.docs[index]["hasImg"],
                              ),
                              builder: (context, AsyncSnapshot snapshot2) {
                                if (snapshot2.connectionState ==
                                        ConnectionState.done &&
                                    snapshot2.hasData) {
                                  // Display the decrypted image
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Column(
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            XFile file =
                                                XFile(snapshot2.data!.path);
                                            Share.shareXFiles([file]);
                                          },
                                          child: const Icon(Icons.download,
                                              color: Colors.white),
                                        ),
                                        Image.file(snapshot2.data!)
                                      ],
                                    ),
                                  );
                                } else if (snapshot2.hasError) {
                                  return const Text('Error loading image',
                                      style: TextStyle(color: Colors.red));
                                } else {
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: CircularProgressIndicator(
                                        color: Colors.white),
                                  );
                                }
                              },
                            ),
                          );

                          // Return the message container
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Display sent messages
                              Visibility(
                                visible:
                                    snapshot.data.docs[index]["sentByMe"] == 1,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 250),
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 7, 10, 7),
                                    margin: const EdgeInsets.only(top: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[700],
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        bottomLeft: Radius.circular(20),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          snapshot.data.docs[index]["date"],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        imageWidget,
                                        Text(
                                          disptext,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 17),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Display received messages
                              Visibility(
                                visible:
                                    snapshot.data.docs[index]["sentByMe"] == 0,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 250),
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 7, 10, 7),
                                    margin: const EdgeInsets.only(top: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          snapshot.data.docs[index]["date"],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11),
                                        ),
                                        imageWidget,
                                        Text(
                                          disptext,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 17),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: _notifier,
                      builder:
                          (BuildContext? context, bool? val, Widget? child) {
                        return Visibility(
                          visible: val!,
                          child: const LinearProgressIndicator(
                            color: Colors.blue,
                            minHeight: 10,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Loading();
          }
        });
  }

  // Stream constantly updating for newly recieved messages
  Stream getMessages() {
    var messagedata = FirebaseFirestore.instance
        .collection('User')
        .doc('ChatData')
        .collection(widget.guid)
        .orderBy('messageID', descending: true)
        .snapshots();
    return messagedata;
  }

  // Sorts messages
  void loader(String message) async {
    _notifier.value = true;
    Timer.periodic(const Duration(milliseconds: 1000), (Timer timer) async {
      var msgs = await FirebaseFirestore.instance
          .collection('User')
          .doc('ChatData')
          .collection(widget.guid)
          .orderBy('messageID', descending: true)
          .get();
      msgs.docs.sort((a, b) {
        if (b['sentByMe'] > a['sentByMe']) {
          return 1;
        }
        return -1;
      });
      var msgl = msgs.docs.first;
      String msg = encrypter!.decrypt64(msgl["text"], iv: iv);

      if (message == msg) {
        timer.cancel();
        _notifier.value = false;
      }
    });
  }

  // Load photos if message has photos
  Future<File> photoSave2(imgUrl, msgid, has) async {
    Directory documentDirectory = await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
    if (has == 0) {
      return File('/');
    }
    if (File('${documentDirectory.path}/${widget.guid}/$msgid.jpg')
        .existsSync()) {
      if (_controller.position.userScrollDirection != ScrollDirection.forward) {
        ImNum++;
      }

      final file = File('${documentDirectory.path}/${widget.guid}/$msgid.jpg');

      return file;
    } else {
      var rsp = await http.get(Uri.parse(imgUrl));

      if (_controller.position.userScrollDirection == ScrollDirection.idle) {
        ImNum++;
      }

      // Here we cache the photo for fast retrieval
      return compute(getImage,
          [documentDirectory.path, widget.guid, msgid.toString(), rsp.body]);
    }
  }
}

String getRandom(int length) {
  const ch = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
  Random r = Random();
  return String.fromCharCodes(
      Iterable.generate(length, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
}
