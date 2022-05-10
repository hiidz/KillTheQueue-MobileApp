// This file is our tutorial page codes. 

// We used a third party library, intro_slider, to create 4 tutorial pages with a slider

// We used another library, shared preferences, to save the data that user has already seen the tutorial, so 
// it the page will not appear again when app is reloaded

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intro_slider/intro_slider.dart';

class IntroSlidePages extends StatefulWidget {
  final String userID;
  IntroSlidePages(this.userID);
  @override
  IntroSlidePagesState createState() {
    return IntroSlidePagesState();
  }
}

class IntroSlidePagesState extends State<IntroSlidePages> {
  List<Slide> slides = List();
  bool userExist;

  @override
  void initState() {
    super.initState();

    if (widget.userID == null) {
      userExist = false;
    } else {
      userExist = true;
    }
    slides.add(
      Slide(
          title: "Turn On Location",
          description:
              "Turn on your GPS to find the nearest Shops that support Kill-The-Queue!",
          pathImage: "assets/tutorial/Tutorial_1.jpeg",
          backgroundColor: Color(0xfffFFA33A)),
    );
    slides.add(
      Slide(
          title: "Select Your Shop",
          description:
              "After turning on your location, choose your desired store!",
          pathImage: "assets/tutorial/Tutorial_2.png",
          backgroundColor: Color(0xfff3F88C5)),
    );
    slides.add(
      Slide(
          title: "Scan Your Item",
          description:
              "Simply scan the item's QR code to add it to cart!",
          pathImage: "assets/tutorial/Tutorial_3.jpeg",
          backgroundColor: Color(0xfffD72638)),
    );
    slides.add(
      Slide(
          title: "Make Payment",
          description:
              "Skip the queue and make payment on the app!",
          pathImage: "assets/tutorial/Tutorial_4.jpeg",
          backgroundColor: Color(0xfff201849)),
    );
  }

  Future onDonePress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('seen', true);
    userExist
        ? Navigator.pop(context)
        : Navigator.pushReplacementNamed(context, '/auth');
  }

  void onSkipPress() {
    userExist
        ? Navigator.pop(context)
        : Navigator.pushReplacementNamed(context, '/auth');
  }

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      slides: this.slides,
      onDonePress: this.onDonePress,
      onSkipPress: this.onSkipPress,
    );
  }
}
