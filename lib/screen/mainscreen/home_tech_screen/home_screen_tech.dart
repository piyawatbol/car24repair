// ignore_for_file: unused_field
import 'dart:convert';
import 'dart:math';
import 'package:car24repair/screen/mainscreen/home_tech_screen/apm_screen.dart';
import 'package:car24repair/screen/mainscreen/home_tech_screen/check_request_screen.dart';
import 'package:car24repair/widget/toast_custom.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/widget/auto_size_text.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:car24repair/widget/drawer/menudrawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';

class HomeScreenTech extends StatefulWidget {
  HomeScreenTech({Key? key}) : super(key: key);

  @override
  State<HomeScreenTech> createState() => _HomeScreenTechState();
}

class _HomeScreenTechState extends State<HomeScreenTech> {
  List userList = [];
  List requestList = [];
  List tech_accept_requset_List = [];
  String? user_id;
  String? _user_id;
  String? car_id;
  Position? techLocation;
  double? distance;
  List distanceList = [];
  String? radius;
  TextEditingController radius_text = TextEditingController();

  Future get_user() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    var url = Uri.parse('$ipcon/user/get_user.php');
    var response = await http.post(url, body: {
      "user_id": user_id.toString(),
    });
    var data = json.decode(response.body);
    setState(() {
      userList = data;
    });
  }

  Future get_request() async {
    var url = Uri.parse('$ipcon/request/get_request.php');
    var response = await http.get(url);
    var data = json.decode(response.body);
    setState(() {
      requestList = data;
    });
  }

  get_radius() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      radius = preferences.getString('radius');
    });
    print(radius);
    if (radius == null) {
      buildPopup();
    }
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

  calculateDistance(index, double lat, double long) {
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
    if (distanceList.length >= requestList.length) {
      distanceList[index] = distance;
    } else {
      distanceList.add(distance);
    }
    return distance;
  }

  @override
  void initState() {
    _getLocation();
    get_radius();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: width,
        height: height,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: height * 0.27,
                    color: purple,
                  ),
                  buildHalfButtom()
                ],
              ),
            ),
            buildHelloBox(),
            buildAppbar()
          ],
        ),
      ),
    );
  }

  Widget buildHalfButtom() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: double.infinity,
      height: height * 0.73,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.07),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoText(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: null,
                      text: 'ตามหาลูกค้าของคุณ',
                      text_align: TextAlign.left,
                      width: width * 0.52,
                    ),
                    TextButton(
                        onPressed: () {
                          buildPopup();
                        },
                        child: Text("ปรับระยะทาง"))
                  ],
                )),
            Container(
              width: width,
              height: height * 0.39,
              child: buildListRequest(),
            ),
            buildButtonButtom()
          ],
        ),
      ),
    );
  }

  Widget buildListRequest() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return FutureBuilder(
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return FutureBuilder(
          future: get_request(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            return techLocation == null
                ? Center(
                    child: CircularProgressIndicator(color: purple),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: height * 0.001),
                    itemCount: requestList.length,
                    itemBuilder: (BuildContext context, int index) {
                      calculateDistance(
                          index,
                          double.parse(
                              requestList[index]['user_lati'].toString()),
                          double.parse(
                              requestList[index]['user_longti'].toString()));
                      return radius == null
                          ? Container()
                          : distanceList[index] > double.parse(radius!)
                              ? Container()
                              : Stack(
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: height * 0.01),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(builder:
                                                  (BuildContext context) {
                                            return CheckReQuestScreen(
                                              name:
                                                  '${requestList[index]['name']}',
                                              lastname:
                                                  '${requestList[index]['lastname']}',
                                              car_name:
                                                  '${requestList[index]['car_brand']}',
                                              detail:
                                                  '${requestList[index]['detail']}',
                                              img_request:
                                                  '${requestList[index]['img_request']}',
                                              want_slide_car:
                                                  '${requestList[index]['want_slide_car']}',
                                              user_img:
                                                  '${requestList[index]['user_img']}',
                                              user_lati:
                                                  '${requestList[index]['user_lati']}',
                                              user_longti:
                                                  '${requestList[index]['user_longti']}',
                                              techLocation: techLocation,
                                              request_id:
                                                  '${requestList[index]['request_id']}',
                                            );
                                          }));
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: height * 0.012,
                                              horizontal: width * 0.05),
                                          width: double.infinity,
                                          height: height * 0.15,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                spreadRadius: 0.4,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              requestList[index]
                                                          ['img_request'] ==
                                                      ""
                                                  ? Container(
                                                      margin: EdgeInsets.all(5),
                                                      width: width * 0.3,
                                                      height: double.infinity,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                      ),
                                                      child: Center(
                                                        child: AutoText(
                                                          width: width * 0.17,
                                                          text: "ไม่มีรูปภาพ",
                                                          fontSize: 14,
                                                          color: purple,
                                                          text_align:
                                                              TextAlign.center,
                                                          fontWeight: null,
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      margin: EdgeInsets.all(5),
                                                      width: width * 0.3,
                                                      height: double.infinity,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: NetworkImage(
                                                              "$ipcon/images_request/${requestList[index]['img_request']}"),
                                                        ),
                                                      ),
                                                    ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: width * 0.02,
                                                    vertical: height * 0.01),
                                                width: width * 0.5,
                                                height: double.infinity,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    AutoText2(
                                                      width: width * 0.5,
                                                      text:
                                                          "ชื่อ : ${requestList[index]['name']} ${requestList[index]['lastname']}",
                                                      fontSize: 14,
                                                      color: purple,
                                                      text_align:
                                                          TextAlign.left,
                                                      fontWeight: null,
                                                    ),
                                                    AutoText(
                                                      width: width * 0.5,
                                                      text:
                                                          "รถ : ${requestList[index]['car_brand']}",
                                                      fontSize: 14,
                                                      color: Colors.grey,
                                                      text_align:
                                                          TextAlign.left,
                                                      fontWeight: null,
                                                    ),
                                                    AutoText2(
                                                      width: width * 0.5,
                                                      text:
                                                          "รายละเอียด : ${requestList[index]['detail']}",
                                                      fontSize: 14,
                                                      color: Colors.grey,
                                                      text_align:
                                                          TextAlign.left,
                                                      fontWeight: null,
                                                    ),
                                                    distanceList == []
                                                        ? Text("...")
                                                        : AutoText(
                                                            width: width * 0.5,
                                                            text:
                                                                "รถ : ${distanceList[index]}",
                                                            fontSize: 14,
                                                            color: Colors.grey,
                                                            text_align:
                                                                TextAlign.left,
                                                            fontWeight: null,
                                                          ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: width * 0.07,
                                                height: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: purple,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(15),
                                                    bottomRight:
                                                        Radius.circular(15),
                                                  ),
                                                ),
                                                child: Image.asset(
                                                    "assets/images/Expand_right_double.png"),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.03),
                                      child: CircleAvatar(
                                        radius: width * 0.08,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: width * 0.07,
                                          backgroundImage: NetworkImage(
                                              "$ipcon/images_user/${requestList[index]['user_img']}"),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                    },
                  );
          },
        );
      },
    );
  }

  Widget buildAppbar() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.06, vertical: height * 0.01),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: width * 0.35,
              child: AutoSizeText(
                "Car24Repair",
                maxLines: 1,
                minFontSize: 1,
                style: GoogleFonts.mitr(
                  textStyle: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {
                showTopModalSheet(context, MenuDrawer());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHelloBox() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return FutureBuilder(
      future: get_user(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: height * 0.23),
                  width: width * 0.87,
                  height: height * 0.08,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: Row(
                        children: [
                          userList.isEmpty
                              ? Text("...")
                              : SizedBox(
                                  width: userList[0]['name']!.length <= 12
                                      ? width * 0.5
                                      : width * 0.75,
                                  child: AutoSizeText(
                                    "สวัสดี ${userList[0]['name']} ${userList[0]['lastname']}",
                                    maxLines: 1,
                                    style: GoogleFonts.mitr(
                                      textStyle: TextStyle(
                                          color: Colors.grey, fontSize: 20),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget buildButtonButtom() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: width * 0.05, vertical: height * 0.022),
      width: double.infinity,
      height: height * 0.18,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 0.4,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return ApmScreen();
          }));
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: height * 0.007),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      "assets/images/Desk_fill.png",
                      width: width * 0.19,
                      height: height * 0.1,
                      color: Color(0xff5755B7),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.01),
                      child: SizedBox(
                        width: width * 0.18,
                        child: AutoSizeText(
                          "นัดช่าง",
                          minFontSize: 1,
                          maxLines: 1,
                          style: GoogleFonts.mitr(
                            textStyle: TextStyle(
                                color: Color(0xff5755B7), fontSize: 24),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: width * 0.29,
                        child: AutoSizeText(
                          "กำหนดการ",
                          minFontSize: 1,
                          maxLines: 1,
                          style: GoogleFonts.mitr(
                            textStyle: TextStyle(
                                color: Color(0xff5755B7), fontSize: 24),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width * 0.25,
                        child: AutoSizeText(
                          "เปลี่ยนแบตเตอร์รี่",
                          minFontSize: 1,
                          maxLines: 1,
                          style: GoogleFonts.mitr(
                            textStyle: TextStyle(
                                color: Color(0xff5755B7), fontSize: 12),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width * 0.32,
                        child: AutoSizeText(
                          "01-02-22 12:12pm",
                          textAlign: TextAlign.end,
                          minFontSize: 1,
                          maxLines: 1,
                          style: GoogleFonts.mitr(
                            textStyle:
                                TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width * 0.25,
                        child: AutoSizeText(
                          "เปลี่ยนแบตเตอร์รี่",
                          minFontSize: 1,
                          maxLines: 1,
                          style: GoogleFonts.mitr(
                            textStyle: TextStyle(
                                color: Color(0xff5755B7), fontSize: 12),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width * 0.32,
                        child: AutoSizeText(
                          "01-02-22 12:12pm",
                          textAlign: TextAlign.end,
                          minFontSize: 1,
                          maxLines: 1,
                          style: GoogleFonts.mitr(
                            textStyle:
                                TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildPopup() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("กรอกระยะทางที่คุณต้องการรับลูกค้า"),
        content: TextField(
          controller: radius_text,
          decoration: InputDecoration(hintText: "กรอกระยะทางที่คุณต้องการ"),
        ),
        actions: [
          TextButton(
              onPressed: () {
                setState(() {
                  if (radius_text.text != "") {
                    preferences.setString('radius', radius_text.text);
                    radius = preferences.getString('radius');
                    Navigator.pop(context);
                  } else {
                    Toast_Custom("กรุณากรอกตัวเลข", Colors.red);
                  }
                });
              },
              child: Text("ตกลง"))
        ],
      ),
    );
  }
}
