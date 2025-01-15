import 'package:flutter/material.dart';

/// This is the stateful widget that the main application instantiates.
class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  State<Loading> createState() => _Loading();
}

/// This is the private State class that goes with MyStatefulWidget.
/// AnimationControllers can be created with `vsync: this` because of TickerProviderStateMixin.
class _Loading extends State<Loading> with TickerProviderStateMixin {
  AnimationController? controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    controller?.repeat(reverse: false);

    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          const Align(
            alignment: Alignment.center,
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
            child: Align(
              child: CircularProgressIndicator(
                value: controller?.value,
                strokeWidth: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
