// It contains the code for validation, connection to database and the button animation
// It also contains the function for viewing the hidden password

// This file also has the datepicker function

import 'dart:async';
import 'dart:convert';
import 'package:flutter/animation.dart';

import 'package:flutter/material.dart';
import './animation.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:intl/intl.dart';

class SignupPage extends StatefulWidget {
  final Function fetchUserID;
  SignupPage(this.fetchUserID);
  @override
  SignupPageState createState() {
    return SignupPageState();
  }
}

class SignupPageState extends State<SignupPage> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  AnimationController _signUpController;

  @override
  void initState() {
    super.initState();
    _signUpController = AnimationController(
        duration: Duration(milliseconds: 3000), vsync: this);
  }

  @override
  void dispose() {
    _signUpController.dispose();
    super.dispose();
  }

  String fullname;
  String email;
  String password;
  String phone;
  String dob;
  var animationStatus = 0;

  // registerValidation value will be loaded below fields
  String registerValidation = "";
  //Sets validation value
  void formValidator(String value) {
    setState(() {
      registerValidation = value;
    });
  }

  bool _obscureTextLogin = true;
  void _viewPass() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  Future<List> _register() async {
    if (!_formKey2.currentState.validate()) {
      formValidator("");
      return null;
    }
    _formKey2.currentState.save();
    final response = await http
        .post("https://mp02.projectsbit.org/KillQ/register.php", body: {
      "full_name": fullname,
      "password": password,
      "email": email,
      "phone_no": phone,
      "date_of_birth": dob,
      "role": 'cus',
      "submit": "true"
    });
    var dataUser = json.decode(response.body);
    Map<String, dynamic> dataResult = dataUser[0];
    if (dataResult["result"] == "0") {
      formValidator("Email has already been registered");
    } else {
      final date = DateTime.now();
      List newdob = dob.split("/");
      DateTime dateOfBirth =
          DateTime.parse(newdob[2] + "-" + newdob[0] + "-" + newdob[1]);
      double difference = ((date.difference(dateOfBirth).inDays) / 365);
      int diff = difference.toInt();

      widget.fetchUserID(dataResult["user_id"], diff, dataResult["email"],
          dataResult["full_name"]);
      Navigator.pushReplacementNamed(context, '/landing');
    }
    return null;
  }

  Future _chooseDate(BuildContext context, String initialDateString) async {
    var now = DateTime.now();
    var initialDate = convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year >= 1900 && initialDate.isBefore(now)
        ? initialDate
        : now);

    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1900),
        lastDate: DateTime.now());

    if (result == null) return;

    setState(() {
      _controller.text = DateFormat('dd/MM/yyyy').format(result);
    });
  }

  DateTime convertToDate(String input) {
    try {
      var d = DateFormat('dd/MM/yyyy').parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  Future<Null> _playAnimation() async {
    try {
      await _signUpController.forward();
      await _signUpController.reverse();
    } on TickerCanceled {}
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.4;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Color(0xfff596E8B),
        image: DecorationImage(
          colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.15), BlendMode.dstATop),
          image: AssetImage('assets/background/signup_background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: ListView(
        children: <Widget>[
          Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 100.0),
                    child: Center(
                      child: Icon(
                        Icons.account_box,
                        color: Colors.redAccent,
                        size: 50.0,
                      ),
                    ),
                  ),
                  Form(
                    key: _formKey2,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: Text(
                              "NAME",
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
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: Colors.redAccent,
                                    width: 0.5,
                                    style: BorderStyle.solid),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16.5),
                                    decoration: InputDecoration(
                                      icon: Icon(
                                        Icons.person,
                                        color: Colors.red,
                                      ),
                                      border: InputBorder.none,
                                      hintText: 'Sim Jie Ru',
                                      hintStyle:
                                          TextStyle(color: Colors.grey[500]),
                                    ),
                                    initialValue: "Tom Cruise",
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return "Invalid Name";
                                      }
                                    },
                                    onSaved: (value) {
                                      fullname = value;
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
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: Colors.redAccent,
                                    width: 0.5,
                                    style: BorderStyle.solid),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                      keyboardType: TextInputType.emailAddress,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16.5),
                                      decoration: InputDecoration(
                                        icon: Icon(Icons.email,
                                            color: Colors.red),
                                        border: InputBorder.none,
                                        hintText: 'tom@cruise.com',
                                        hintStyle:
                                            TextStyle(color: Colors.grey[500]),
                                      ),
                                      initialValue: "tom@cruise.com",
                                      validator: (String value) {
                                        if (value.isEmpty ||
                                            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                                                .hasMatch(value)) {
                                          return "Invalid Email";
                                        }
                                      },
                                      onSaved: (value) {
                                        email = value;
                                      }),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                registerValidation,
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                ),
                              ),
                            ],
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
                            margin: const EdgeInsets.only(top: 10.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: Colors.redAccent,
                                    width: 0.5,
                                    style: BorderStyle.solid),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    obscureText: _obscureTextLogin,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16.5),
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.lock, color: Colors.red),
                                      border: InputBorder.none,
                                      hintText: '*********',
                                      hintStyle:
                                          TextStyle(color: Colors.grey[500]),
                                    ),
                                    initialValue: "password",
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return "Invalid Password";
                                      } else if (value.length < 4) {
                                        return "Minimum of 4 characters";
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
                          SizedBox(
                            height: 20.0,
                          ),
                          Container(
                            child: Text(
                              "PHONE",
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
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: Colors.redAccent,
                                    width: 0.5,
                                    style: BorderStyle.solid),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                      keyboardType: TextInputType.phone,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16.5),
                                      decoration: InputDecoration(
                                        icon: Icon(Icons.phone,
                                            color: Colors.red),
                                        border: InputBorder.none,
                                        hintText: '9876 5432',
                                        hintStyle:
                                            TextStyle(color: Colors.grey[500]),
                                      ),
                                      initialValue: "98761232",
                                      validator: (String value) {
                                        if (value.isEmpty) {
                                          return "Invalid Phone";
                                        } else if (value.length != 8) {
                                          return "Phone number must be 8 digits long";
                                        }
                                      },
                                      onSaved: (value) {
                                        phone = value;
                                      }),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 40.0),
                                  child: Text(
                                    "DATE OF BIRTH",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.only(top: 10.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: Colors.redAccent,
                                    width: 0.5,
                                    style: BorderStyle.solid),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                      keyboardType: TextInputType.datetime,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16.5),
                                      decoration: InputDecoration(
                                        icon: Icon(Icons.calendar_today,
                                            color: Colors.red),
                                        border: InputBorder.none,
                                        hintText: '02/02/1997',
                                        hintStyle:
                                            TextStyle(color: Colors.grey[500]),
                                      ),
                                      controller: _controller,
                                      validator: (val) {
                                        var d = convertToDate(val);
                                        if (val.isEmpty ||
                                            d.isAfter(DateTime.now()) ||
                                            d.isAtSameMomentAs(
                                                DateTime.now())) {
                                          return "Invalid Date";
                                        }
                                      },
                                      onSaved: (value) {
                                        dob = value;
                                      }),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.more_horiz,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Choose date',
                                  onPressed: (() {
                                    _chooseDate(context, _controller.text);
                                  }),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 140,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: animationStatus == 0
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
                                borderRadius: BorderRadius.all(
                                    const Radius.circular(30.0)),
                              ),
                              child: Text(
                                "SIGN UP",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )
                      : StaggerAnimation(
                          _signUpController.view, _register, "SIGN UP"))
            ],
          )
        ],
      ),
    );
  }
}
