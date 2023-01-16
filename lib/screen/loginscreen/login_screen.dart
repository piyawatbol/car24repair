import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:car24repair/screen/fotget_password_screen/forget_screen.dart';
import 'package:car24repair/screen/loginscreen/confirm_email_screen.dart';
import 'package:car24repair/screen/loginscreen/register_screen.dart';
import 'package:car24repair/screen/mainscreen/home_screen/home_screen.dart';
import 'package:car24repair/screen/mainscreen/home_tech_screen/home_screen_tech.dart';
import 'package:car24repair/widget/colors.dart';
import 'package:car24repair/widget/inputsytle.dart';
import 'package:car24repair/widget/loading_screen.dart';
import 'package:car24repair/widget/toast_custom.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:car24repair/ipcon.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool statusLoading = false;
  List userList = [];
  TextEditingController user_name = TextEditingController();
  TextEditingController pass_word = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void lineSDKInit() async {
    await LineSDK.instance.setup("1657819331").then((_) {
      // print("LineSDK is Prepared");
    });
  }

  Future getAccessToken() async {
    try {
      final result = await LineSDK.instance.currentAccessToken;
      return result!.value;
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  void startLineLogin() async {
    try {
      setState(() {});
      final result =
          await LineSDK.instance.login(scopes: ["profile", "openid", "email"]);
      print(result.toString());
      final userEmail = result.accessToken.email;
      var displayname = result.userProfile!.displayName;
      print(displayname);
      print(userEmail);
      loginLine(userEmail, displayname);
    } on PlatformException catch (e) {
      setState(() {
        statusLoading = false;
      });
      print(e);
      switch (e.code.toString()) {
        default:
          Toast_Custom(
              "เกิดข้อผิดพลาด กรุณาเข้าสู่ระบบใหม่อีกครั้ง", Colors.red);
          break;
      }
    }
  }

  login() async {
    var url = Uri.parse('$ipcon/login_system/login.php');
    var response = await http.post(url, body: {
      "user_name": user_name.text,
      "pass_word": pass_word.text,
    });
    var data = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        statusLoading = false;
      });
    }
    if (data == "miss") {
      Toast_Custom("ชื่อผู้ใช้ หรือ รหัสผ่านไม่ถูกต้อง", Colors.red);
    } else {
      setState(() {
        userList = data;
      });
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('user_id', userList[0]['user_id']);
      preferences.setString('user_type', userList[0]['user_type']);
      if (userList[0]['status_email'] == "0") {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return ConfirmEmailScreen(email: userList[0]['email']);
        }));
      } else {
        if (userList[0]['user_type'] == "user") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return HomeScreen();
          }));
        } else if (userList[0]['user_type'] == "tech") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return HomeScreenTech();
          }));
        }
      }
    }
  }

  loginLine(String? email, String? name) async {
    var url = Uri.parse('$ipcon/login_system/login_line.php');
    var response = await http.post(url, body: {
      "email": email.toString(),
    });
    var data = json.decode(response.body);
    if (data == "don't have accout") {
      register_line(email, name);
    } else {
      setState(() {
        userList = data;
      });
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('user_id', userList[0]['user_id']);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return HomeScreen();
      }));
    }
  }

  register_line(String? email, String? name) async {
    var url = Uri.parse('$ipcon/login_system/register_line.php');
    var response = await http.post(url, body: {
      "name": name.toString(),
      "lastname": "",
      "email": email.toString(),
      "user_name": "",
      "pass_word": "",
    });
    var data = json.decode(response.body);
    print(data);
    if (response.statusCode == 200) {
      loginLine(email, name);
    } else {
      setState(() {
        statusLoading = false;
      });
    }
  }

  @override
  void initState() {
    lineSDKInit();
    super.initState();
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
        body: Stack(
          children: [
            Container(
              width: width,
              height: height,
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: height * 0.1),
                      Image.asset(
                        "assets/images/logo.png",
                        width: width * 0.3,
                        height: height * 0.1,
                      ),
                      SizedBox(
                        width: width * 0.37,
                        child: AutoSizeText(
                          "Car 24 Repair",
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          minFontSize: 1,
                          style: TextStyle(
                              fontSize: 24,
                              color: Color(0xff5755B7),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: width * 0.09, vertical: height * 0.09),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  buildUserBox(),
                                  SizedBox(
                                    height: height * 0.02,
                                  ),
                                  buildPassBox(),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return ForgetPasswordScreen();
                                }));
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: height * 0.015),
                                child: SizedBox(
                                  width: width * 0.31,
                                  child: AutoSizeText(
                                    "Forget Password?",
                                    minFontSize: 1,
                                    maxLines: 1,
                                    style: GoogleFonts.mitr(
                                      textStyle: TextStyle(
                                          color: Color(0xff5755B7),
                                          fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            buildSingInButton(),
                            buildButtonLine(),
                            SizedBox(height: height * 0.01),
                            buildCreateOne()
                          ],
                        ),
                      )
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

  Widget buildUserBox() {
    double width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: width * 0.18,
          child: AutoSizeText(
            "Username",
            minFontSize: 1,
            maxLines: 1,
            style: GoogleFonts.mitr(
                textStyle: TextStyle(color: Colors.black, fontSize: 14)),
          ),
        ),
        TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return ('กรุณากรอกชื่อผู้ใช้');
            }
            return null;
          },
          controller: user_name,
          decoration: buildInputStyle(context, "User_fill.png"),
        ),
      ],
    );
  }

  Widget buildPassBox() {
    double width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: width * 0.18,
          child: AutoSizeText(
            "Passsword",
            minFontSize: 1,
            maxLines: 1,
            style: GoogleFonts.mitr(
                textStyle: TextStyle(
              color: Colors.black,
              fontSize: 14,
            )),
          ),
        ),
        TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return ('กรุณากรอกรหัสผ่าน');
            }
            return null;
          },
          controller: pass_word,
          obscureText: true,
          decoration: buildInputStyle(context, "Lock_fill_black.png"),
        ),
      ],
    );
  }

  Widget buildSingInButton() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.002),
      width: double.infinity,
      height: height * 0.05,
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
            setState(() {
              statusLoading = true;
            });
            login();
          }
        },
        child: Container(
          width: width * 0.18,
          child: AutoSizeText(
            "Sign In",
            textAlign: TextAlign.center,
            minFontSize: 1,
            maxLines: 1,
            style: GoogleFonts.mitr(
              textStyle: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButtonLine() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.002),
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.green,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        onPressed: () {
          setState(() {
            statusLoading = true;
          });
          startLineLogin();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/line_icon.png",
              width: width * 0.06,
            ),
            SizedBox(width: width * 0.01),
            SizedBox(
              child: AutoSizeText(
                "Line",
                textAlign: TextAlign.center,
                minFontSize: 1,
                maxLines: 1,
                style: GoogleFonts.mitr(
                  textStyle: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCreateOne() {
    double width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: width * 0.3,
          child: AutoSizeText(
            "Don't have accout? ",
            textAlign: TextAlign.end,
            minFontSize: 1,
            maxLines: 1,
            style: GoogleFonts.mitr(
              textStyle: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return RegisterScreen();
            }));
          },
          child: Container(
            width: width * 0.2,
            child: AutoSizeText(
              "Create One",
              minFontSize: 1,
              maxLines: 1,
              style: GoogleFonts.mitr(
                textStyle: TextStyle(color: Color(0xff5755B7), fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showDialogBox(String title, String body) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Text(body)],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("ปิด"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
