import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:car24repair/screen/loginscreen/confirm_email_screen.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:car24repair/widget/inputsytle.dart';
import 'package:car24repair/widget/loading_screen.dart';
import 'package:car24repair/widget/toast_custom.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key? key}) : super(key: key);
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool statusLoading = false;
  TextEditingController email = TextEditingController();
  TextEditingController user_name = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController pass_word = TextEditingController();
  TextEditingController re_pass_word = TextEditingController();
  final formKey = GlobalKey<FormState>();

  register() async {
    var url = Uri.parse('$ipcon/login_system/register.php');
    var response = await http.post(url, body: {
      "name": name.text,
      "lastname": lastname.text,
      "email": email.text,
      "user_name": user_name.text,
      "pass_word": pass_word.text,
    });
    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
    }
    if (data == "duplicate_username") {
      Toast_Custom("ชื่อผู้ใช้นี้ถูกใช้ไปแล้ว", Colors.red);
    } else if (data == "duplicate_email") {
      Toast_Custom("อีเมลนี้ถูกใช้ไปแล้ว", Colors.red);
    } else if (data == "succes") {
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return ConfirmEmailScreen(
          email: email.text,
        );
      }));
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
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.09),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          "assets/images/logo.png",
                          width: width * 0.4,
                          height: height * 0.11,
                        ),
                        SizedBox(
                          width: width * 0.42,
                          child: AutoSizeText(
                            "Car 24 Repair",
                            minFontSize: 1,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 24,
                                color: Color(0xff5755B7)),
                          ),
                        ),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              buildInputBox(
                                  "Email", email, 0.1, false, "User_fill.png"),
                              buildInputBox("Username", user_name, 0.18, false,
                                  "User_fill.png"),
                              buildInputBox(
                                  "Name", name, 0.1, false, "User_fill.png"),
                              buildInputBox("Lastname", lastname, 0.17, false,
                                  "User_fill.png"),
                              buildInputBox("Password", pass_word, 0.17, true,
                                  "Lock_fill_black.png"),
                              buildInputBox("Re-Password", re_pass_word, 0.23,
                                  true, "Lock_fill_black.png")
                            ],
                          ),
                        ),
                        Container(
                          height: height * 0.165,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [buildButtonSingUP(), buildBackSignIn()],
                          ),
                        ),
                      ],
                    ),
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

  Widget buildInputBox(String? text, TextEditingController controller,
      double? width2, bool? _obscureText, String? img) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.005),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width * width2!,
            child: AutoSizeText(
              "$text",
              minFontSize: 1,
              maxLines: 1,
              style: GoogleFonts.mitr(
                textStyle: TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),
          ),
          SizedBox(
            height: height * 0.00,
          ),
          TextFormField(
              obscureText: _obscureText!,
              validator: (value) {
                if (value!.isEmpty) {
                  if (text == "Email") {
                    return ('กรุณากรอกอีเมล');
                  } else if (text == "Username") {
                    return ('กรุณากรอกชื่อผู้ใช้');
                  } else if (text == "Name") {
                    return ('กรุณากรอกชื่อ');
                  } else if (text == "Lastname") {
                    return ('กรุณากรอกนามสกุล');
                  } else if (text == "Password") {
                    return ('กรุณากรอกรหัสผ่าน');
                  } else if (text == "Re-Password") {
                    return ('กรุณากรอกรหัสผ่าน');
                  }
                }
                if (value.length <= 5) {
                  if (text == "Password") {
                    return ('กรุณาใส่รหัสผ่าน 6 ตัวขึ้นไป');
                  } else if (text == "Re-Password") {
                    return ('กรุณาใส่รหัสผ่าน 6 ตัวขึ้นไป');
                  }
                }
                return null;
              },
              controller: controller,
              decoration: buildInputStyle(context, "$img")),
        ],
      ),
    );
  }

  Widget buildButtonSingUP() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.symmetric(vertical: height * 0.02),
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.11,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: purple,
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
              register();
            }
          }
        },
        child: SizedBox(
          width: width * 0.22,
          child: AutoSizeText(
            "Sign Up",
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

  Widget buildBackSignIn() {
    double width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: width * 0.45,
          child: AutoSizeText(
            "Already have an account?",
            minFontSize: 1,
            maxLines: 1,
            textAlign: TextAlign.end,
            style: GoogleFonts.mitr(
              textStyle: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: SizedBox(
            width: width * 0.12,
            child: AutoSizeText(
              "Sign in",
              minFontSize: 1,
              maxLines: 1,
              style: GoogleFonts.mitr(
                textStyle: TextStyle(color: Color(0xff5755B7), fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
