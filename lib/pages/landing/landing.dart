// We used the location, geocoder, gradient_appbar, places dialog library

// It contains the code for fetching of user GPS, and displaying the google maps
// for user to pick a location on the map

// It also contains the drawer for navigating to other pages of the app

import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_places_dialog/flutter_places_dialog.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:http/http.dart' as http;

class LandingPage extends StatefulWidget {
  final Function fetchStore;
  final Function fetchUserID;
  final String email;
  final String fullName;
  LandingPage(this.fetchStore, this.fetchUserID, this.email, this.fullName);
  @override
  State<StatefulWidget> createState() {
    return LandingPageState();
  }
}

class LandingPageState extends State<LandingPage> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    initLocator();

    FlutterPlacesDialog.setGoogleApiKey(
        "insert_api_key_here");
  }

  initLocator() async {
    Map<String, double> currentLocation = await getCurrentLocation();
    if (currentLocation != null) {
      await _fetchLocation(currentLocation['latitude'].toString(),
          currentLocation['longitude'].toString());
    } else {
      await _fetchLocation();
    }
  }

  String displayplacename = "";
  List _locationList = [];
  String currentLong;
  String currentLat;

  Future<Map<String, double>> getCurrentLocation() async {
    Map<String, double> currentLocation;
    var location = Location();

    try {
      currentLocation = await location.getLocation();
      currentLat = currentLocation["latitude"].toString();
      currentLong = currentLocation["longitude"].toString();
    } catch (e) {
      currentLocation = null;
    }
    //Format : lat,lon
    return currentLocation;
  }

  showPlacePicker() async {
    PlaceDetails place;
    try {
      place = await FlutterPlacesDialog.getPlacesDialog();
      setState(() {
        displayplacename = place.address;
        currentLat = place.location.latitude.toString();
        currentLong = place.location.longitude.toString();
      });

      _fetchLocation(currentLat, currentLong);
    } on PlatformException {
      print("exit");
    }

    if (!mounted) return;
  }

  Future<Null> _fetchLocation([String latitude, String longitude]) async {
    refreshKey.currentState?.show(atTop: true);

    String latitudeString;
    String longitudeString;
    var first;

    if (latitude == null || longitude == null) {
      latitudeString = "1.284540";
      longitudeString = "103.852028";
      currentLat = "1.284540";
      currentLong = "103.852028";
      first = "Raffles Place, Singapore";
    } else {
      final coordinates =
          Coordinates(double.parse(latitude), double.parse(longitude));
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      first = addresses.first.addressLine;

      latitudeString = latitude.toString();
      longitudeString = longitude.toString();
    }

    final response = await http.post(
        "https://mp02.projectsbit.org/KillQ/fetch_stores.php",
        body: {"latitude": latitudeString, "longitude": longitudeString});

    List locationList = json.decode(response.body);
    Map<String, dynamic> locationResult = locationList[0];
    if (locationResult["result"] == "0") {
      setState(() {
        _locationList = [];
        displayplacename = first;
      });
      return null;
    } else {
      setState(() {
        _locationList = locationList;
        displayplacename = first;
      });
      return null;
    }
  }

  Future<Null> _refreshLocation() async {
    imageCache.clear();
    final response = await http.post(
        "https://mp02.projectsbit.org/KillQ/fetch_stores.php",
        body: {"latitude": currentLat, "longitude": currentLong});
    List locationList = json.decode(response.body);
    Map<String, dynamic> locationResult = locationList[0];
    if (locationResult["result"] == "0") {
      setState(() {
        _locationList = [];
      });
      return null;
    } else {
      setState(() {
        _locationList = locationList;
      });
      return null;
    }
  }

  Widget _buildSideDrawer(BuildContext context, fetchUserID, email, fullName) {
    return Drawer(
      elevation: 10,
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountEmail: Text(email),
            accountName: Text(fullName),
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(60)),
              child: CircleAvatar(
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey,
                ),
                backgroundColor: Colors.white,
              ),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/extras/drawer_background.jpg"),
                  fit: BoxFit.fill),
            ),
          ),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text(
              'Payment Method',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/addpayment');
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(
              'Order History',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/order_history');
            },
          ),
          ListTile(
            leading: Icon(Icons.question_answer),
            title: Text(
              'Tutorial',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/intro_slides');
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(
              'Logout',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              fetchUserID(null, 0, '0', '0');
              Navigator.pushNamed(context, '/auth');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: _buildSideDrawer(
          context, widget.fetchUserID, widget.email, widget.fullName),
      appBar: GradientAppBar(
        elevation: 0.0,
        title: Text(
          'Find Nearby Stores',
          style: TextStyle(
            fontFamily: "OpenSans-Bold",
          ),
        ),
        centerTitle: true,
        backgroundColorStart: Color(0xfffF23D45),
        backgroundColorEnd: Color(0xfffF7544B),
      ),
      body: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xfffF7544B), Color(0xfffFE7353)]),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.elliptical(200, 20),
                  bottomRight: Radius.elliptical(200, 20)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 3.0,
                ),
              ],
            ),
            padding: EdgeInsets.only(
                top: 15.0, left: 10.0, right: 10.0, bottom: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(bottom: 10.0, left: 5.0),
                  child: Text(
                    "Current Location:",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontFamily: "Roboto-Medium",
                        color: Colors.white),
                  ),
                ),
                GestureDetector(
                  onTap: showPlacePicker,
                  child: Container(
                    width: deviceWidth,
                    padding: EdgeInsets.all(10.0),
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.all(
                        const Radius.circular(12.0),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.search),
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.only(right: 13.0),
                            child: Text(
                              displayplacename,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.0,
                                fontFamily: 'Roboto',
                                color: Color(0xFF212121),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              key: refreshKey,
              child: _locationList.length > 0
                  ? ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        String timeDisplay;
                        String distanceDisplay;
                        int decimalPlace;
                        String distanceMeasurement;
                        if (_locationList[index]["starting_hour"] ==
                            _locationList[index]["ending_hour"]) {
                          timeDisplay = "24 HOURS";
                        } else {
                          timeDisplay =
                              "${DateFormat.jm().format(DateFormat("Hms", "en_US").parse(_locationList[index]["starting_hour"]))}";
                          timeDisplay += " - ";
                          timeDisplay +=
                              "${DateFormat.jm().format(DateFormat("Hms", "en_US").parse(_locationList[index]["ending_hour"]))}";
                        }
                        if (num.parse(_locationList[index]["distance"]) < 1) {
                          distanceDisplay =
                              (num.parse(_locationList[index]["distance"]) *
                                      1000)
                                  .toString();
                          decimalPlace = 0;
                          distanceMeasurement = "m";
                        } else {
                          distanceDisplay = _locationList[index]["distance"];
                          decimalPlace = 2;
                          distanceMeasurement = "km";
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Card(
                            color: Color(0xfffEFF2F5),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                            ),
                            elevation: 5,
                            child: InkWell(
                              onTap: () {
                                widget.fetchStore(
                                  _locationList[index]["merchant_id"],
                                  _locationList[index]["merchant_name"],
                                  _locationList[index]["image"],
                                );
                                Navigator.pushNamed(context, '/cart');
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.horizontal(
                                          left: Radius.circular(15.0)),
                                    ),
                                    padding: const EdgeInsets.only(
                                        top: 10.0,
                                        left: 10.0,
                                        bottom: 20.0,
                                        right: 10.0),
                                    child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            _locationList[index]["image"]),
                                        radius:
                                            MediaQuery.of(context).size.width *
                                                0.11),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Container(
                                      width: 200,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            _locationList[index]
                                                ["merchant_name"],
                                            style: TextStyle(
                                                fontFamily: "OpenSans-Bold"),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 6.0),
                                            child: Text(
                                              "• ${(num.parse(distanceDisplay)).toStringAsFixed(decimalPlace)} $distanceMeasurement",
                                              style: TextStyle(
                                                fontFamily: "OpenSans-light",
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0),
                                            child: Text(
                                              _locationList[index]["address"],
                                              style: TextStyle(
                                                  fontFamily:
                                                      "OpenSans-Regular",
                                                  fontSize: 12),
                                            ),
                                          ),
                                          Text(
                                            "OPEN $timeDisplay",
                                            style: TextStyle(
                                              fontFamily: "Roboto-black",
                                              fontSize: 13,
                                              color: Color(0xfff596E8B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Icon(
                                      Icons.keyboard_arrow_right,
                                      size: 25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: _locationList.length,
                    )
                  : ListView(
                      children: <Widget>[
                        SizedBox(
                          height: 100,
                        ),
                        Icon(
                          Icons.store,
                          size: 50.0,
                          color: Colors.grey[600],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'There are no open stores nearby currently. Please try again later.',
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Color(0xfff596E8B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
              onRefresh: _refreshLocation,
            ),
          ),
        ],
      ),
    );
  }
}
