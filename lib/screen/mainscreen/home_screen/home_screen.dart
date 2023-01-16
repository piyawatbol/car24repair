// ignore_for_file: deprecated_member_use, unused_field
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:car24repair/screen/mainscreen/drawer/mycar_screen/add_new_car_screen.dart';
import 'package:car24repair/screen/mainscreen/home_screen/tech_near_me_screen/tech_near_me_screen.dart';
import 'package:car24repair/widget/auto_size_text.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:car24repair/screen/mainscreen/home_screen/select_car/call_car_slide_screen/call_car_slide_screen.dart';
import 'package:car24repair/screen/mainscreen/home_screen/select_car/quick_car_screen/quick_car_screen.dart';
import 'package:car24repair/screen/mainscreen/home_screen/technician_appointment_screen/technician_appointment_screen.dart';
import 'package:car24repair/widget/drawer/menudrawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? user_id;
  List userList = [];
  List apmList = [];

  Future get_user() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    print("user_id : $user_id");
    var url = Uri.parse('$ipcon/user/get_user.php');
    var response = await http.post(url, body: {
      "user_id": user_id.toString(),
    });
    var data = json.decode(response.body);
    setState(() {
      userList = data;
    });
  }

  get_apm() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    var url = Uri.parse('$ipcon/appointment/get_apm.php');
    var response = await http.post(url, body: {
      "user_id": user_id,
    });
    var data = await json.decode(response.body);
    setState(() {
      apmList = data;
    });
  }

  @override
  void initState() {
    get_user();
    get_apm();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        color: Colors.white,
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
            SizedBox(height: height * 0.06),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05, vertical: height * 0.01),
              child: SizedBox(
                width: width * 0.34,
                child: AutoSizeText(
                  "ให้เราช่วยคุณ",
                  minFontSize: 1,
                  maxLines: 1,
                  style: GoogleFonts.mitr(
                    textStyle: TextStyle(color: Colors.black, fontSize: 22),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [buildButtonLeft(), buildButtonRight()],
              ),
            ),
            buildButtonButtom(),
            buildButton1(),
            SizedBox(height: height * 0.01),
            buildButton2()
          ],
        ),
      ),
    );
  }

  Widget buildButtonLeft() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: width * 0.425,
      height: height * 0.19,
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
          onPrimary: Colors.black87,
          primary: purple,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return QuickCarScreen();
          }));
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: height * 0.01),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/images/mile.png",
                  color: Colors.white,
                  width: width * 0.2,
                  height: height * 0.1,
                ),
                SizedBox(
                  width: width * 0.3,
                  child: AutoSizeText(
                    "ซ่อมรถด่วน",
                    minFontSize: 1,
                    maxLines: 1,
                    style: GoogleFonts.mitr(
                      textStyle: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButtonRight() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: width * 0.425,
      height: height * 0.19,
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
          onPrimary: Colors.black87,
          primary: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return CallCarSlideScreen();
          }));
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: height * 0.01),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: height * 0.01),
                  child: Image.asset(
                    "assets/images/location.png",
                    width: width * 0.2,
                    height: height * 0.09,
                    color: purple,
                  ),
                ),
                SizedBox(
                  width: width * 0.2,
                  child: AutoSizeText(
                    "รถสไลด์",
                    minFontSize: 1,
                    maxLines: 1,
                    style: GoogleFonts.mitr(
                      textStyle: TextStyle(color: purple, fontSize: 24),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButtonButtom() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: width * 0.05, vertical: height * 0.021),
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
          onPrimary: Colors.black87,
          primary: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return TechnicianAppoinmentScreen();
          }));
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: height * 0.007),
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
                          textStyle:
                              TextStyle(color: Color(0xff5755B7), fontSize: 24),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SingleChildScrollView(
                child: Container(
                  width: width * 0.6,
                  height: height * 0.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AutoText(
                        width: width * 0.3,
                        text: "กำหนดการ",
                        fontSize: 24,
                        color: purple,
                        text_align: TextAlign.right,
                        fontWeight: null,
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(0),
                          itemCount: apmList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                AutoText(
                                  width: width * 0.4,
                                  text: "${apmList[index]['detail']}",
                                  fontSize: 14,
                                  color: purple,
                                  text_align: TextAlign.right,
                                  fontWeight: null,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    AutoText(
                                      width: width * 0.2,
                                      text: "${apmList[index]['date']}",
                                      fontSize: 14,
                                      color: grey2,
                                      text_align: TextAlign.right,
                                      fontWeight: null,
                                    ),
                                    AutoText(
                                      width: width * 0.12,
                                      text: "${apmList[index]['time']}",
                                      fontSize: 14,
                                      color: grey2,
                                      text_align: TextAlign.right,
                                      fontWeight: null,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
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
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 0.1,
                    blurRadius: 2,
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
  }

  Widget buildButton1() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: width * 0.05),
      width: double.infinity,
      height: height * 0.06,
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
          onPrimary: Colors.black87,
          primary: purple,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return AddNewCarScreen();
          }));
        },
        child: Row(
          children: [
            SizedBox(
              width: width * 0.01,
            ),
            SizedBox(
              width: width * 0.3,
              child: AutoSizeText(
                "เพิ่มข้อมูลรถ",
                minFontSize: 1,
                maxLines: 1,
                style: GoogleFonts.mitr(
                  textStyle: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton2() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: width * 0.05),
      width: double.infinity,
      height: height * 0.06,
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
          onPrimary: Colors.black87,
          primary: Color(0xffDBDBDB),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return TechNearMeScreen();
          }));
        },
        child: Row(
          children: [
            Container(
              width: width * 0.52,
              child: AutoSizeText(
                "\"ช่างซ่อมรถ\" ใกล้ฉัน",
                minFontSize: 1,
                maxLines: 1,
                style: GoogleFonts.mitr(
                  textStyle: TextStyle(color: purple, fontSize: 23),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
