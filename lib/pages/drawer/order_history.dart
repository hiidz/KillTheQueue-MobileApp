// Displays all the order history details which is fetched from the database

// A library draggable scrollbar is used so user can scroll the page quickly

import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class OrderHistoryPage extends StatefulWidget {
  final String userID;
  OrderHistoryPage(this.userID);

  @override
  OrderHistoryPageState createState() {
    return OrderHistoryPageState();
  }
}

class OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  void initState() {
    super.initState();

    _fetchOrderHistory();
  }

  bool loaderState = false;

  List orderHistory = [];

  Future<Null> _fetchOrderHistory() async {
    setState(() {
      loaderState = true;
    });
    final response = await http.post(
        "https://mp02.projectsbit.org/KillQ/order_history.php",
        body: {"user_id": widget.userID});

    List orderList = json.decode(response.body);
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        loaderState = false;
      });

      Map<String, dynamic> orderHistoryResult = orderList[0];
      if (orderHistoryResult["result"] == "0") {
        setState(() {
          orderHistory = [];
        });
      } else {
        setState(() {
          orderHistory = orderList;
        });
      }
    });
  }

  ScrollController _semicircleController = ScrollController();
  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return ModalProgressHUD(
      inAsyncCall: loaderState,
      progressIndicator: CircularProgressIndicator(),
      child: Scaffold(
        appBar: GradientAppBar(
            elevation: 0.0,
            title: Text(
              'Order History',
              style: TextStyle(fontFamily: "OpenSans-Bold"),
            ),
            centerTitle: true,
            backgroundColorStart: Color(0xfffF23D45),
            backgroundColorEnd: Color(0xfffF9604E)),
        body: Column(children: <Widget>[
          Container(
            width: deviceWidth,
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
            child: DraggableScrollbar.semicircle(
              controller: _semicircleController,
              child: orderHistory.length > 0
                  ? ListView.builder(
                      controller: _semicircleController,
                      itemCount: orderHistory.length,
                      itemBuilder: (BuildContext context, int index) {
                        List productName =
                            orderHistory[index]["product_name"].split(",");
                        List productQty =
                            orderHistory[index]["quantity"].split(",");
                        double totalPrice =
                            double.parse(orderHistory[index]["price"]);
                        String storeImage = orderHistory[index]["image"];
                        print(orderHistory);
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: 8.0, left: 12, right: 12, top: 8.0),
                          child: Card(
                            elevation: 4,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey[300]))),
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 18.0, bottom: 5),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "ORDER #${orderHistory[index]["order_id"]}",
                                              style: TextStyle(
                                                fontFamily: "Roboto-bold",
                                                fontSize: 16,
                                                color: Color(0xfff596E8B),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                              ),
                                              Text(
                                                "  Completed",
                                                style: TextStyle(
                                                    fontFamily:
                                                        "OpenSans-SemiBold",
                                                    color: Color(0xfff596E8B)),
                                              )
                                            ]),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 18.0),
                                        child: Container(
                                          width: 120,
                                          child: Text(
                                            DateFormat('dd MMMM yyyy hh:mm aa')
                                                .format(DateTime.parse(
                                                    orderHistory[index]
                                                        ["created_at"])),
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                color: Colors.grey[700],
                                                fontFamily: "OpenSans-Bold",
                                                fontSize: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 24.0),
                                    child: ListView.separated(
                                      separatorBuilder: (context, index) =>
                                          Divider(
                                            color: Colors.black,
                                          ),
                                      itemCount: productName.length,
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      itemBuilder:
                                          (BuildContext context, int idx) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 4.0),
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                width:
                                                    (deviceWidth - 24) * 0.65,
                                                child: Text(
                                                  productName[idx],
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontFamily:
                                                          "OpenSans-SemiBold"),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                    "${productQty[idx]} pcs"),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    )),
                                Container(
                                  height: 50,
                                  color: Colors.blueGrey[50],
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                width: 40.0,
                                                height: 40.0,
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                decoration: new BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(
                                                            storeImage)),
                                              ),
                                              Container(
                                                height: 30.0,
                                                width: 1.0,
                                                color: Colors.blueGrey,
                                                margin: const EdgeInsets.only(
                                                    left: 10.0, right: 10.0),
                                              ),
                                              Container(
                                                padding:
                                                    EdgeInsets.only(left: 5),
                                                child: Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.credit_card,
                                                      color: Color(0xfff8E2724),
                                                    ),
                                                    Text(
                                                      " **** ${orderHistory[index]["payment"]}",
                                                      style: TextStyle(
                                                          fontFamily:
                                                              "OpenSans-Regular",
                                                          fontSize: 14,
                                                          color: Color(
                                                              0xfff8E2724)),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(right: 12),
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                "Total:   ",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily:
                                                        "OpenSans-regular",
                                                    color: Colors.blueGrey),
                                              ),
                                              Text(
                                                " \$${totalPrice.toStringAsFixed(2)}",
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontFamily:
                                                        "OpenSans-SemiBold",
                                                    color: Color(0xfff201849)),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : ListView(
                      children: <Widget>[
                        SizedBox(
                          height: 100,
                        ),
                        Icon(
                          Icons.receipt,
                          size: 50.0,
                          color: Colors.grey[600],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'You have not completed any orders.',
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Color(0xfff596E8B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
            ),
          )
        ]),
      ),
    );
  }
}
