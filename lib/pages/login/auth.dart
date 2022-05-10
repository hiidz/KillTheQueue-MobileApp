// This page also contains animation controller, which when the user press the login or sign up button, 
// the page transition will act like a slider

import 'package:flutter/material.dart';

import './authpages/home.dart';
import './authpages/signup.dart';
import './authpages/login.dart';

class AuthPage extends StatefulWidget {
  final Function fetchUserID;
  AuthPage(this.fetchUserID);
  @override
  AuthPageState createState() {
    return AuthPageState();
  }
}

class AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  PageController _controller =
      PageController(initialPage: 1, viewportFraction: 1.0);



  gotoLogin() {
    //controller_0To1.forward(from: 0.0);
    _controller.animateToPage(
      0,
      duration: Duration(milliseconds: 800),
      curve: Curves.fastOutSlowIn,
    );
  }

  gotoSignup() {
    //controller_minus1To0.reverse(from: 0.0);
    _controller.animateToPage(
      2,
      duration: Duration(milliseconds: 800),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          height: MediaQuery.of(context).size.height,
          child: PageView(
            controller: _controller,
            physics: AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              LoginPage(widget.fetchUserID),
              HomePage(gotoLogin, gotoSignup),
              SignupPage(widget.fetchUserID)
            ],
            scrollDirection: Axis.horizontal,
          )),
    );
  }
}
