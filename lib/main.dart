import 'package:flutter/material.dart';

import './pages/intro/splashscreen.dart';
import './pages/intro/intro_slides.dart';
import './pages/cart/cart.dart';
import './pages/login/auth.dart';
import './pages/landing/landing.dart';
import './pages/payment/addpayment.dart';
import './pages/payment/checkout.dart';
import './pages/drawer/order_history.dart';

void main() => runApp(KillQApp());

class KillQApp extends StatefulWidget {
  @override
  KillQAppState createState() {
    return KillQAppState();
  }
}

class KillQAppState extends State<KillQApp> {
  String userID;
  String storeID;
  String storeName;
  String storePic;
  int ageDifference;
  String email;
  String fullName;
  List cartList;
  double totalCartPrice;

  void fetchUserID(id, dob, emailData, name) {
    setState(() {
      userID = id;
      ageDifference = dob;
      email = emailData;
      fullName = name;
    });
  }

  void fetchStore(id, name, pic) {
    setState(() {
      storeID = id;
      storeName = name;
      storePic = pic;
    });
  }

  void saveCartList(List cartlist, cartTotal) {
    setState(() {
      cartList = cartlist;
      totalCartPrice = cartTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'OpenSans-Regular',
      ),
      home: SplashScreenPage(),
      routes: {
        '/intro_slides': (context) => IntroSlidePages(userID),
        '/auth': (context) => AuthPage(fetchUserID),
        '/landing': (context) => LandingPage(fetchStore, fetchUserID, email, fullName),
        '/cart': (context) => CartPage(storeID, saveCartList,ageDifference),
        '/addpayment': (context) => AddPaymentPage(userID),
        '/checkout': (context) => CheckoutPage(
            totalCartPrice, cartList, userID, storeID, storeName, storePic),
        '/order_history': (context) => OrderHistoryPage(userID),
      },
    );
  }
}
