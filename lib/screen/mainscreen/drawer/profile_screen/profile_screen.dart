import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:car24repair/widget/auto_size_text.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/screen/mainscreen/drawer/chat_screen/chat_screen.dart';
import 'package:car24repair/screen/mainscreen/drawer/profile_screen/edit_profile_screen.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? user_id;
  List userList = [];
  List carList = [];

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

  Future get_car() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      user_id = preferences.getString('user_id');
    });
    var url = Uri.parse('$ipcon/car/get_car.php');
    var response = await http.post(url, body: {
      "user_id": user_id.toString(),
    });
    var data = json.decode(response.body);
    setState(() {
      carList = data;
    });
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
            Container(
              width: width,
              height: height * 0.2,
              color: purple,
              child: AppbarCustom(),
            ),
            FutureBuilder(
              future: get_user(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                return Column(
                  children: [
                    SizedBox(
                      height: height * 0.125,
                    ),
                    Stack(
                      children: [
                        Container(
                          height: height * 0.15,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              buildProfile(),
                              buildMessage(),
                              buildButtonEdit()
                            ],
                          ),
                        ),
                        Positioned(right: 0, bottom: 0, child: buildName())
                      ],
                    ),
                    SizedBox(height: height * 0.025),
                    Container(
                      width: double.infinity,
                      height: height * 0.22,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 0.2,
                            blurRadius: 3,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.07,
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: height * 0.015),
                            userList.isEmpty
                                ? buildRowPhone("เบอร์โทร", "...")
                                : buildRowPhone(
                                    "เบอร์โทร", "${userList[0]['phone']}"),
                            userList.isEmpty
                                ? buildRowEmail("อีเมล", "...")
                                : buildRowEmail(
                                    "อีเมล",
                                    "${userList[0]['email']}",
                                  )
                          ],
                        ),
                      ),
                    ),
                    buildListCar()
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget buildProfile() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: width < 380 ? 85 : 100,
      height: height < 680 ? 85 : 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 0.2,
            blurRadius: 3,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: userList.isEmpty
          ? CircularProgressIndicator()
          : userList[0]['user_img'] != ""
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                    ),
                    CircleAvatar(
                      radius: width * 0.11,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(
                          "$ipcon/images_user/${userList[0]['user_img']}"),
                    ),
                  ],
                )
              : CircleAvatar(
                  backgroundImage: AssetImage("assets/images/profile.jpg"),
                ),
    );
  }

  Widget buildMessage() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return ChatScreen();
        }));
      },
      child: Container(
        width: width * 0.105,
        height: height * 0.05,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 0.2,
              blurRadius: 3,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Image.asset(
          "assets/images/Chat_fill.png",
        ),
      ),
    );
  }

  Widget buildButtonEdit() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return EditProfileScreen(
            user_id: user_id,
          );
        }));
      },
      child: Container(
        width: width * 0.4,
        height: height * 0.045,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 0.2,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: SizedBox(
            width: width * 0.17,
            child: AutoSizeText(
              "แก้ไขข้อมูล",
              maxLines: 1,
              minFontSize: 1,
              style: GoogleFonts.mitr(
                textStyle: TextStyle(color: Color(0xff5755B7), fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildListCar() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return FutureBuilder(
      future: get_car(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return carList.isEmpty
            ? Container()
            : Container(
                height: carList.length <= 2 ? height * 0.38 : height * 0.48,
                child: ListView.builder(
                  padding: EdgeInsets.all(0),
                  itemCount: carList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      width: double.infinity,
                      height: height * 0.19,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                        child: Row(
                          children: [
                            Container(
                              width: width * 0.35,
                              height: height * 0.18,
                              child: Image.network(
                                "$ipcon/images_car/${carList[index]['car_img']}",
                                fit: BoxFit.contain,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: height * 0.01,
                                  horizontal: width * 0.04),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: height * 0.01),
                                  AutoText(
                                    width: width * 0.37,
                                    text: "${carList[index]['car_brand']} ",
                                    fontSize: 20,
                                    color: Colors.black,
                                    text_align: TextAlign.left,
                                    fontWeight: null,
                                  ),
                                  AutoText(
                                    width: width * 0.37,
                                    text: carList[index]['car_model'],
                                    fontSize: 16,
                                    color: Colors.black,
                                    text_align: TextAlign.left,
                                    fontWeight: null,
                                  ),
                                  buildRowText("ทะเบียนรถ",
                                      "${carList[index]['car_regis']}"),
                                  buildRowText("เครื่องยนต์",
                                      "${carList[index]['engine_type']}"),
                                  buildRowText("ประเภทเกียร์",
                                      "${carList[index]['gear_type']}")
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
      },
    );
  }

  Widget buildRowText(String? text1, String? text2) {
    double width = MediaQuery.of(context).size.width;
    return Row(
      children: [
        AutoText(
            width: width * 0.16,
            text: text1,
            fontSize: 14,
            color: Colors.black,
            text_align: TextAlign.left,
            fontWeight: null),
        SizedBox(
          width: width * 0.02,
        ),
        AutoText(
            width: width * 0.16,
            text: text2,
            fontSize: 14,
            color: Colors.grey,
            text_align: TextAlign.left,
            fontWeight: null),
      ],
    );
  }

  Widget buildRowPhone(String? text1, String? text2) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: width * 0.25,
              child: AutoSizeText(
                "$text1 :",
                maxLines: 1,
                minFontSize: 1,
                style: GoogleFonts.mitr(
                  textStyle: TextStyle(color: purple, fontSize: 24),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: width * 0.6,
              child: Text(
                "$text2",
                style: GoogleFonts.mitr(
                  textStyle: TextStyle(color: Colors.grey, fontSize: 24),
                ),
              ),
            ),
            Image.asset(
              "assets/images/View_fill.png",
              height: height * 0.035,
            )
          ],
        ),
      ],
    );
  }

  Widget buildRowEmail(String? text1, String? text2) {
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Row(
          children: [
            Text(
              "$text1 :",
              style: GoogleFonts.mitr(
                textStyle: TextStyle(color: purple, fontSize: 24),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$text2",
              style: GoogleFonts.mitr(
                textStyle: TextStyle(color: Colors.grey, fontSize: 24),
              ),
            ),
            Image.asset(
              "assets/images/View_fill.png",
              height: height * 0.035,
            )
          ],
        ),
      ],
    );
  }

  Widget buildName() {
    double width = MediaQuery.of(context).size.width;
    return Row(
      children: [
        SizedBox(
          width: width * 0.58,
          child: userList.isEmpty
              ? AutoSizeText(
                  "...",
                  minFontSize: 1,
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.mitr(
                    textStyle: TextStyle(color: purple, fontSize: 40),
                  ),
                )
              : AutoSizeText(
                  "${userList[0]['name']} ${userList[0]['lastname']}",
                  minFontSize: 1,
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.mitr(
                    textStyle: TextStyle(color: purple, fontSize: 22),
                  ),
                ),
        ),
        SizedBox(
          width: width * 0.05,
        )
      ],
    );
  }
}
