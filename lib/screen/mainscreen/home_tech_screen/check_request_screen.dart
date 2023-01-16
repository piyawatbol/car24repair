// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:math';
import 'package:car24repair/screen/mainscreen/home_tech_screen/prepare_screen.dart';
import 'package:car24repair/widget/loading_screen.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/auto_size_text.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckReQuestScreen extends StatefulWidget {
  String? request_id;
  String? name;
  String? lastname;
  String? img_request;
  String? car_name;
  String? detail;
  String? want_slide_car;
  String? user_img;
  String? user_lati;
  String? user_longti;
  Position? techLocation;

  CheckReQuestScreen(
      {required this.request_id,
      required this.name,
      required this.lastname,
      required this.car_name,
      required this.detail,
      required this.img_request,
      required this.want_slide_car,
      required this.user_img,
      required this.user_lati,
      required this.user_longti,
      required this.techLocation});

  @override
  State<CheckReQuestScreen> createState() => _CheckReQuestScreenState();
}

class _CheckReQuestScreenState extends State<CheckReQuestScreen> {
  double? distance;
  GoogleMapController? mapController;
  final Set<Marker> markers = new Set();
  String? user_id;
  bool statusLoading = false;

  Future get_user() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
  }

  accept_request() async {
    var url = Uri.parse('$ipcon/request/accept_request.php');
    var response = await http.post(url, body: {
      "request_id": widget.request_id.toString(),
      "tech_user_id": user_id,
      "tech_lati": widget.techLocation!.latitude.toString(),
      "tech_longti": widget.techLocation!.longitude.toString(),
    });
    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      if (data == "accept success") {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return PrePareScreen(
            distance: distance,
            request_id: widget.request_id.toString(),
          );
        }), (route) => route.isFirst);
      }
    }
  }

  setMarker() {
    setState(() {
      markers.add(Marker(
        markerId: MarkerId("1"),
        position: LatLng(
          double.parse(widget.user_lati.toString()),
          double.parse(widget.user_longti.toString()),
        ),
        infoWindow: InfoWindow(
          title: 'My Custom Title ',
          snippet: 'My Custom Subtitle',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  calcuDistance() {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((widget.techLocation!.latitude -
                    double.parse(widget.user_lati.toString())) *
                p) /
            2 +
        c(double.parse(widget.user_lati.toString()) * p) *
            c(widget.techLocation!.latitude * p) *
            (1 -
                c((double.parse(widget.user_longti.toString()) -
                        widget.techLocation!.longitude) *
                    p)) /
            2;
    setState(() {
      distance = double.parse((12742 * asin(sqrt(a))).toStringAsFixed(2));
    });
  }

  @override
  void initState() {
    get_user();
    calcuDistance();
    setMarker();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: purple,
      body: Stack(
        children: [
          Container(
            width: width,
            height: height,
            child: Column(
              children: [
                AppbarCustom(),
                SizedBox(
                  width: width,
                  height: height * 0.78,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildRowtop(),
                            buildWantSlide(),
                            SizedBox(height: height * 0.03),
                            AutoText(
                              width: width * 0.4,
                              text: "ข้อมูลเพียงพอหรือไม่?",
                              fontSize: 14,
                              color: purple,
                              text_align: TextAlign.center,
                              fontWeight: FontWeight.w400,
                            ),
                            buildChat(),
                            SizedBox(height: height * 0.04),
                            buildMap()
                          ],
                        ),
                      ),
                      buildImg(),
                    ],
                  ),
                ),
                buildButton("รับงาน")
              ],
            ),
          ),
          LoadingScreen(statusLoading: statusLoading)
        ],
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
          widget.img_request == ""
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
                          "$ipcon/images_request/${widget.img_request}"),
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
                  text: "ชื่อ : ${widget.name} ${widget.lastname}",
                  fontSize: 16,
                  color: purple,
                  text_align: TextAlign.left,
                  fontWeight: null,
                ),
                AutoText(
                  width: width * 0.5,
                  text: "รถ : ${widget.car_name}",
                  fontSize: 14,
                  color: Colors.grey,
                  text_align: TextAlign.left,
                  fontWeight: null,
                ),
                AutoText2(
                  width: width * 0.5,
                  text: "รายละเอียด : ${widget.detail}",
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
    return widget.want_slide_car != "1"
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
      width: double.infinity,
      height: height * 0.4,
      decoration: BoxDecoration(
        color: grey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(8),
            height: height * 0.05,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/images/location.png",
                      width: width * 0.1,
                      height: height * 0.05,
                    ),
                    SizedBox(width: width * 0.03),
                    AutoText(
                      width: width * 0.17,
                      text: "$distance K.M",
                      fontSize: 14,
                      color: purple,
                      text_align: TextAlign.left,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: height * 0.33,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: GoogleMap(
                markers: markers,
                zoomControlsEnabled: false,
                initialCameraPosition: CameraPosition(
                  zoom: 16,
                  target: LatLng(double.parse(widget.user_lati.toString()),
                      double.parse(widget.user_longti.toString())),
                ),
              ),
            ),
          ),
        ],
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
              NetworkImage("$ipcon/images_user/${widget.user_img}"),
        ),
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
          backgroundColor: yellow,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        onPressed: () async {
          setState(() {
            statusLoading = true;
          });
          accept_request();
        },
        child: Center(
          child: Text(
            "$text",
            style: GoogleFonts.mitr(
              textStyle: TextStyle(color: Colors.black, fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}
