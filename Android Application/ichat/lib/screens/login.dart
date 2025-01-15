import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ichat/screens/forgotpassword.dart';
import 'chat.dart';

class Login extends StatefulWidget {
  @override
  _Login createState() => _Login();
}

TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();

class _Login extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  get user => _auth.currentUser;

  // Call Future to sign user in
  Future signIn({String? email, String? password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email!, password: password!);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade100,
                Colors.blue.shade900,
              ],
            )),
          ),
          SingleChildScrollView(
            child: Center(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Chat bubble icon
                    const Padding(
                        padding: EdgeInsets.only(top: 70),
                        child: Icon(
                          CupertinoIcons.chat_bubble_fill,
                          size: 250,
                          color: Colors.white,
                        )),

                    // Email label
                    const Padding(
                      padding: EdgeInsets.only(top: 35, left: 30, right: 0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Email:",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          )),
                    ),

                    // Email text field
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 5, left: 20, right: 20),
                      child: TextFormField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ), // add padding to adjust icon
                              child: Icon(
                                CupertinoIcons.person_alt_circle_fill,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 0,
                                //style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 0,
                              ),
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            hintStyle: const TextStyle(color: Colors.white),
                            hintText: "Enter your email",
                            fillColor: Colors.white12),
                      ),
                    ),

                    // Password text field
                    const Padding(
                      padding: EdgeInsets.only(top: 35, left: 30, right: 0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Password:",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          )),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 5, left: 20, right: 20),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ), // add padding to adjust icon
                              child: Icon(
                                CupertinoIcons.lock_circle_fill,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 0,
                                //style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 0,
                              ),
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            hintStyle: const TextStyle(color: Colors.white),
                            hintText: "Enter your password",
                            fillColor: Colors.white12),
                      ),
                    ),

                    //Sign-in button
                    Padding(
                        padding: const EdgeInsets.only(top: 35),
                        child: SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 20, left: 20),
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                      foregroundColor:
                                          WidgetStateProperty.all<Color>(
                                              Colors.blue),
                                      backgroundColor:
                                          WidgetStateProperty.all<Color>(
                                              Colors.white),
                                      shape: WidgetStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              side: const BorderSide(
                                                  color: Colors.white)))),
                                  onPressed: () async {
                                    signIn(
                                            email: emailController.text,
                                            password: passwordController.text)
                                        .then((result) {
                                      if (result == null) {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    chatSc()));
                                      } else {
                                        showAlertDialog4(context, result);
                                      }
                                    });
                                  },
                                  child: const Text('Login')),
                            ))),

                    // Forgot Password button
                    Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 20, left: 20),
                              child: TextButton(
                                  child: const Text(
                                    'Forgot Password',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ForgotPasswordPage()));
                                  }),
                            )))
                  ],
                ),
              ),
            ),
          )
        ]));
  }
}

showAlertDialog4(BuildContext context, String errmesg) {
  // Create button
  Widget okButton = TextButton(
    child: const Text("OK", style: TextStyle(color: Colors.red)),
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop();
    },
  );

  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    title: const Text("Error"),
    content: Text(errmesg),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
