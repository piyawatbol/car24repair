import 'dart:convert';
import 'package:car24repair/screen/mainscreen/home_screen/home_screen.dart';
import 'package:car24repair/screen/mainscreen/home_screen/select_car/quick_car_screen/status_quick_screen.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/widget/appbar/app_bar_custom.dart';
import 'package:car24repair/widget/auto_size_text.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class WaitingQuickScreen extends StatefulWidget {
  WaitingQuickScreen({Key? key}) : super(key: key);

  @override
  State<WaitingQuickScreen> createState() => _WaitingQuickScreenState();
}

class _WaitingQuickScreenState extends State<WaitingQuickScreen> {
  String user_id = "";
  List requestList = [];
  String? status;

  get_request() async {
    var url = Uri.parse('$ipcon/request/get_request_user.php');
    var response = await http.post(url, body: {
      "user_id": user_id,
    });
    var data = json.decode(response.body);
    if (this.mounted) {
      setState(() {
        requestList = data;
        status = requestList[0]['status'];
      });
    }
  }

  get_user_id() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      user_id = preferences.getString('user_id')!;
    });
  }

  cancel_request() async {
    var url = Uri.parse('$ipcon/request/delete_request.php');
    var response = await http.post(url, body: {
      "user_id": user_id,
    });
    if (this.mounted) {
      if (response.statusCode == 200) {
        setState(() {
          status = "cancel";
        });
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return HomeScreen();
        }), (route) => false);
      }
    }
  }

  @override
  void initState() {
    get_user_id();
    Timer.periodic(Duration(seconds: 5), (timer) async {
      print("status $status");
      get_request();
      if (status == "accept" || status == "ready") {
        timer.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return StatusQuickScreen(
                request_id: requestList[0]['request_id'],
              );
            },
          ),
        );
      } else if (status == "cancel") {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return HomeScreen();
        }), (route) => false);
      }
    });
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
        child: Column(
          children: [
            AppbarCustom(),
            Container(
              width: width,
              height: height * 0.76,
              child: Center(
                child: AutoText(
                  width: width * 0.7,
                  text: "กำลังหาช่าง ...",
                  fontSize: 64,
                  color: purple,
                  text_align: TextAlign.left,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            buildButton("ยกเลิก")
          ],
        ),
      ),
    );
  }

  Widget buildButton(String? text) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.03),
      width: width * 0.7,
      height: height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Color(0xffDBDBDB),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        onPressed: () async {
          cancel_request();
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
