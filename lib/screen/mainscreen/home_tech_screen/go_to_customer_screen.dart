// ignore_for_file: must_be_immutable, unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:car24repair/widget/auto_size_text.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoToCustomerScreen extends StatefulWidget {
  String? request_id;
  GoToCustomerScreen({required this.request_id});

  @override
  State<GoToCustomerScreen> createState() => _GoToCustomerScreenState();
}

class _GoToCustomerScreenState extends State<GoToCustomerScreen> {
  List requestList = [];
  GoogleMapController? mapController;
  PolylinePoints polylinePoints = PolylinePoints();

  String googleAPiKey = "AIzaSyB69O3HUJkJwXLuvu3jfqgW7EUOzGvVxlI";

  Set<Marker> markers = Set(); //markers for google map
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction

  LatLng? startLocation;
  LatLng? endLocation;
  Position? techLocation;
  double? distance;
  double latmap = 0.0;
  double longmap = 0.0;
  double? zoom;
  String? status;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
    techLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    return techLocation;
  }

  Future get_accept_request() async {
    var url = Uri.parse('$ipcon/request/get_accept_request.php');
    var response = await http.post(url, body: {
      "request_id": widget.request_id.toString(),
    });
    var data = json.decode(response.body);
    if (this.mounted) {
      setState(() {
        requestList = data;
        status = requestList[0]['status'];
      });
      add_maker_polyline();
    }
  }

  add_maker_polyline() async {
    startLocation = LatLng(techLocation!.latitude, techLocation!.longitude);
    endLocation = LatLng(double.parse(requestList[0]['user_lati']),
        double.parse(requestList[0]['user_longti']));
    latmap = techLocation!.latitude + double.parse(requestList[0]['user_lati']);
    latmap = latmap / 2;
    longmap =
        techLocation!.longitude + double.parse(requestList[0]['user_longti']);
    longmap = longmap / 2;
    double cal = calculateDistance(double.parse(requestList[0]['user_lati']),
        double.parse(requestList[0]['user_longti']));
    check_zoom(cal);
    if (this.mounted) {
      setState(
        () {
          mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                zoom: zoom!,
                target: LatLng(latmap, longmap),
              ),
            ),
          );
          markers.add(
            Marker(
              markerId: MarkerId(endLocation.toString()),
              position: endLocation!, //position of marker
              infoWindow: InfoWindow(
                title: 'Destination Point ',
                snippet: 'Destination Marker',
              ),
              icon: BitmapDescriptor.defaultMarker,
            ),
          );
        },
      );
    }
    await getDirections();
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
        c((lat - double.parse(techLocation!.latitude.toString())) * p) / 2 +
        c(double.parse(techLocation!.latitude.toString()) * p) *
            c(lat * p) *
            (1 -
                c((double.parse(techLocation!.longitude.toString()) - long) *
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
    setState(() {});
  }

  update_location() async {
    var url = Uri.parse('$ipcon/request/update_location_tech.php');
    var response = await http.post(url, body: {
      "request_id": widget.request_id.toString(),
      "tech_lati": techLocation!.latitude.toString(),
      "tech_longti": techLocation!.longitude.toString(),
    });
    var data = json.decode(response.body);
  }

  @override
  void initState() {
    Timer.periodic(Duration(seconds: 5), (timer) async {
      await _getLocation();
      get_accept_request();
      update_location();
      if (status == 'success') {
        timer.cancel();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: purple,
      body: requestList.isEmpty
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : Container(
              width: width,
              height: height,
              child: Container(
                width: width,
                height: height,
                child: Column(
                  children: [
                    AppbarCustom(),
                    SizedBox(
                      width: width,
                      height: height * 0.87,
                      child: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.all(30),
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildRowtop(),
                                buildWantSlide(),
                                SizedBox(height: height * 0.03),
                                buildChat(),
                                SizedBox(height: height * 0.015),
                                requestList[0]['status'] == "ready"
                                    ? Column(
                                        children: [
                                          AutoText(
                                            width: width * 0.34,
                                            text: "ลูกค้ากำลังรอคุณอยู่",
                                            fontSize: 16,
                                            color: purple,
                                            text_align: TextAlign.center,
                                            fontWeight: null,
                                          ),
                                          SizedBox(height: height * 0.02),
                                          buildMap(),
                                        ],
                                      )
                                    : requestList[0]['status'] == "arrived"
                                        ? buildArrivedStatus()
                                        : buildSuccessStatus()
                              ],
                            ),
                          ),
                          buildImg(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildRowtop() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          requestList[0]['img_request'] == ""
              ? Container(
                  width: width * 0.25,
                  height: height * 0.11,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: AutoText(
                      width: width * 0.17,
                      text: "ไม่มีรูปภาพ",
                      fontSize: 14,
                      color: purple,
                      text_align: TextAlign.center,
                      fontWeight: null,
                    ),
                  ),
                )
              : Container(
                  width: width * 0.25,
                  height: height * 0.11,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                          "$ipcon/images_request/${requestList[0]['img_request']}"),
                    ),
                  ),
                ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: width * 0.03, vertical: height * 0.005),
            width: width * 0.55,
            height: height * 0.11,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoText2(
                  width: width * 0.5,
                  text:
                      "ชื่อ : ${requestList[0]['name']} ${requestList[0]['lastname']}",
                  fontSize: 16,
                  color: purple,
                  text_align: TextAlign.left,
                  fontWeight: null,
                ),
                AutoText(
                  width: width * 0.5,
                  text: "รถ : ${requestList[0]['car_brand']}",
                  fontSize: 14,
                  color: Colors.grey,
                  text_align: TextAlign.left,
                  fontWeight: null,
                ),
                AutoText2(
                  width: width * 0.5,
                  text: "รายละเอียด : ${requestList[0]['detail']}",
                  fontSize: 14,
                  color: Colors.grey,
                  text_align: TextAlign.left,
                  fontWeight: null,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildWantSlide() {
    double width = MediaQuery.of(context).size.width;
    return requestList[0]['want_slide_car'] != "1"
        ? Text("")
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.015),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset("assets/images/Check_round_fill.png"),
                AutoText(
                  width: width * 0.26,
                  text: "ต้องการรถสไลด์",
                  fontSize: 14,
                  color: purple,
                  text_align: TextAlign.left,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          );
  }

  Widget buildChat() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: width * 0.7,
      height: height * 0.04,
      decoration: BoxDecoration(
        color: grey,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 0.4,
            blurRadius: 2,
            offset: Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: purple,
            child: Image.asset(
              "assets/images/chat_Icon.png",
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: width * 0.032),
          AutoText(
            width: width * 0.5,
            text: "สอบถามข้อมูลเพิ่มเติมผ่าน chat",
            fontSize: 16,
            color: purple,
            text_align: TextAlign.center,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }

  Widget buildMap() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.49,
      width: width * 0.9,
      decoration:
          BoxDecoration(color: grey, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: height * 0.49,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: FutureBuilder(
                  future: _getLocation(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      return GoogleMap(
                        onMapCreated: _onMapCreated,
                        myLocationEnabled: true,
                        markers: markers,
                        polylines: Set<Polyline>.of(polylines.values),
                        zoomControlsEnabled: false,
                        initialCameraPosition: CameraPosition(
                          zoom: 16,
                          target: LatLng(
                              techLocation!.latitude, techLocation!.longitude),
                        ),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                )),
          ),
        ],
      ),
    );
  }

  Widget buildArrivedStatus() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        AutoText(
          width: width * 0.5,
          text: "ถึงตัวลูกค้าแล้ว",
          fontSize: 16,
          color: purple,
          text_align: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        SizedBox(height: height * 0.03),
        AutoText(
          width: width,
          text: "ตรวจเช็ครถลูกค้า",
          fontSize: 16,
          color: grey,
          text_align: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        AutoText(
          width: width,
          text: "และทำการซ่อมหากเป็นไปได้",
          fontSize: 16,
          color: grey,
          text_align: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: height * 0.05),
          width: width * 0.5,
          height: height * 0.2,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/Vector2.png"),
            ),
          ),
        ),
        buildButton("เรียกรถสไลด์"),
        AutoText(
          width: width,
          text: "หากรถมีความเสียหายกว่าเกินจะซ่อมได้",
          fontSize: 16,
          color: grey,
          text_align: TextAlign.center,
          fontWeight: FontWeight.w400,
        ),
        SizedBox(
          height: height * 0.02,
        )
      ],
    );
  }

  Widget buildSuccessStatus() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: width * 0.8,
      height: height * 0.4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          AutoText(
            width: width * 0.5,
            text: "งานได้รับการยืนยันแล้ว",
            fontSize: 20,
            color: purple,
            text_align: TextAlign.center,
            fontWeight: FontWeight.w400,
          ),
          buildButton("กลับหน้าแรก")
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
          backgroundColor: purple,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        onPressed: () async {
          if (text == "กลับหน้าแรก") {
            Navigator.pop(context);
          }
        },
        child: Center(
          child: Text(
            "$text",
            style: GoogleFonts.mitr(
              textStyle: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImg() {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.03),
      child: CircleAvatar(
        radius: width * 0.09,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: width * 0.08,
          backgroundImage:
              NetworkImage("$ipcon/images_user/${requestList[0]['user_img']}"),
        ),
      ),
    );
  }
}
