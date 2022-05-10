// At the initialising stage of this page, we add a delay so the splashscreen will load for 3 seconds

// We will also check the shared prefences data if the user has seen the tutorial page. 
// If they have seen it, after the timer ends, they will be redirected straight to login
// If they have not seen it, they will be redirected to the tutorial page

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenPage extends StatefulWidget {
  @override
  SplashScreenPageState createState() {
    return SplashScreenPageState();
  }
}

class SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 3000), () {
      checkFirstSeen();
    });
  }

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      Navigator.pushReplacementNamed(context, '/auth');
    } else {
      Navigator.pushReplacementNamed(context, '/intro_slides');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xffffdbb2d),
                    Color(0xfffFE5A34),
                    Color(0xfffF1272C),
                    Color(0xfffA70B0F)
                  ]),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(60.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset("assets/title/Killed_the_que-06.png"),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                      ),
                       Image.asset("assets/title/Killed_the_que-03.png"),
                    ],
                  ),
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      Padding(padding: EdgeInsets.only(top: 20.0)),
                      Text("Beat The Queue Today!",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold))
                    ],
                  ))
            ],
          )
        ],
      ),
    );
  }
}
