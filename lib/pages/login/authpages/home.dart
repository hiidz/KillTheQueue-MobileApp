// When the user press the login or sign up button, the page transition animation, 
// which is at the home.dart file, will be executed

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final Function gotoSignup;
  final Function gotoLogin;
  HomePage(this.gotoLogin, this.gotoSignup);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.redAccent,
        image: DecorationImage(
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.2), BlendMode.dstATop),
          image: AssetImage('assets/background/homeauth_background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: ListView(
        children: <Widget>[
          topImageDisplay(),
          topTitleDisplay(),
          signUpButton(context),
          loginButton(context),
        ],
      ),
    );
  }

  Widget topImageDisplay() {
    return Container(
      padding: EdgeInsets.only(top: 50.0, left: 70.0, right: 70.0),
      child: Center(
        child: Image.asset(
          "assets/title/Killed_the_que-06.png",
          scale: 2.0,
        ),
      ),
    );
  }

  Widget topTitleDisplay() {
    return Container(
      padding: EdgeInsets.only(top: 50.0, left: 50.0, right: 50.0),
      child: Image.asset(
        "assets/title/Killed_the_que-04.png",
        scale: 2.0,
      ),
    );
  }

  Widget signUpButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 120.0),
      alignment: Alignment.center,
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlineButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              color: Colors.redAccent,
              highlightedBorderColor: Colors.white,
              onPressed: () => gotoSignup(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 20.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        "SIGN UP",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget loginButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
      alignment: Alignment.center,
      child: Row(
        children: <Widget>[
          Expanded(
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              color: Colors.white,
              onPressed: () => gotoLogin(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 20.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        "LOGIN",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
