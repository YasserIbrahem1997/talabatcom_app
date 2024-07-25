import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashOne extends StatefulWidget {
  @override
  _SplashOneState createState() => _SplashOneState();
}

class _SplashOneState extends State<SplashOne> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      // Navigate to the existing SplashScreen after 3 seconds
      Get.offNamed('/splashScreen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Image(
          height: 200,
          width: 200,
          fit: BoxFit.fill,
          image: AssetImage("assets/image/splashOne.png"),
        ),
      ),
    );
  }
}
