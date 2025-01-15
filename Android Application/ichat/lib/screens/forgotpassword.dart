import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _message;

  void _sendPasswordResetEmail() async {
    setState(() {
      _message = null;
    });

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      setState(() {
        _message = 'Password reset email sent!';

        // Introduce a 3-second delay before navigating back
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pop(context); // Navigate back after the delay
        });
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _message = e.message;
      });
    } finally {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.blue.shade900,
          title: Text('Forgot Password'),
          titleTextStyle: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        body: Stack(children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade900,
                Colors.blue.shade300,
              ],
            )),
          ),
          SingleChildScrollView(
            child: Center(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                        padding: EdgeInsets.only(top: 70),
                        child: Icon(
                          CupertinoIcons.padlock,
                          size: 250,
                          color: Colors.white,
                        )),
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
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 5, left: 20, right: 20),
                      child: TextFormField(
                        controller: _emailController,
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
                                    _sendPasswordResetEmail();
                                  },
                                  child: const Text('Reset')),
                            ))),
                    if (_message != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          _message!,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          )
        ]));
  }
}
