// It contains the code for validation, connection to database and the button animation
// It also contains the function for viewing the hidden password

import 'dart:async';
import 'dart:convert';
import 'package:flutter/animation.dart';

import 'package:flutter/material.dart';
import './animation.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

class LoginPage extends StatefulWidget {
  final Function fetchUserID;
  LoginPage(this.fetchUserID);

  @override
  LoginPageState createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> with TickerProviderStateMixin {

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AnimationController _loginButtonController;

  @override
  void initState() {
    super.initState();

    _loginButtonController = AnimationController(
        duration: Duration(milliseconds: 3000), vsync: this);
  }

  @override
  void dispose() {
    _loginButtonController.dispose();
    super.dispose();
  }

  String email;
  String password;
  var animationStatus = 0;

  // loginValidation value will be loaded below fields
  String loginValidation = "";
  //Sets validation value
  void formValidator(String value) {
    setState(() {
      loginValidation = value;
    });
  }

  bool _obscureTextLogin = true;
  void _viewPass() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  //Validates form internally (valid fields) and externally (comparing to server)
  Future<List> _login() async {
    if (!_formKey.currentState.validate()) {
      formValidator("");
      return null;
    } else {
      _formKey.currentState.save();

      final response = await http.post(
          "https://mp02.projectsbit.org/KillQ/login_app.php",
          body: {"email": email, "password": password, "role": 'cus'});

      var dataUser = json.decode(response.body);
      Map<String, dynamic> dataResult = dataUser[0];

      if (dataResult["result"] == "0") {
        formValidator("Incorrect Email or Password");
      } else if (dataResult["result"] == "1") {
        final date = DateTime.now();
        DateTime newdate = DateTime.parse(dataResult["date_of_birth"]);
        double difference = ((date.difference(newdate).inDays) / 365);
        int diff = difference.toInt();
        widget.fetchUserID(dataResult["user_id"], diff, dataResult["email"],
            dataResult["full_name"]);
        Navigator.pushReplacementNamed(context, '/landing');
      }
      return null;
    }
  }

  Future<Null> _playAnimation() async {
    try {
      await _loginButtonController.forward();
      await _loginButtonController.reverse();
    } on TickerCanceled {}
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.4;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Container(
      decoration: BoxDecoration(
        color: Color(0xfff596E8B),
        image: DecorationImage(
          colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.15), BlendMode.dstATop),
          image: AssetImage('assets/background/login_background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(0.0),
        children: <Widget>[
          Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 100.0),
                    child: Center(
                      child: Icon(
                        Icons.verified_user,
                        color: Colors.redAccent,
                        size: 50.0,
                      ),
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: Text(
                              "EMAIL",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.only(top: 10.0),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: Colors.redAccent,
                                    width: 0.5,
                                    style: BorderStyle.solid),
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    textAlign: TextAlign.left,
                                    initialValue: "john@smith.com",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16.5),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'kill@queue.com',
                                      hintStyle:
                                          TextStyle(color: Colors.grey[500]),
                                    ),
                                    validator: (String value) {
                                      if (value.isEmpty ||
                                          !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                                              .hasMatch(value)) {
                                        return "Invalid Email";
                                      }
                                    },
                                    onSaved: (value) {
                                      email = value;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Container(
                            child: Text(
                              "PASSWORD",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: Colors.redAccent,
                                    width: 0.5,
                                    style: BorderStyle.solid),
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    obscureText: _obscureTextLogin,
                                    textAlign: TextAlign.left,
                                    initialValue: "fypa123",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16.5),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '*********',
                                      hintStyle:
                                          TextStyle(color: Colors.grey[500]),
                                    ),
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return "Password field is empty!";
                                      }
                                    },
                                    onSaved: (value) {
                                      password = value;
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon:
                                      Icon(Icons.visibility, color: Colors.red),
                                  tooltip: 'View password',
                                  onPressed: (() {
                                    _viewPass();
                                  }),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        loginValidation,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(top: 80),
                    margin: const EdgeInsets.only(
                        left: 30.0, right: 30.0, top: 20.0),
                    alignment: Alignment.center,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 0, color: Colors.transparent),
                            ),
                          ),
                        ),
                        FlatButton(
                          child: Text(
                            "",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15.0,
                            ),
                            textAlign: TextAlign.end,
                          ),
                          onPressed: () {},
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0, color: Colors.transparent)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              animationStatus == 0
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            animationStatus = 1;
                          });
                          _playAnimation();
                        },
                        child: Container(
                          width: 320.0,
                          height: 60.0,
                          alignment: FractionalOffset.center,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius:
                                BorderRadius.all(const Radius.circular(30.0)),
                          ),
                          child: Text(
                            "LOGIN",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  : StaggerAnimation(
                      _loginButtonController.view, _login, "LOGIN"),
            ],
          ),
        ],
      ),
    );
  }
}
