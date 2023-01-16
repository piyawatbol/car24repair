// ignore_for_file: must_be_immutable, unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:car24repair/screen/mainscreen/home_screen/home_screen.dart';
import 'package:car24repair/widget/loading_screen.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/auto_size_text.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatusCallScreen extends StatefulWidget {
  String? request_id;
  StatusCallScreen({required this.request_id});

  @override
  State<StatusCallScreen> createState() => _StatusCallScreenState();
}

class _StatusCallScreenState extends State<StatusCallScreen> {
  TextEditingController detail = TextEditingController();
  String? user_id;
  List requestList = [];
  GoogleMapController? mapController;
  PolylinePoints polylinePoints = PolylinePoints();
  double? star;

  String googleAPiKey = "AIzaSyB69O3HUJkJwXLuvu3jfqgW7EUOzGvVxlI";

  Set<Marker> markers = Set(); //markers for google map
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction

  LatLng? startLocation;
  LatLng? endLocation;
  Position? userLocation;
  double? distance;
  double latmap = 0.0;
  double longmap = 0.0;
  double? zoom;
  String? status;
  bool statusLoading = false;


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  get_user_id() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
  }



  Future<Position?> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    userLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    return userLocation;
  }

  get_request() async {
    var url = Uri.parse('$ipcon/request/get_request_user.php');
    var response = await http.post(url, body: {
      "user_id": user_id,
    });
    var data = await json.decode(response.body);
    if (this.mounted) {
      setState(() {
        requestList = data;
      });
    }
    if (requestList[0]['status'] == "ready") {
      await _getLocation();
      add_mark_polyline();
    }
  }

  add_mark_polyline() {
    if (this.mounted) {
      setState(() {
        startLocation = LatLng(userLocation!.latitude, userLocation!.longitude);
        endLocation = LatLng(double.parse(requestList[0]['tech_lati']),
            double.parse(requestList[0]['tech_longti']));
        latmap =
            userLocation!.latitude + double.parse(requestList[0]['tech_lati']);
        latmap = latmap / 2;

        longmap = userLocation!.longitude +
            double.parse(requestList[0]['tech_longti']);
        longmap = longmap / 2;

        double cal = calculateDistance(
            double.parse(requestList[0]['tech_lati']),
            double.parse(requestList[0]['tech_longti']));
        if (cal <= 0.1) {
          update_status();
        }
        check_zoom(cal);
        mapController!.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(zoom: zoom!, target: LatLng(latmap, longmap))));
        markers.add(Marker(
          markerId: MarkerId("1"),
          position: endLocation!, //position of marker
          infoWindow: InfoWindow(
            title: 'Destination Point ',
            snippet: 'Destination Marker',
          ),
          icon: BitmapDescriptor.defaultMarker,
        ));
      });
      getDirections();
    }
  }

  check_zoom(double cal) {
    if (cal <= 0.3) {
      return zoom = 17;
    } else if (cal <= 1) {
      return zoom = 16;
    } else if (cal <= 2) {
      return zoom = 15;
    } else if (cal <= 3) {
      return zoom = 14;
    } else if (cal <= 4) {
      return zoom = 13;
    } else if (cal <= 5) {
      return zoom = 12;
    } else if (cal <= 6) {
      return zoom = 11;
    } else if (cal <= 7) {
      return zoom = 10;
    } else if (cal <= 8) {
      return zoom = 9;
    } else if (cal <= 9) {
      return zoom = 8;
    }
  }

  calculateDistance(double lat, double long) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat - double.parse(userLocation!.latitude.toString())) * p) / 2 +
        c(double.parse(userLocation!.latitude.toString()) * p) *
            c(lat * p) *
            (1 -
                c((double.parse(userLocation!.longitude.toString()) - long) *
                    p)) /
            2;

    distance = double.parse((12742 * asin(sqrt(a))).toStringAsFixed(2));
    return distance;
  }

  getDirections() async {
    List<LatLng> polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(startLocation!.latitude, startLocation!.longitude),
      PointLatLng(endLocation!.latitude, endLocation!.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.green,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
  }

  update_status() async {
    var url = Uri.parse('$ipcon/request/update_status.php');
    var response = await http.post(url, body: {
      "request_id": requestList[0]['request_id'].toString(),
      "status": "arrived",
    });
    if (response.statusCode == 200) {
      setState(() {
        status = "arrived";
      });
    }
  }

  success() async {
    var url = Uri.parse('$ipcon/request/update_status.php');
    var response = await http.post(url, body: {
      "request_id": requestList[0]['request_id'].toString(),
      "status": "success",
    });
    setState(() {
      statusLoading = false;
      requestList[0]['status'] = "success";
    });
  }

  add_star() async {
    var url = Uri.parse('$ipcon/request/add_star.php');
    var response = await http.post(url, body: {
      "request_id": requestList[0]['request_id'].toString(),
      "star": star.toString(),
      "detail": detail.text,
    });
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return HomeScreen();
      }), (route) => false);
    }
  }

  @override
  void initState() {
    _getLocation();
    get_user_id();
    Timer.periodic(Duration(seconds: 5), (timer) async {
      get_request();
      if (status == "arrived") {
        timer.cancel();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        body: requestList.isEmpty
            ? Center(child: CircularProgressIndicator(color: purple))
            : Stack(
                children: [
                  Container(
                    width: width,
                    height: height,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          AppbarCustom(),
                          buildHalfTop(),
                          Container(
                              width: width,
                              height: height * 0.42,
                              child: requestList[0]['status'] == "accept"
                                  ? buildStatus1()
                                  : requestList[0]['status'] == "ready"
                                      ? buildStatus2()
                                      : requestList[0]['status'] == "arrived"
                                          ? buildStatus3()
                                          : requestList[0]['status'] ==
                                                  "success"
                                              ? buildStatus4()
                                              : Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                )),
                          buildMessage()
                        ],
                      ),
                    ),
                  ),
                  LoadingScreen(statusLoading: statusLoading)
                ],
              ),
      ),
    );
  }

  Widget buildHalfTop() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height * 0.36,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0.1,
            blurRadius: 5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          buildImage(),
          AutoText(
            width: width * 0.8,
            text: "${requestList[0]['name']} ${requestList[0]['lastname']}",
            fontSize: 22,
            color: purple,
            text_align: TextAlign.center,
            fontWeight: FontWeight.w300,
          ),
          buildStatus(),
          requestList[0]['status'] == "accept"
              ? AutoText(
                  width: width * 0.35,
                  text: "ช่างกำลังเตรียมตัว",
                  fontSize: 16,
                  color: purple,
                  text_align: TextAlign.center,
                  fontWeight: FontWeight.w300,
                )
              : requestList[0]['status'] == "ready"
                  ? AutoText(
                      width: width * 0.5,
                      text: "ช่างกำลังเดินทางไปหาคุณ",
                      fontSize: 16,
                      color: purple,
                      text_align: TextAlign.center,
                      fontWeight: FontWeight.w300,
                    )
                  : requestList[0]['status'] == "arrived"
                      ? AutoText(
                          width: width * 0.5,
                          text: "ช่างกำลังซ่อมรถคุณ",
                          fontSize: 16,
                          color: purple,
                          text_align: TextAlign.center,
                          fontWeight: FontWeight.w300,
                        )
                      : AutoText(
                          width: width * 0.5,
                          text: "เสร็จแล้ว",
                          fontSize: 16,
                          color: purple,
                          text_align: TextAlign.center,
                          fontWeight: FontWeight.w300,
                        )
        ],
      ),
    );
  }

  Widget buildImage() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.02),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 0.1,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: CircleAvatar(
            radius: width * 0.14,
            backgroundColor: Colors.white,
            child: requestList[0]['user_img'] == ""
                ? CircleAvatar(
                    radius: width * 0.13,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage(
                      "assets/images/profile.jpg",
                    ),
                  )
                : CircleAvatar(
                    radius: width * 0.13,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(
                      "$ipcon/images_user/${requestList[0]['user_img']}",
                    ),
                  )),
      ),
    );
  }

  Widget buildStatus() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: width * 0.12,
            height: height * 0.06,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: purple,
            ),
            child: Image.asset("assets/images/Arhive_load_fill.png"),
          ),
          Container(
            width: width * 0.08,
            height: height * 0.01,
            color: requestList[0]['status'] != "accept" ? purple : grey,
          ),
          Container(
            width: width * 0.12,
            height: height * 0.06,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: requestList[0]['status'] != "accept" ? purple : grey,
            ),
            child: Image.asset(
              "assets/images/Vector (1).png",
              color:
                  requestList[0]['status'] == "accept" ? purple : Colors.white,
            ),
          ),
          Container(
            width: width * 0.08,
            height: height * 0.01,
            color: requestList[0]['status'] == "arrived"
                ? purple
                : requestList[0]['status'] == "success"
                    ? purple
                    : grey,
          ),
          Container(
            width: width * 0.12,
            height: height * 0.06,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: requestList[0]['status'] == "arrived"
                  ? purple
                  : requestList[0]['status'] == "success"
                      ? purple
                      : grey,
            ),
            child: Image.asset(
              "assets/images/Vector (2).png",
              color: requestList[0]['status'] == "arrived"
                  ? Colors.white
                  : requestList[0]['status'] == "success"
                      ? Colors.white
                      : purple,
            ),
          ),
          Container(
            width: width * 0.08,
            height: height * 0.01,
            color: requestList[0]['status'] != "success" ? grey : purple,
          ),
          Container(
            width: width * 0.12,
            height: height * 0.06,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: requestList[0]['status'] != "success" ? grey : purple,
            ),
            child: Image.asset(
              "assets/images/happy.png",
              color:
                  requestList[0]['status'] != "success" ? purple : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMessage() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              width: width * 0.7,
              height: height * 0.05,
              decoration: BoxDecoration(
                border: Border.all(
                  color: purple,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                  child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                    child: Text(
                      "ส่งข้อความหาช่าง",
                      style: GoogleFonts.mitr(
                        textStyle: TextStyle(
                            color: purple,
                            fontSize: 16,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                  ),
                ],
              ))),
          SizedBox(width: width * 0.01),
          Container(
            width: width * 0.1,
            height: height * 0.05,
            decoration: BoxDecoration(
              color: purple,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Image.asset("assets/images/chat_Icon.png"),
          ),
        ],
      ),
    );
  }

  Widget buildStatus1() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: height * 0.03),
          child: AutoText(
            width: width * 0.8,
            text: "ระหว่างรอ",
            fontSize: 18,
            color: purple,
            text_align: TextAlign.center,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: height * 0.02),
        AutoText(
          width: width * 0.51,
          text: "ให้ขับรถหรือเคลื่อนย้ายรถเข้าจอด",
          fontSize: 14,
          color: purple,
          text_align: TextAlign.center,
          fontWeight: FontWeight.w300,
        ),
        AutoText(
          width: width * 0.78,
          text: "ข้างทางหรือในจุดที่ปลอดภัยที่สุด เพื่อความปลอดภัย",
          fontSize: 14,
          color: purple,
          text_align: TextAlign.center,
          fontWeight: FontWeight.w300,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: height * 0.03),
          child: AutoText(
            width: width * 0.5,
            text: "ดับเครื่องยนต์ และเปิดไฟฉุกเฉิน",
            fontSize: 14,
            color: purple,
            text_align: TextAlign.center,
            fontWeight: FontWeight.w300,
          ),
        ),
        AutoText(
          width: width * 0.6,
          text: "ตั้งป้ายฉุกเฉิน(ถ้ามี) ในเลนที่รถจอดอยู่",
          fontSize: 14,
          color: purple,
          text_align: TextAlign.center,
          fontWeight: FontWeight.w300,
        ),
        AutoText(
          width: width * 0.85,
          text: "โดยวางไว้ด้านหลังรถระยะห่างจากรถอย่างน้อย 50 เมตร",
          fontSize: 14,
          color: purple,
          text_align: TextAlign.center,
          fontWeight: FontWeight.w300,
        ),
        AutoText(
          width: width * 0.84,
          text: "เพื่อเตือนรถคันที่ขับใกล้เข้ามาสังเกตุเห็นรถคุณได้ง่ายขึ้น",
          fontSize: 14,
          color: purple,
          text_align: TextAlign.center,
          fontWeight: FontWeight.w300,
        ),
      ],
    );
  }

  Widget buildStatus2() {
    return Container(
        child: FutureBuilder(
      future: _getLocation(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return GoogleMap(
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            markers: markers,
            polylines: Set<Polyline>.of(polylines.values),
            zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(
              zoom: 16,
              target: LatLng(latmap, longmap),
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    ));
  }

  Widget buildStatus3() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height * 0.4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoText(
            width: width * 0.8,
            text: "หากซ่อมเสร็จแล้ว",
            fontSize: 22,
            color: purple,
            text_align: TextAlign.center,
            fontWeight: FontWeight.w300,
          ),
          buildButton("เสร็จสิ้น")
        ],
      ),
    );
  }

  Widget buildStatus4() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height * 0.5,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: height * 0.04),
            child: RatingBar.builder(
              initialRating: 3,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: purple,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  star = rating;
                });
                print(star);
              },
            ),
          ),
          Container(
            width: width * 0.8,
            height: height * 0.1,
            child: TextField(
              controller: detail,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xffD9D9D9),
                contentPadding: EdgeInsets.all(20),
                hintText: "ข้อเสนอแนะเพิ่มเติม",
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xffD9D9D9)),
                  borderRadius: BorderRadius.circular(15),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xffD9D9D9)),
                  borderRadius: BorderRadius.circular(15),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xffD9D9D9)),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          buildButton("ส่ง")
        ],
      ),
    );
  }

  Widget buildButton(String? text) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: width * 0.7,
      height: height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: text == "ส่ง" ? purple : yellow,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        onPressed: () async {
          if (text == "ส่ง") {
            setState(() {
              statusLoading = true;
            });
            add_star();
          } else {
            setState(() {
              statusLoading = true;
            });
            success();
          }
        },
        child: Center(
          child: Text(
            "$text",
            style: GoogleFonts.mitr(
              textStyle: TextStyle(
                  color: text == "ส่ง" ? Colors.white : Colors.black,
                  fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}
