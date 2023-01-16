// ignore_for_file: unused_local_variable, deprecated_member_use, must_be_immutable

import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:car24repair/widget/inputsytle.dart';
import 'package:car24repair/widget/loading_screen.dart';
import 'package:car24repair/widget/toast_custom.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:car24repair/screen/loginscreen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RePasswordScreen extends StatefulWidget {
  String? email;
  RePasswordScreen({required this.email});

  @override
  State<RePasswordScreen> createState() => _RePasswordScreenState();
}

class _RePasswordScreenState extends State<RePasswordScreen> {
  bool statusLoading = false;
  TextEditingController pass_word = TextEditingController();
  TextEditingController re_pass_word = TextEditingController();
  final formKey = GlobalKey<FormState>();

  reset_pass() async {
    var url = Uri.parse('$ipcon/forget_password/repass.php');
    var response = await http.post(url, body: {
      "pass_word": pass_word.text,
      "re_pass_word": re_pass_word.text,
      "email": widget.email,
    });
    var data = json.decode(response.body);
    print(data);

    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
    }
    if (data == "reset password success") {
      Toast_Custom("รีเซ็ตรหัสผ่านเรียบร้อย", Colors.green);
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return LoginScreen();
      }), (route) => false);
    } else {
      Toast_Custom("เกิดข้อผิดพลาด", Colors.red);
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
                      SizedBox(height: height * 0.02),
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
                      SizedBox(height: height * 0.02),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            buildPassBox(),
                            buildRePassBox(),
                          ],
                        ),
                      ),
                      Container(
                        height: height * 0.24,
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
          final isValid = formKey.currentState!.validate();
          if (isValid) {
            if (pass_word.text != re_pass_word.text) {
              Toast_Custom("รหัสผ่านไม่ตรงกัน", Colors.red);
            } else {
              setState(() {
                statusLoading = true;
              });
              reset_pass();
            }
          }
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

  Widget buildPassBox() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.005),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width * 0.21,
            child: AutoSizeText(
              "ตั้งรหัสผ่านใหม่",
              maxLines: 1,
              minFontSize: 1,
              style: GoogleFonts.mitr(
                  textStyle: TextStyle(color: Colors.black, fontSize: 14)),
            ),
          ),
          SizedBox(height: height * 0.01),
          TextFormField(
              obscureText: true,
              validator: (value) {
                if (value!.isEmpty) {
                  return ('กรุณากรอกรหัสผ่าน');
                }
                if (value.length <= 5) {
                  return ('กรุณาใส่รหัสผ่าน 6 ตัวขึ้นไป');
                }
                return null;
              },
              controller: pass_word,
              decoration: buildInputStyle(context, "")),
        ],
      ),
    );
  }

  Widget buildRePassBox() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.005),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width * 0.18,
            child: AutoSizeText(
              "รหัสผ่าน (ซ้ำ)",
              minFontSize: 1,
              maxLines: 1,
              style: GoogleFonts.mitr(
                  textStyle: TextStyle(color: Colors.black, fontSize: 14)),
            ),
          ),
          SizedBox(height: height * 0.01),
          TextFormField(
              obscureText: true,
              validator: (value) {
                if (value!.isEmpty) {
                  return ('กรุณากรอกรหัสผ่าน');
                }
                if (value.length <= 5) {
                  return ('กรุณาใส่รหัสผ่าน 6 ตัวขึ้นไป');
                }
                return null;
              },
              controller: re_pass_word,
              decoration: buildInputStyle(context, "")),
        ],
      ),
    );
  }
}
