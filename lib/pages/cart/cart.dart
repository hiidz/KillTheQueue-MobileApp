// Contains QR Code scanner, product modal sheet and product slider

// This file is connected to the database to fetch the product information,
// which will depend on the product ID, which is fetched from the product QR Code

// The QR Code and slidable library is used for this page

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import './product_info.dart';

class CartPage extends StatefulWidget {
  final String storeID;
  final Function saveCartList;
  final int userAge;
  CartPage(this.storeID, this.saveCartList, this.userAge);
  @override
  CartPageState createState() {
    return CartPageState();
  }
}

class CartPageState extends State<CartPage> {
  List product = [];
  int _n = 1;
  double discountedTotalPrice = 0;

  Future _scanQR() async {
    try {
      String barcode = await BarcodeScanner.scan();
      _fetchProduct(barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        print("CAMERA ACCESS DENIED");
      } else {
        print("UNKNOWN ERROR1");
      }
    } on FormatException {
      print("UNKNOWN ERROR2");
    } catch (e) {
      print(e);
    }
  }

  Future _fetchProduct(String barcode) async {
    final response = await http.post(
        "https://mp02.projectsbit.org/KillQ/fetch_product.php",
        body: {"product_id": barcode, "merchant_id": widget.storeID});

    var dataResult = json.decode(response.body);
    Map<String, dynamic> productData = dataResult[0];

    if (productData["result"] == "0") {
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Product does not exist!'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Please try scanning another product.'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'CLOSE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(
                  'RETRY',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  _scanQR();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      _showModalSheet(productData);
    }
  }

  Future<Null> add(StateSetter updateState) async {
    updateState(() {
      _n++;
    });
  }

  Future<Null> minus(StateSetter updateState) async {
    updateState(() {
      if (_n != 1) _n--;
    });
  }

  void _showModalSheet(productData) {
    String productId = productData["product_id"];
    String productName = productData["product_name"];
    double productOriginalCost = double.tryParse(productData["original_cost"]);
    double productPrice = double.tryParse(productData["price"]);
    String productImage = productData["image"];
    String productBrand = productData["brand"];
    String productDescription = productData["description"];
    String productAgeRestriction = productData["age_restricted"];
    String productCategory = productData["category"];
    double discountedProductPrice =
        double.tryParse(productData["discounted_price"]);
    String olddiscountDateCreated = productData["discounted_date_created"];
    String olddiscountValidUntilDate = productData["discount_valid_until"];
    DateTime discountDateCreated;
    DateTime discountValidUntilDate;
    int dateTimeDifference;
    bool discountExist;
    if (olddiscountDateCreated == "") {
      discountDateCreated = null;
    } else {
      discountDateCreated = DateTime.parse(olddiscountDateCreated);
      final todaysDate = DateTime.now();
      dateTimeDifference = discountDateCreated.difference(todaysDate).inDays;
    }
    if (olddiscountValidUntilDate == "") {
      discountValidUntilDate = null;
    } else {
      discountValidUntilDate = DateTime.parse(olddiscountValidUntilDate);
    }

    if (discountDateCreated == null ||
        discountValidUntilDate == null ||
        dateTimeDifference > 0) {
      discountedProductPrice = productPrice;
    }

    if (productPrice == discountedProductPrice) {
      discountExist = false;
    } else {
      discountExist = true;
    }

    Future<void> future = showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, state) {
          return GestureDetector(
            onTap: () {},
            child: Container(
              height: 240.0,
              color: Colors.white,
              child: Card(
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 55.0,
                      child: Image(
                        image: NetworkImage(productImage),
                      ),
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: 10.0, bottom: 5.0),
                          child: Text(
                            '${productName[0].toUpperCase()}${productName.substring(1)}',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          child: discountExist
                              ? Row(
                                  children: <Widget>[
                                    Text(
                                      "\$${(_n * productPrice).toStringAsFixed(2)}",
                                      style: TextStyle(
                                          fontSize: 17.0,
                                          color: Colors.grey,
                                          decoration:
                                              TextDecoration.lineThrough),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "\$${(_n * discountedProductPrice).toStringAsFixed(2)}",
                                      style: TextStyle(
                                          fontSize: 17.0, color: Colors.red),
                                    ),
                                  ],
                                )
                              : Text(
                                  "\$${(_n * discountedProductPrice).toStringAsFixed(2)}",
                                  style: TextStyle(
                                      fontSize: 17.0, color: Colors.red),
                                ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Quantity:",
                                style: TextStyle(fontSize: 15.0),
                              ),
                              IconButton(
                                icon: Icon(const IconData(0xe15b,
                                    fontFamily: 'MaterialIcons')),
                                onPressed: () {
                                  minus(state);
                                },
                              ),
                              Text(
                                '$_n',
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.add,
                                  size: 20.0,
                                ),
                                onPressed: () {
                                  add(state);
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 30.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              FlatButton(
                                textColor: Colors.black,
                                color: Colors.white,
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                shape: StadiumBorder(),
                              ),
                              RaisedButton(
                                textColor: Colors.white,
                                color: Colors.redAccent,
                                child: Text('Add to cart'),
                                onPressed: () {
                                  Map<String, dynamic> productAdd = {
                                    "product_id": productId,
                                    "product_name": productName,
                                    "original_cost": productOriginalCost,
                                    "cogs": productOriginalCost * _n,
                                    "price": productPrice,
                                    "total_price": discountedProductPrice * _n,
                                    "image": productImage,
                                    "brand": productBrand,
                                    "description": productDescription,
                                    "age_restricted": productAgeRestriction,
                                    "category": productCategory,
                                    "quantity": _n,
                                    "discount_price": discountedProductPrice,
                                    "discount_date_start": discountDateCreated,
                                    "discount_date_end": discountValidUntilDate
                                  };
                                  if (int.parse(productAgeRestriction) >
                                      widget.userAge) {
                                    showDialog<void>(
                                      context: context,
                                      barrierDismissible:
                                          false, // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('You are underage'),
                                          content: SingleChildScrollView(
                                            child: ListBody(
                                              children: <Widget>[
                                                Text(
                                                    'You have to be $productAgeRestriction years old to purchase this.'),
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text(
                                                'OK',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).popUntil(
                                                    ModalRoute.withName(
                                                        '/cart'));
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    if (product.length == 0) {
                                      discountedTotalPrice +=
                                          discountedProductPrice * _n;
                                      product.add(productAdd);
                                      Navigator.pop(context);
                                    } else {
                                      bool found = false;
                                      for (var i = 0; i < product.length; i++) {
                                        if (product[i]["product_name"] ==
                                            productAdd["product_name"]) {
                                          found = true;
                                          showDialog<void>(
                                            context: context,
                                            barrierDismissible:
                                                false, // user must tap button!
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                    'Product is already in the cart!'),
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: <Widget>[
                                                      Text(
                                                          'Do you wish to update quantity of the product?'),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    child: Text(
                                                      'NO',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .popUntil(ModalRoute
                                                              .withName(
                                                                  '/cart'));
                                                    },
                                                  ),
                                                  FlatButton(
                                                    child: Text(
                                                      'YES',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    onPressed: () {
                                                      discountedTotalPrice +=
                                                          discountedProductPrice *
                                                              _n;
                                                      product[i]["quantity"] +=
                                                          productAdd[
                                                              "quantity"];
                                                      product[i]
                                                          ["cogs"] = product[i]
                                                              ["quantity"] *
                                                          product[i]
                                                              ["original_cost"];
                                                      product[i][
                                                          "total_price"] = product[
                                                              i]["quantity"] *
                                                          product[i][
                                                              "discount_price"];
                                                      Navigator.of(context)
                                                          .popUntil(ModalRoute
                                                              .withName(
                                                                  '/cart'));
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          break;
                                        }
                                        continue;
                                      }
                                      if (!found) {
                                        discountedTotalPrice +=
                                            discountedProductPrice * _n;
                                        product.add(productAdd);
                                        Navigator.pop(context);
                                      }
                                    }
                                  }
                                },
                                shape: StadiumBorder(),
                              ),
                            ],
                          ),
                        )
                      ],
                    ))
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
    future.then((void value) => _closeModal(value));
  }

  void _closeModal(void value) {
    Timer(const Duration(milliseconds: 100), () {
      setState(() {
        _n = 1;
      });
    });
  }

  void deleteProduct(int index) {
    setState(() {
      discountedTotalPrice -= product[index]["total_price"];
      product.removeAt(index);
    });
  }

  void warningDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('You are about to discard your cart!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure about this?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'NO',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'YES',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: GradientAppBar(
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            product.isEmpty ? Navigator.of(context).pop() : warningDialog();
          },
        ),
        title: Text(
          'Cart',
          style: TextStyle(fontFamily: "OpenSans-Bold"),
        ),
        centerTitle: true,
        backgroundColorStart: Color(0xfffF23D45),
        backgroundColorEnd: Color(0xfffF9604E),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.camera_alt, size: 35),
            onPressed: () {
              _scanQR();
            },
          ),
        ],
      ),
      body: Column(children: [
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: product.length > 0
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return StatefulBuilder(builder: (context, state) {
                            return Column(children: [
                              Slidable(
                                delegate: SlidableDrawerDelegate(),
                                actionExtentRatio: 0.20,
                                key: Key(product[index]['product_id']),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProductInfoPage(
                                                    product[index])));
                                  },
                                  child: Column(children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CircleAvatar(
                                            radius: 45.0,
                                            child: Image(
                                              image: NetworkImage(
                                                  product[index]['image']),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0, left: 8.0),
                                                child: Text(
                                                  product[index]
                                                      ['product_name'],
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontFamily:
                                                          "OpenSans-SemiBold"),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2.0, left: 8.0),
                                                child: Text(
                                                  product[index]['brand'],
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily:
                                                          "Montserrat-Regular"),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10.0, left: 8.0),
                                                child: Text(
                                                  "\$ ${product[index]['total_price'].toStringAsFixed(2)}",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontFamily:
                                                          "Roboto-Medium",
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 12.0, right: 8.0),
                                          child: Column(
                                            children: <Widget>[
                                              IconButton(
                                                icon: Icon(
                                                  Icons.add,
                                                  size: 25.0,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    product[index]
                                                        ['quantity']++;
                                                    product[index][
                                                        'total_price'] = product[
                                                                index]
                                                            ['discount_price'] *
                                                        product[index]
                                                            ['quantity'];
                                                    product[index][
                                                        "cogs"] = product[index]
                                                            ["quantity"] *
                                                        product[index]
                                                            ["original_cost"];
                                                    discountedTotalPrice +=
                                                        product[index]
                                                            ['discount_price'];
                                                  });
                                                },
                                              ),
                                              Text(
                                                product[index]['quantity']
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily:
                                                        "Montserrat-Medium"),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.remove,
                                                  size: 25.0,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    if (product[index]
                                                            ['quantity'] !=
                                                        1) {
                                                      product[index]
                                                          ['quantity']--;
                                                      product[index]
                                                          ["cogs"] = product[
                                                                  index]
                                                              ["quantity"] *
                                                          product[index]
                                                              ["original_cost"];
                                                      product[index][
                                                          'total_price'] = product[
                                                                  index][
                                                              'discount_price'] *
                                                          product[index]
                                                              ['quantity'];
                                                      discountedTotalPrice -=
                                                          product[index][
                                                              'discount_price'];
                                                    }
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ]),
                                ),
                                secondaryActions: <Widget>[
                                  IconSlideAction(
                                    icon: Icons.delete,
                                    color: Colors.red[900],
                                    caption: "Delete",
                                    onTap: () {
                                      deleteProduct(index);
                                    },
                                  ),
                                  IconSlideAction(
                                    icon: Icons.more_horiz,
                                    color: Colors.blueAccent,
                                    caption: "More",
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductInfoPage(
                                                      product[index])));
                                    },
                                  )
                                ],
                              ),
                              Divider(
                                color: Colors.grey[800],
                              )
                            ]);
                          });
                        },
                        itemCount: product.length,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.add_shopping_cart,
                            size: 50.0,
                            color: Colors.grey[600],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Cart is empty. To add one, simply scan a product QR code at the top right button.',
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
            ],
          ),
        ),
        Container(
          child: Column(children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Color(0xfffCCCFD3),
              ),
              height: deviceSize.height / 22,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Order Total:",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontFamily: "Roboto-Medium"),
                      ),
                      Text(
                        "\$ ${discountedTotalPrice.toStringAsFixed(2)}",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.5,
                            fontFamily: "Roboto-Medium"),
                      ),
                    ]),
              ),
            ),
            Container(
              width: deviceSize.width,
              height: deviceSize.height / 12,
              color: Color(0xfff596E8B),
              child: FlatButton(
                onPressed: () {
                  if (product.isEmpty) {
                    showDialog<void>(
                      context: context,
                      barrierDismissible: false, // user must tap button!
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            'Cart is Empty!',
                            style: TextStyle(fontFamily: "Roboto-Regular"),
                          ),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                Text(
                                  'Please scan a product to add to cart.',
                                  style:
                                      TextStyle(fontFamily: "Roboto-Regular"),
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text(
                                'CLOSE',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    widget.saveCartList(product, discountedTotalPrice);
                    Navigator.pushNamed(context, '/checkout');
                  }
                },
                child: Text(
                  "CONTINUE",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: "OpenSans-Bold",
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
