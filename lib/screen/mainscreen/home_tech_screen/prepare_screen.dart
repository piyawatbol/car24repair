// ignore_for_file: must_be_immutable
import 'dart:convert';
import 'package:car24repair/screen/mainscreen/home_tech_screen/go_to_customer_screen.dart';
import 'package:car24repair/widget/loading_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/auto_size_text.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:flutter/material.dart';

class PrePareScreen extends StatefulWidget {
  String? request_id;
  double? distance;
  PrePareScreen({required this.distance, required this.request_id});
  @override
  State<PrePareScreen> createState() => _PrePareScreenState();
}

class _PrePareScreenState extends State<PrePareScreen> {
  List requestList = [];
  bool statusLoading = false;

  GoogleMapController? mapController;
  final Set<Marker> markers = new Set();
  double? distance;

  Future get_accept_request() async {
    var url = Uri.parse('$ipcon/request/get_accept_request.php');
    var response = await http.post(url, body: {
      "request_id": widget.request_id.toString(),
    });
    var data = json.decode(response.body);
    setState(() {
      requestList = data;
      markers.add(Marker(
        markerId: MarkerId("1"),
        position: requestList[0]['user_lati'] == null ||
                requestList[0]['user_lati'] == ""
            ? LatLng(0, 0)
            : LatLng(
                double.parse(requestList[0]['user_lati']),
                double.parse(requestList[0]['user_longti']),
              ),
        infoWindow: InfoWindow(
          title: 'My Custom Title ',
          snippet: 'My Custom Subtitle',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  Future ready_request() async {
    var url = Uri.parse('$ipcon/request/ready_request.php');
    var response = await http.post(url, body: {
      "request_id": widget.request_id.toString(),
    });
    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
      if (data == "ready success") {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return GoToCustomerScreen(
            request_id: '${requestList[0]['request_id']}',
          );
        }), (route) => route.isFirst);
      }
    }
  }

  @override
  void initState() {
    get_accept_request();
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
          : Stack(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  buildRowtop(),
                                  buildWantSlide(),
                                  SizedBox(height: height * 0.03),
                                  buildChat(),
                                  SizedBox(height: height * 0.05),
                                  buildText(),
                                  buildMap()
                                ],
                              ),
                            ),
                            buildImg(),
                          ],
                        ),
                      ),
                      buildButton("พร้อม")
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

  Widget buildText() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AutoText(
              width: width * 0.31,
              text: "คุณยังอยู่ในสถานะ",
              fontSize: 16,
              color: purple,
              text_align: TextAlign.center,
              fontWeight: FontWeight.w300,
            ),
            AutoText(
              width: width * 0.23,
              text: "เตรียมพร้อม",
              fontSize: 16,
              color: purple,
              text_align: TextAlign.center,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
        AutoText(
          width: width * 0.6,
          text: "เราจะแจ้งให้ลูกค้าทราบเมื่อคุณพร้อม",
          fontSize: 16,
          color: purple,
          text_align: TextAlign.center,
          fontWeight: FontWeight.w300,
        ),
        SizedBox(height: height * 0.04),
        AutoText(
          width: width * 0.6,
          text: "เตรียมอุปกรณ์ที่จำเป็นต่อการซ่อมรถ",
          fontSize: 16,
          color: grey2,
          text_align: TextAlign.center,
          fontWeight: FontWeight.w300,
        ),
        AutoText(
          width: width * 0.52,
          text: "โดยวิเคราะห์อาการที่ลูกค้าส่งมา",
          fontSize: 16,
          color: grey2,
          text_align: TextAlign.center,
          fontWeight: FontWeight.w300,
        ),
        SizedBox(height: height * 0.04),
      ],
    );
  }

  Widget buildMap() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.22,
      width: width * 0.9,
      decoration:
          BoxDecoration(color: grey, borderRadius: BorderRadius.circular(15)),
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
                      text: "${widget.distance} K.M",
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
            height: height * 0.15,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: GoogleMap(
                markers: markers,
                zoomControlsEnabled: false,
                initialCameraPosition: CameraPosition(
                  zoom: 15,
                  target: LatLng(
                      double.parse(requestList[0]['user_lati'].toString()),
                      double.parse(requestList[0]['user_longti'].toString())),
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
              NetworkImage("$ipcon/images_user/${requestList[0]['user_img']}"),
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
          ready_request();
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
