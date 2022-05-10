// This file is the page where user can add more payment methods to their account

// This page uses the Credit Card Validator API to check if card is valid
// as well as the type of card that is being used

// As user types the card information field, the card display ui will be dynamically updated

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:font_awesome_flutter/icon_data.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:http/http.dart' as http;

class AddPaymentPage extends StatefulWidget {
  final String userID;
  AddPaymentPage(this.userID);
  @override
  AddPaymentPageState createState() {
    return AddPaymentPageState();
  }
}

class AddPaymentPageState extends State<AddPaymentPage> {
  String cvvValidator;
  String dateValidator;
  String ccValidator;
  String nameValidator;
  IconData cardIconDisplay = Icons.credit_card;
  bool cardValid = false;
  String cardName = "";
  String dateOfExpiry = "";
  String cardNumber = "";
  String cvv = "";
  String cardType;
  var cardNumberController =
      new MaskedTextController(mask: '0000 0000 0000 0000');
  var cardExpiryController = new MaskedTextController(mask: '00/00');

  Future<List> _addCard() async {
    String cardNumberTrim = cardNumber.replaceAll(RegExp(r' '), '');
    String lastDigits;
    if (cardNumberTrim.length == 16) {
      lastDigits = cardNumberTrim[12] +
          cardNumberTrim[13] +
          cardNumberTrim[14] +
          cardNumberTrim[15];
    } else if (cardNumberTrim.length == 15) {
      lastDigits = cardNumberTrim[12] + cardNumberTrim[13] + cardNumberTrim[14];
    }
    print(cardValid);

    if (cardValid == false) {
      setState(() {
        ccValidator = "Invalid Credit Card";
      });
    } else {
      setState(() {
        ccValidator = null;
      });
    }
    if (cardName.length == 0) {
      setState(() {
        nameValidator = "Invalid Name";
      });
    } else {
      setState(() {
        nameValidator = null;
      });
    }
    if (dateOfExpiry.length != 5) {
      setState(() {
        dateValidator = "Invalid Date";
      });
    } else {
      setState(() {
        dateValidator = null;
      });
    }
    if (cvv.length != 3) {
      setState(() {
        cvvValidator = "Invalid CVV";
      });
    } else {
      setState(() {
        cvvValidator = null;
      });
    }
    if (cardValid == true &&
        cardName.length > 0 &&
        dateOfExpiry.length == 5 &&
        cvv.length == 3) {
      print("SUCCESS");
      final response = await http
          .post("https://mp02.projectsbit.org/KillQ/register_card.php", body: {
        "creditcard_no": lastDigits,
        "name_on_card": cardName,
        "date_of_expiry": dateOfExpiry,
        "cvv": cvv,
        "card_type": cardType,
        "user_id": widget.userID,
        "submit": "true",
      });

      var result = json.decode(response.body);
      Map<String, dynamic> addCardResult = result[0];

      if (addCardResult["result"] == "0") {
        print("fail");
      } else if (addCardResult["result"] == "1") {
        print("success");
        Navigator.pop(context);
      }
      return null;
    }
    return null;
  }

  Future<void> _verifyCard(cc) async {
    String ccTrim = cc.replaceAll(RegExp(r' '), '');
    var url =
        "https://api.bincodes.com/cc/?format=json&api_key=insert_api_key_here&cc=$ccTrim";
    final response = await http.get(url);
    Map<String, dynamic> result = json.decode(response.body);
    /*Map<String, dynamic> result = {
      "bin": "515735",
      "bank": "CITIBANK, N.A.",
      "card": "MASTERCARD",
      "type": "CREDIT",
      "level": "WORLD CARD",
      "country": "UNITED STATES",
      "countrycode": "US",
      "website": "HTTPS://ONLINE.CITIBANK.COM/",
      "phone": "1-800-374-9700",
      "valid": "true"
    };*/
    if (result["valid"] == "true") {
      switch (result["card"]) {
        case 'MASTERCARD':
          setState(() {
            cardIconDisplay = IconDataBrands(0xf1f1);
            cardValid = true;
          });
          cardType = "MASTERCARD";
          break;
        case 'VISA':
          setState(() {
            cardIconDisplay = IconDataBrands(0xf1f0);
            cardValid = true;
          });
          cardType = "VISA";
          break;
        case 'AMERICAN EXPRESS':
          setState(() {
            cardIconDisplay = IconDataBrands(0xf1f3);
            cardValid = true;
          });
          cardType = "AMERICAN EXPRESS";
          break;
      }
    } else {
      setState(() {
        cardValid = false;
        cardType = null;
      });
    }
  }

  textDisplay(displayType, displayValue) {
    if (displayType == "card_number") {
      if (displayValue == "") {
        return Text("**** **** **** ****",
            style: TextStyle(color: Colors.white, fontSize: 22.0));
      } else {
        return Text(displayValue,
            style: TextStyle(color: Colors.white, fontSize: 22.0));
      }
    } else if (displayType == "date_of_expiry") {
      if (displayValue == "") {
        return Text("MM/YY",
            style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.normal,
                color: Colors.white));
      } else {
        return Text(displayValue,
            style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.normal,
                color: Colors.white));
      }
    } else if (displayType == "cvv") {
      if (displayValue == "") {
        return Text("***",
            style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.normal,
                color: Colors.white));
      } else {
        return Text(displayValue,
            style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.normal,
                color: Colors.white));
      }
    } else if (displayType == "name_of_card_owner") {
      if (displayValue == "") {
        return Text("Your Name",
            style: TextStyle(color: Colors.white, fontSize: 22.0));
      } else {
        return Text(displayValue,
            style: TextStyle(color: Colors.white, fontSize: 22.0));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: GradientAppBar(
        elevation: 0.0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
        centerTitle: true,
        title: Text(
          "Payment Details",
          style: TextStyle(
            fontFamily: "OpenSans-Bold",
          ),
        ),
        backgroundColorStart: Color(0xfffF23D45),
        backgroundColorEnd: Color(0xfffF7544B),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: deviceSize.height * 0.3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xfffF7544B), Color(0xfffFE7353)]),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.elliptical(50, 10),
                  bottomRight: Radius.elliptical(50, 10)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 3.0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 3.0,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.blueGrey.shade800,
                          Colors.black87,
                        ]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          textDisplay("card_number", cardNumber),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Column(
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Expiry",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  textDisplay("date_of_expiry", dateOfExpiry),
                                ],
                              ),
                              SizedBox(
                                width: 30.0,
                              ),
                              Column(
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "CVV",
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  textDisplay("cvv", cvv),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        right: 10.0,
                        top: 10.0,
                        child: Icon(
                          cardIconDisplay,
                          color: Colors.white,
                          size: 40,
                        )),
                    Positioned(
                      right: 10.0,
                      bottom: 10.0,
                      child: textDisplay("name_of_card_owner", cardName),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: TextField(
                    controller: cardNumberController,
                    keyboardType: TextInputType.number,
                    maxLength: 19,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          cardIconDisplay,
                          color: Colors.black,
                          size: 32,
                        ),
                        errorText: ccValidator,
                        labelText: "Credit Card Number",
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        border: OutlineInputBorder()),
                    onChanged: (value) {
                      setState(() {
                        cardNumber = value;
                      });
                      if (cardNumber.length == 19 || cardNumber.length == 18) {
                        setState(() {
                          ccValidator = null;
                        });
                        _verifyCard(value);
                      } else {
                        setState(() {
                          cardIconDisplay = Icons.credit_card;
                        });
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    maxLength: 20,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        errorText: nameValidator,
                        labelText: "Name on card",
                        border: OutlineInputBorder()),
                    onChanged: (value) {
                      setState(() {
                        cardName = value;
                      });

                      if (cardName.length > 0) {
                        setState(() {
                          nameValidator = null;
                        });
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: (deviceSize.width * 0.5) - 32,
                        child: TextField(
                          controller: cardExpiryController,
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              errorText: dateValidator,
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              labelText: "MM/YY",
                              border: OutlineInputBorder()),
                          onChanged: (value) {
                            setState(() {
                              dateOfExpiry = value;
                            });
                            if (dateOfExpiry.length == 5) {
                              setState(() {
                                dateValidator = null;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 32.0),
                      Container(
                        width: (deviceSize.width * 0.5) - 32,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              errorText: cvvValidator,
                              labelStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              labelText: "CVV",
                              border: OutlineInputBorder()),
                          onChanged: (value) {
                            setState(() {
                              cvv = value;
                            });
                            if (cvv.length == 3) {
                              setState(() {
                                cvvValidator = null;
                              });
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  width: deviceSize.width,
                  height: deviceSize.height / 11,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: RaisedButton(
                      elevation: 7.0,
                      color: Color(0xfff596E8B),
                      onPressed: () {
                        _addCard();
                      },
                      child: Text(
                        "ADD CARD",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
