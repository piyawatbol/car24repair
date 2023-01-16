// ignore_for_file: unused_local_variable, deprecated_member_use

import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:car24repair/widget/inputsytle.dart';
import 'package:car24repair/widget/loading_screen.dart';
import 'package:car24repair/widget/toast_custom.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/screen/fotget_password_screen/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgetPasswordScreen extends StatefulWidget {
  ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  TextEditingController email = TextEditingController();
  bool statusLoading = false;

  checkEmail() async {
    var url = Uri.parse('$ipcon/forget_password/checkEmail.php');
    var response = await http.post(url, body: {
      "email": email.text,
    });
    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
    }
    if (data == "have email") {
      setState(() {
        statusLoading = true;
      });
      sendEmail();
    } else {
      Toast_Custom("ไม่พบอีเมลดังกล่าว", Colors.red);
    }
  }

  sendEmail() async {
    var url = Uri.parse('$ipcon/forget_password/forgetbyemail.php');
    var response = await http.post(url, body: {
      "email": email.text,
    });
    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
    }
    if (data == "sendemail success") {
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return OtpScreen(
          email: email.text,
        );
      }));
      Toast_Custom("ส่ง OTP ไปที่อีเมลเรียบร้อย", Colors.green);
    }
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
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Stack(
          children: [
            Container(
              color: Colors.white,
              width: width,
              height: height,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.09),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: height * 0.035),
                      Image.asset(
                        "assets/images/logo.png",
                        width: width * 0.4,
                        height: height * 0.11,
                      ),
                      SizedBox(
                        width: width * 0.37,
                        child: AutoSizeText(
                          "Car 24 Repair",
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          minFontSize: 1,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 24,
                              color: Color(0xff5755B7)),
                        ),
                      ),
                      SizedBox(height: height * 0.08),
                      SizedBox(
                        width: width * 0.46,
                        child: AutoSizeText(
                          "Password Recovery",
                          minFontSize: 1,
                          maxLines: 1,
                          style: GoogleFonts.mitr(
                            textStyle: TextStyle(
                                color: Color(0xff5755B7), fontSize: 22),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      buildEmailBox(),
                      Container(
                        width: double.infinity,
                        height: height * 0.35,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [buildButton()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            LoadingScreen(statusLoading: statusLoading)
          ],
        ),
      ),
    );
  }

  Widget buildButton() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.symmetric(vertical: height * 0.02),
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.11,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.black87,
          primary: purple,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        onPressed: () {
          setState(() {
            statusLoading = true;
          });
          checkEmail();
        },
        child: SizedBox(
          width: width * 0.14,
          child: AutoSizeText(
            "Next",
            minFontSize: 1,
            maxLines: 1,
            style: GoogleFonts.mitr(
              textStyle: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmailBox() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.025),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width * 0.08,
            child: AutoSizeText(
              "Email",
              maxLines: 1,
              minFontSize: 1,
              style: GoogleFonts.mitr(
                  textStyle: TextStyle(color: Colors.black, fontSize: 14)),
            ),
          ),
          SizedBox(height: height * 0.01),
          TextFormField(
              controller: email, decoration: buildInputStyle(context, "")),
        ],
      ),
    );
  }
}
