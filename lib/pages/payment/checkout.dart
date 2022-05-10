// It contains the function to display the list of cards the user has in a slider
// It also contains all they transaction details, such as discounts saved and total price/quantity

// A receipt dialog will appear when user checkout, which will again contain the purchase information,
// such as store location, credit card used and total price

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class CheckoutPage extends StatefulWidget {
  final List cartList;
  final String userID;
  final String storeID;
  final String storeName;
  final String storePic;
  final double totalCartPrice;
  CheckoutPage(this.totalCartPrice, this.cartList, this.userID, this.storeID,
      this.storeName, this.storePic);

  @override
  CheckoutPageState createState() {
    return CheckoutPageState();
  }
}

class CheckoutPageState extends State<CheckoutPage> {
  @override
  void initState() {
    super.initState();
    calculateSubTotal();
    calculateDiscountTotal();
    _fetchCard();
  }

  List cardList = [];
  bool loaderState = false;

  Future<List> _fetchCard() async {
    final response = await http.post(
        "https://mp02.projectsbit.org/KillQ/fetch_card.php",
        body: {"user_id": widget.userID});
    List dataUser = json.decode(response.body);
    Map<String, dynamic> dataResult = dataUser[0];
    if (dataResult["result"] == "0") {
      setState(() {
        cardList = [];
      });
    } else {
      setState(() {
        cardList = dataUser;
      });
    }
    return null;
  }

  Future<List> _purchase() async {
    setState(() {
      loaderState = true;
    });
    List<String> productList = [];
    List<int> quantityList = [];
    double cogs = 0;
    for (var i = 0; i < widget.cartList.length; i++) {
      productList.add(widget.cartList[i]["product_id"]);
      quantityList.add(widget.cartList[i]["quantity"]);
      cogs += widget.cartList[i]["cogs"];
    }
    String newProductList = productList.join(', ');
    String newQuantityList = quantityList.join(', ');

    final response = await http
        .post("https://mp02.projectsbit.org/KillQ/purchase.php", body: {
      "user_id": widget.userID,
      "productList": newProductList,
      "quantityList": newQuantityList,
      "payment": cardList[cardSelected]["creditcard_no"],
      "store": widget.storeID,
      "COGS": cogs.toString(),
      "price": widget.totalCartPrice.toString()
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        loaderState = false;
      });
      var result = json.decode(response.body);
      Map<String, dynamic> purchaseResult = result[0];
      if (purchaseResult["result"] == "0") {
        print("fail");
      } else if (purchaseResult["result"] == "1") {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () {
                  Navigator.pushNamed(context, '/landing');
                },
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          child: Material(
                            clipBehavior: Clip.antiAlias,
                            elevation: 2.0,
                            borderRadius: BorderRadius.circular(4.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "Thank You!",
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.red),
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(
                                        "Your transaction was successful",
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.red),
                                      ),
                                    ],
                                  ),
                                  ListTile(
                                    title: Text("Date"),
                                    subtitle: Text(
                                        "${DateFormat.yMMMMd().format(DateTime.now())}"),
                                    trailing: Text(
                                        "${DateFormat.jm().format(DateTime.now())}"),
                                  ),
                                  ListTile(
                                    title: Text("Store Name"),
                                    subtitle: Text(widget.storeName),
                                    trailing: Container(
                                      width: 52.0,
                                      height: 52.0,
                                      padding: const EdgeInsets.all(2.0),
                                      decoration: BoxDecoration(
                                        color: Colors.red, // border color
                                        shape: BoxShape.circle,
                                      ),
                                      child: CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(widget.storePic),
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text("Amount"),
                                    subtitle: Text(
                                        "\$${widget.totalCartPrice.toStringAsFixed(2)}"),
                                    trailing: Text("Completed"),
                                  ),
                                  Card(
                                    clipBehavior: Clip.antiAlias,
                                    elevation: 0.0,
                                    color: Colors.grey.shade300,
                                    child: ListTile(
                                      leading: Icon(
                                        cardIconSelected(cardList[cardSelected]
                                            ["card_type"]),
                                        color: Colors.black,
                                      ),
                                      title: Text(
                                        "Credit/Debit Card",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                          "Card ending with ${cardList[cardSelected]["creditcard_no"]}"),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        FloatingActionButton(
                          backgroundColor: Colors.black,
                          child: Icon(
                            Icons.clear,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/landing');
                          },
                        )
                      ],
                    ),
                  ),
                ),
              );
            });
      }
    });
    return null;
  }

  int cardSelected;
  bool isSelected = false;

  IconData cardIconSelected(cardType) {
    switch (cardType) {
      case 'MASTERCARD':
        return FontAwesomeIcons.ccMastercard;
        break;
      case 'VISA':
        return FontAwesomeIcons.ccVisa;
        break;
      case 'AMERICAN EXPRESS':
        return FontAwesomeIcons.ccAmex;
        break;
    }
    return null;
  }

  cardNumberDisplay(cardNumber) {
    String lastDigits;
    if (cardNumber.length == 16) {
      lastDigits =
          cardNumber[12] + cardNumber[13] + cardNumber[14] + cardNumber[15];
      return lastDigits;
    } else if (cardNumber.length == 15) {
      lastDigits = cardNumber[12] + cardNumber[13] + cardNumber[14];
      return lastDigits;
    }
    return null;
  }

  double subTotal = 0;
  double discountTotal = 0;
  String subTotalString;
  String discountTotalString;
  calculateSubTotal() {
    for (var i = 0; i < widget.cartList.length; i++) {
      subTotal += widget.cartList[i]["price"] * widget.cartList[i]["quantity"];
    }
    subTotalString = subTotal.toStringAsFixed(2);
  }

  calculateDiscountTotal() {
    discountTotal = subTotal - widget.totalCartPrice;
    discountTotalString = discountTotal.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: GradientAppBar(
          elevation: 0.0,
          title: Text(
            'Checkout',
            style: TextStyle(fontFamily: "OpenSans-Bold"),
          ),
          centerTitle: true,
          backgroundColorStart: Color(0xfffF23D45),
          backgroundColorEnd: Color(0xfffF9604E)),
      body: ModalProgressHUD(
        inAsyncCall: loaderState,
        progressIndicator: CircularProgressIndicator(),
        child: Column(children: <Widget>[
          Container(
            width: deviceSize.width,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xfffF9604E), Color(0xfffFE7353)]),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.elliptical(200, 20),
                  bottomRight: Radius.elliptical(200, 20)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 3.0,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      height: cardList.isEmpty ? 0 : 200,
                      child: Swiper(
                          onTap: (int) {
                            setState(() {
                              cardSelected = int;
                              isSelected
                                  ? isSelected = false
                                  : isSelected = true;
                            });
                          },
                          physics: isSelected
                              ? NeverScrollableScrollPhysics()
                              : null,
                          loop: false,
                          pagination: SwiperPagination(),
                          scale: 0.7,
                          itemCount: cardList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 20.0, top: 12.0),
                              child: Card(
                                elevation: 1.0,
                                child: Stack(fit: StackFit.expand, children: <
                                    Widget>[
                                  Opacity(
                                    opacity: isSelected ? 0.25 : 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          Colors.blueGrey.shade800,
                                          Colors.black87,
                                        ]),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8.0, left: 16.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  "My Card Details",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontFamily:
                                                          "OpenSans-SemiBold"),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 16.0),
                                                  child: Icon(
                                                    cardIconSelected(
                                                        cardList[index]
                                                            ["card_type"]),
                                                    size: 30.0,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 16.0, left: 16.0),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Container(
                                                      width: deviceSize.width *
                                                          0.5,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text(
                                                            "Card Number",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          SizedBox(
                                                            height: 2.0,
                                                          ),
                                                          Text(
                                                            "xxxx-xxxx-xxxx-${cardList[index]["creditcard_no"]}",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text("Exp.",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                          SizedBox(
                                                            height: 2.0,
                                                          ),
                                                          Text(
                                                            "${cardList[index]["date_of_expiry"]}",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .white),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 16.0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Container(
                                                        width:
                                                            deviceSize.width *
                                                                0.5,
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 8.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Text(
                                                                "Card Holder Name",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                            SizedBox(
                                                              height: 2.0,
                                                            ),
                                                            Text(
                                                              "${cardList[index]["name_on_card"]}",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 8.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Text("CVV / CVC",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                            SizedBox(
                                                              height: 2.0,
                                                            ),
                                                            Text(
                                                              "***",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                      child: isSelected
                                          ? Image.asset(
                                              'assets/extras/addbutton.png')
                                          : null)
                                ]),
                              ),
                            );
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/addpayment')
                              .then((value) {
                            _fetchCard();
                          });
                        },
                        child: Text(
                          "Add Payment Method",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration:
                      BoxDecoration(color: Colors.grey[400], boxShadow: [
                    BoxShadow(blurRadius: 1.0, color: Colors.grey),
                    BoxShadow(),
                  ]),
                  width: deviceSize.width,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 24.0, top: 8.0, bottom: 8.0),
                    child: Text(
                      "Transaction Details",
                      style: TextStyle(fontSize: 18.0, color: Colors.black),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 1.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    width: 175.0,
                                    padding: EdgeInsets.only(
                                      top: 10.0,
                                      left: 8.0,
                                      right: 8.0,
                                    ),
                                    child: Text(
                                      'Product',
                                      style: TextStyle(
                                        color: Colors.blueGrey[300],
                                        fontSize: 13.0,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 75.0,
                                    padding: EdgeInsets.only(
                                      top: 10.0,
                                      left: 8.0,
                                      right: 8.0,
                                    ),
                                    child: Text(
                                      'Qty.',
                                      style: TextStyle(
                                          color: Colors.blueGrey[300],
                                          fontSize: 13.0),
                                    ),
                                  ),
                                  Container(
                                    //width: 150.0,
                                    padding: EdgeInsets.only(
                                      top: 10.0,
                                      left: 8.0,
                                      right: 8.0,
                                    ),
                                    child: Text(
                                      'Total',
                                      style: TextStyle(
                                        color: Colors.blueGrey[300],
                                        fontSize: 13.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Table(
                                columnWidths: {
                                  0: FixedColumnWidth(175.0),
                                  1: FixedColumnWidth(75.0),
                                  //2: FixedColumnWidth(200.0),
                                },
                                children: widget.cartList.map((product) {
                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          product["product_name"],
                                          style: TextStyle(
                                            fontSize: 15.0,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          product["quantity"].toString(),
                                          style: TextStyle(
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "\$ ${product["total_price"].toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                              Divider(
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                        Align(
                          alignment: FractionalOffset.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 15.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, left: 16.0, right: 16.0),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Subtotal: ",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                        Text(
                                          "\$ $subTotalString",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ]),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, left: 16.0, right: 16.0),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Discount: ",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                        Text(
                                          "- \$$discountTotalString",
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ]),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Divider(
                                    height: 10.0,
                                    color: Colors.black,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0,
                                      left: 16.0,
                                      right: 16.0,
                                      bottom: 14),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        "Total Amount",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        "\$${widget.totalCartPrice.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 60,
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                  child: RaisedButton(
                      shape: StadiumBorder(),
                      elevation: 15,
                      color: Color(0xfff596E8B),
                      child: isSelected
                          ? Text(
                              "CHECKOUT",
                              style: TextStyle(color: Colors.white),
                            )
                          : Text(
                              "CHECKOUT (Select a payment of method)",
                              style: TextStyle(color: Colors.white),
                            ),
                      onPressed: isSelected
                          ? () {
                              _purchase();
                            }
                          : null),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
