// This page is launched when the user slides the product for more info or when they press the product on the cart page

import 'package:flutter/material.dart';

class ProductInfoPage extends StatefulWidget {
  @override
  ProductInfoPageState createState() => ProductInfoPageState();
  final Map<String, dynamic> product;
  ProductInfoPage(this.product);
}

class ProductInfoPageState extends State<ProductInfoPage> {
  @override
  void initState() {
    super.initState();
    if (widget.product["price"] == widget.product["discount_price"]) {
      discountExist = false;
    } else {
      discountExist = true;
    }
  }

  bool discountExist;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: Text('Product Information'),
        ),
        body: ListView(
          children: <Widget>[
            Container(
              padding:
                  EdgeInsets.only(top: 10, bottom: 20, right: 60, left: 60),
              color: Colors.white,
              child: Image(
                image: NetworkImage("${widget.product['image']}"),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: (MediaQuery.of(context).size.width / 4 +
                          MediaQuery.of(context).size.width / 2) -
                      10.0,
                  alignment: FractionalOffset.centerLeft,
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 30),
                  child: Text(
                    '${widget.product['product_name']}',
                    style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'MontSerrat-Regular',
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding:
                          EdgeInsets.only(left: 30.0, top: 5.0, bottom: 10.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 2.5),
                        decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(5.0)),
                        child: Text(
                          '${widget.product['brand']}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.only(right: 30.0, top: 5.0, bottom: 10.0),
                      child: discountExist
                          ? Row(
                              children: <Widget>[
                                Text(
                                  "\$${(widget.product['price']).toStringAsFixed(2)}",
                                  style: TextStyle(
                                      fontSize: 17.0,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "\$${(widget.product['discount_price']).toStringAsFixed(2)}",
                                  style: TextStyle(
                                      fontSize: 17.0, color: Colors.red),
                                ),
                              ],
                            )
                          : Text(
                              "\$${(widget.product['price']).toStringAsFixed(2)}",
                              style:
                                  TextStyle(fontSize: 17.0, color: Colors.red),
                            ),
                    ),
                  ],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: (MediaQuery.of(context).size.width / 2 +
                          MediaQuery.of(context).size.width / 2) -
                      10.0,
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 30),
                  child: Text(
                    '${widget.product['description']}',
                    style: TextStyle(fontSize: 12.0, color: Colors.grey),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
            Divider(),
            Row(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          alignment: FractionalOffset.centerLeft,
                          padding: EdgeInsets.only(right: 10, left: 30),
                          child: Text(
                            'Category:',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.orangeAccent,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              alignment: FractionalOffset.centerLeft,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.0, vertical: 2.5),
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: Text(
                                '${widget.product['category']}',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ));
  }
}
