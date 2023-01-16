import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/screen/mainscreen/home_screen/technician_appointment_screen/technician_appointment_screen2.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TechnicianAppoinmentScreen extends StatefulWidget {
  TechnicianAppoinmentScreen({Key? key}) : super(key: key);
  @override
  State<TechnicianAppoinmentScreen> createState() =>
      _TechnicianAppoinmentScreenState();
}

class _TechnicianAppoinmentScreenState
    extends State<TechnicianAppoinmentScreen> {
  List apmList = [];
  String? user_id;

  get_apm_join() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    var url = Uri.parse('$ipcon/appointment/get_apm_join.php');
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
    get_apm_join();
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppbarCustom(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                child: Text(
                  "นัดช่าง",
                  style: GoogleFonts.mitr(
                    textStyle:
                        TextStyle(color: Color(0xff5755B7), fontSize: 64),
                  ),
                ),
              ),
              buildContainer(),
              buildAddMoreCar()
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContainer() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height * 0.6,
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: apmList.length,
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: width,
                height: height * 0.28,
              ),
              Positioned(
                top: height * 0.035,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      width: width * 0.82,
                      height: height * 0.23,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: height * 0.12,
                            ),
                            Text(
                              "${apmList[index]['detail']}",
                              style: GoogleFonts.mitr(
                                textStyle: TextStyle(
                                    color: purple,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "${apmList[index]['date']}",
                                  style: GoogleFonts.mitr(
                                    textStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                SizedBox(width: width * 0.02),
                                Text(
                                  "${apmList[index]['time']}",
                                  style: GoogleFonts.mitr(
                                    textStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: width * 0.95,
                      height: height * 0.1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: width * 0.3,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: height * 0.01,
                              ),
                              Text(
                                "${apmList[index]['name']} ${apmList[index]['lastname']}",
                                style: GoogleFonts.mitr(
                                  textStyle: TextStyle(
                                      color: purple,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              Text(
                                "${apmList[index]['phone']}",
                                style: GoogleFonts.mitr(
                                  textStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: height * 0.003,
                left: width * 0.1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: apmList[index]['user_img'] != ""
                      ? CircleAvatar(
                          radius: width * 0.09,
                          backgroundImage: NetworkImage(
                              "$ipcon/images_user/${apmList[index]['user_img']}"))
                      : CircleAvatar(
                          radius: width * 0.09,
                          backgroundImage:
                              AssetImage("assets/images/profile.jpg"),
                        ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget buildAddMoreCar() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.05, vertical: height * 0.01),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return TechnicianAppoinmentScreen2();
          }));
        },
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: Radius.circular(20),
          dashPattern: [10, 5],
          color: purple,
          strokeWidth: 2,
          child: Container(
              width: double.infinity,
              height: height * 0.12,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/Vector.png",
                      width: width * 0.1,
                      color: purple,
                    ),
                    Text(
                      "นัดช่าง",
                      style: GoogleFonts.mitr(
                        textStyle: TextStyle(
                            color: purple,
                            fontSize: 20,
                            fontWeight: FontWeight.w300),
                      ),
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
