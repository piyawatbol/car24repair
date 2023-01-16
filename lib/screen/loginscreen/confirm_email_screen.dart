// ignore_for_file: deprecated_member_use, must_be_immutable

import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/screen/loginscreen/login_screen.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:car24repair/widget/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ConfirmEmailScreen extends StatefulWidget {
  String? email;
  ConfirmEmailScreen({required this.email});

  @override
  State<ConfirmEmailScreen> createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends State<ConfirmEmailScreen> {
  bool statusLoading = false;
  TextEditingController otp = TextEditingController();
  sendEmail() async {
    var url = Uri.parse('$ipcon/forget_password/forgetbyemail.php');
    var response = await http.post(url, body: {
      "email": widget.email,
    });
    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
    }
    if (data == "sendemail success") {
      buildDialogCustom("ส่ง OTP ไปที่อีเมลเรียบร้อย", Colors.green);
    }
  }

  checkOtp() async {
    var url = Uri.parse('$ipcon/login_system/checkOtp.php');
    var response = await http.post(url, body: {
      "email": widget.email,
      "otp": otp.text,
    });
    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
    }
    if (data == "correct") {
      buildDialogCustom("สมัครสมาชิกเสร็จสิ้น", Colors.green);
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return LoginScreen();
      }), (route) => false);
    } else if (data == "in_correct") {
      buildDialogCustom("รหัส OTP ไม่ถูกต้อง", Colors.red);
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
                      SizedBox(
                        height: height * 0.035,
                      ),
                      Image.asset(
                        "assets/images/logo.png",
                        width: width * 0.4,
                        height: height * 0.11,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: height * 0.015),
                        child: SizedBox(
                          width: width * 0.37,
                          child: AutoSizeText(
                            "Car 24 Repair",
                            maxLines: 1,
                            minFontSize: 1,
                            style: TextStyle(
                                fontSize: 24, color: Color(0xff5755B7)),
                          ),
                        ),
                      ),
                      buildSendOtpButton(),
                      buildOtpBox(),
                      buildButtonContinnue()
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

  Widget buildOtpBox() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.005),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width * 0.11,
            child: AutoSizeText(
              "OTP",
              maxLines: 1,
              minFontSize: 1,
              style: GoogleFonts.mitr(
                  textStyle: TextStyle(color: Colors.black, fontSize: 14)),
            ),
          ),
          SizedBox(height: height * 0.01),
          TextFormField(
            validator: (value) {
              if (value!.isEmpty) {
                return ('กรุณากรอกอีเมล');
              }
              return null;
            },
            controller: otp,
            decoration: buildInputsytle()
          ),
        ],
      ),
    );
  }

  Widget buildSendOtpButton() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.02),
      child: Column(
        children: [
          Text(
            "${widget.email}",
            style: GoogleFonts.mitr(
              textStyle: TextStyle(color: purple, fontSize: 20),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: height * 0.01),
            width: width * 0.3,
            height: MediaQuery.of(context).size.height * 0.04,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  statusLoading = true;
                });
                sendEmail();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(purple),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              child: SizedBox(
                width: width * 0.13,
                child: AutoSizeText(
                  "ส่ง OTP",
                  minFontSize: 1,
                  maxLines: 1,
                  style: GoogleFonts.mitr(
                    textStyle: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButtonContinnue() {
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
          checkOtp();
        },
        child: SizedBox(
          width: width * 0.26,
          child: AutoSizeText(
            "Continue",
            maxLines: 1,
            minFontSize: 1,
            style: GoogleFonts.mitr(
              textStyle: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }

  buildDialogCustom(String? text, Color? color) {
    Fluttertoast.showToast(
        msg: "$text",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16);
  }
 buildInputsytle(){
   double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
  return  InputDecoration(
              suffixIcon: Icon(
                Icons.email,
                color: Colors.black,
              ),
              filled: true,
              fillColor: Color(0xffD9D9D9),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: width * 0.06, vertical: height * 0.015),
              disabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xffD9D9D9)),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xffD9D9D9)),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xffD9D9D9)),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(15),
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(15),
              ),
            );
 }
}
