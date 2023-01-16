// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'package:car24repair/widget/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:flutter/material.dart';

class ArrivedScreen extends StatefulWidget {
  String? request_id;
  ArrivedScreen({required this.request_id});
  @override
  State<ArrivedScreen> createState() => _ArrivedScreenState();
}

class _ArrivedScreenState extends State<ArrivedScreen> {
  List requestList = [];
  String? status;

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
      print(status);
    }
  }

  @override
  void initState() {
    Timer.periodic(Duration(seconds: 5), (timer) async {
      get_accept_request();
      if (status == "success") {
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
                            children: [
                              buildRowtop(),
                              buildWantSlide(),
                              SizedBox(height: height * 0.03),
                              buildChat(),
                              SizedBox(height: height * 0.04),
                              status == 'success'
                                  ? buildSuccessStatus()
                                  : buildArrivedStatus()
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
    return requestList.isEmpty
        ? Container()
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.03),
            child: CircleAvatar(
              radius: width * 0.09,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: width * 0.08,
                backgroundImage: NetworkImage(
                    "$ipcon/images_user/${requestList[0]['user_img']}"),
              ),
            ),
          );
  }
}
